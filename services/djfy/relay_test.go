package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

const guestA = "guest-aaaaaaaa"

func msg(t, guest string) []byte {
	return []byte(`{"type":"` + t + `","guestId":"` + guest + `","name":"Káťa"}`)
}

func TestCodeAlphabetAvoidsAmbiguousChars(t *testing.T) {
	for range 200 {
		c := randomCode()
		if len(c) != codeLength || strings.ContainsAny(c, "0O1IL") {
			t.Fatalf("bad code %q", c)
		}
	}
}

func TestHostAuth(t *testing.T) {
	h := NewHub(DefaultLimits)
	code, _ := h.Create()
	if err := h.PublishSnapshot(code, "wrong", json.RawMessage(`{}`)); !errors.Is(err, ErrForbidden) {
		t.Fatalf("want forbidden, got %v", err)
	}
	if _, _, err := h.SubscribeHost("ZZZZ", "x"); !errors.Is(err, ErrNotFound) {
		t.Fatalf("want not found, got %v", err)
	}
}

func TestGuestGetsCachedSnapshotOnJoin(t *testing.T) {
	h := NewHub(DefaultLimits)
	code, tok := h.Create()
	if err := h.PublishSnapshot(code, tok, json.RawMessage(`{"v":1}`)); err != nil {
		t.Fatal(err)
	}
	ch, cancel, err := h.SubscribeGuest(code, guestA)
	if err != nil {
		t.Fatal(err)
	}
	defer cancel()
	ev := <-ch
	if ev.Type != "snapshot" || string(ev.Data) != `{"v":1}` {
		t.Fatalf("got %+v", ev)
	}
	h.PublishSnapshot(code, tok, json.RawMessage(`{"v":2}`))
	if ev := <-ch; string(ev.Data) != `{"v":2}` {
		t.Fatalf("got %+v", ev)
	}
}

func TestBacklogFlushedWhenHostConnects(t *testing.T) {
	h := NewHub(DefaultLimits)
	code, tok := h.Create()
	if err := h.FromGuest(code, msg("join", guestA)); err != nil {
		t.Fatal(err)
	}
	ch, cancel, _ := h.SubscribeHost(code, tok)
	defer cancel()
	select {
	case ev := <-ch:
		if ev.Type != "guest" || !strings.Contains(string(ev.Data), `"join"`) {
			t.Fatalf("got %+v", ev)
		}
	default:
		t.Fatal("backlog not flushed")
	}
}

func TestProposalRateLimit(t *testing.T) {
	h := NewHub(Limits{ProposalsPer10Min: 2, SearchesPerMin: 10, VotesPerMin: 10})
	now := time.Unix(1000, 0)
	h.now = func() time.Time { return now }
	code, _ := h.Create()
	for i := range 2 {
		if err := h.FromGuest(code, msg("propose", guestA)); err != nil {
			t.Fatalf("propose %d: %v", i, err)
		}
	}
	if err := h.FromGuest(code, msg("propose", guestA)); !errors.Is(err, ErrRateLimited) {
		t.Fatalf("want rate limited, got %v", err)
	}
	// Another guest has their own budget.
	if err := h.FromGuest(code, msg("propose", "guest-bbbbbbbb")); err != nil {
		t.Fatal(err)
	}
	now = now.Add(10*time.Minute + time.Second)
	if err := h.FromGuest(code, msg("propose", guestA)); err != nil {
		t.Fatalf("window should have slid: %v", err)
	}
}

func TestRejectsBadMessages(t *testing.T) {
	h := NewHub(DefaultLimits)
	code, _ := h.Create()
	for _, raw := range []string{
		`not json`,
		`{"type":"snapshot","guestId":"guest-aaaaaaaa"}`,
		`{"type":"vote","guestId":"short"}`,
		`{"type":"vote","guestId":"guest-aaaaaaaa","name":"` + strings.Repeat("x", 40) + `"}`,
	} {
		if err := h.FromGuest(code, []byte(raw)); !errors.Is(err, ErrBadMessage) {
			t.Errorf("%s: want bad message, got %v", raw, err)
		}
	}
}

func TestBanClosesAndBlocks(t *testing.T) {
	h := NewHub(DefaultLimits)
	code, tok := h.Create()
	ch, cancel, _ := h.SubscribeGuest(code, guestA)
	defer cancel()
	if err := h.Ban(code, tok, guestA); err != nil {
		t.Fatal(err)
	}
	if ev := <-ch; ev.Type != "banned" {
		t.Fatalf("got %+v", ev)
	}
	if err := h.FromGuest(code, msg("vote", guestA)); !errors.Is(err, ErrBanned) {
		t.Fatalf("want banned, got %v", err)
	}
	if _, _, err := h.SubscribeGuest(code, guestA); !errors.Is(err, ErrBanned) {
		t.Fatalf("want banned on resubscribe, got %v", err)
	}
}

func TestGCKeepsConnectedHost(t *testing.T) {
	h := NewHub(DefaultLimits)
	now := time.Unix(0, 0)
	h.now = func() time.Time { return now }
	idle, _ := h.Create()
	live, tok := h.Create()
	_, cancel, _ := h.SubscribeHost(live, tok)
	defer cancel()
	now = now.Add(13 * time.Hour)
	if n := h.GC(12 * time.Hour); n != 1 {
		t.Fatalf("dropped %d", n)
	}
	if _, err := h.get(idle); err == nil {
		t.Fatal("idle session survived")
	}
	if _, err := h.get(live); err != nil {
		t.Fatal("live session dropped")
	}
}

// End-to-end over HTTP: create → host stream → guest message reaches host →
// host snapshot reaches guest stream.
func TestHTTPRoundTrip(t *testing.T) {
	ts := httptest.NewServer(NewServer(NewHub(DefaultLimits), false))
	defer ts.Close()

	res, err := http.Post(ts.URL+"/api/sessions", "application/json", nil)
	if err != nil || res.StatusCode != http.StatusCreated {
		t.Fatalf("create: %v %v", err, res.Status)
	}
	var created struct{ Code, HostToken string }
	json.NewDecoder(res.Body).Decode(&created)
	base := ts.URL + "/api/sessions/" + created.Code

	hostReq, _ := http.NewRequest("GET", base+"/host/events", nil)
	hostReq.Header.Set("Authorization", "Bearer "+created.HostToken)
	hostRes, err := http.DefaultClient.Do(hostReq)
	if err != nil || hostRes.StatusCode != 200 {
		t.Fatalf("host events: %v", err)
	}
	defer hostRes.Body.Close()
	hostEvents := sseReader(hostRes)

	guestRes, err := http.Get(base + "/events?guest=" + guestA)
	if err != nil || guestRes.StatusCode != 200 {
		t.Fatalf("guest events: %v", err)
	}
	defer guestRes.Body.Close()
	guestEvents := sseReader(guestRes)

	r, _ := http.Post(base+"/messages", "application/json", strings.NewReader(string(msg("propose", guestA))))
	if r.StatusCode != http.StatusAccepted {
		t.Fatalf("message: %s", r.Status)
	}
	if typ, data := next(t, hostEvents); typ != "guest" || !strings.Contains(data, "propose") {
		t.Fatalf("host got %s %s", typ, data)
	}

	snapReq, _ := http.NewRequest("POST", base+"/host/snapshot", strings.NewReader("{\n \"queue\": []\n}"))
	snapReq.Header.Set("Authorization", "Bearer "+created.HostToken)
	if r, _ := http.DefaultClient.Do(snapReq); r.StatusCode != http.StatusNoContent {
		t.Fatalf("snapshot: %s", r.Status)
	}
	if typ, data := next(t, guestEvents); typ != "snapshot" || data != `{"queue":[]}` {
		t.Fatalf("guest got %s %q", typ, data)
	}

	if r, _ := http.Get(ts.URL + "/j/" + created.Code); r.StatusCode != 200 {
		t.Fatalf("guest page: %s", r.Status)
	}
}

type sseEvent struct{ typ, data string }

func sseReader(res *http.Response) <-chan sseEvent {
	out := make(chan sseEvent, 8)
	go func() {
		sc := bufio.NewScanner(res.Body)
		var ev sseEvent
		for sc.Scan() {
			line := sc.Text()
			switch {
			case strings.HasPrefix(line, "event: "):
				ev.typ = line[7:]
			case strings.HasPrefix(line, "data: "):
				ev.data = line[6:]
			case line == "" && ev.typ != "":
				out <- ev
				ev = sseEvent{}
			}
		}
		close(out)
	}()
	return out
}

func next(t *testing.T, ch <-chan sseEvent) (string, string) {
	t.Helper()
	select {
	case ev := <-ch:
		return ev.typ, ev.data
	case <-time.After(2 * time.Second):
		t.Fatal("timeout waiting for SSE event")
		return "", ""
	}
}
