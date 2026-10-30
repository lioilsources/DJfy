package main

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"math/big"
	"sync"
	"time"
)

// The relay never owns party state: the host phone is the authority. It only
// forwards guest messages to the host, fans host snapshots out to guests and
// caches the last snapshot so guests can join while the host blips offline.

const (
	codeAlphabet   = "ABCDEFGHJKMNPQRSTUVWXYZ23456789" // no 0/O, 1/I/L
	codeLength     = 4
	subBuffer      = 32
	hostBacklogMax = 200
)

var (
	ErrNotFound    = errors.New("session not found")
	ErrForbidden   = errors.New("forbidden")
	ErrBanned      = errors.New("banned")
	ErrRateLimited = errors.New("rate limited")
	ErrBadMessage  = errors.New("bad message")
)

// Event is one SSE frame.
type Event struct {
	Type string
	Data []byte
}

// Limits holds the per-guest sliding windows enforced before anything reaches
// the host.
type Limits struct {
	ProposalsPer10Min int
	SearchesPerMin    int
	VotesPerMin       int
}

var DefaultLimits = Limits{ProposalsPer10Min: 5, SearchesPerMin: 30, VotesPerMin: 60}

type rateWindow struct {
	window time.Duration
	max    int
}

type session struct {
	code      string
	hostToken string

	mu         sync.Mutex
	snapshot   json.RawMessage
	hostSubs   map[chan Event]struct{}
	guestSubs  map[string]map[chan Event]struct{}
	backlog    []Event // guest messages queued while no host is connected
	banned     map[string]bool
	hits       map[string][]time.Time // "<kind>:<guestId>" → timestamps
	lastActive time.Time
	ended      bool
}

type Hub struct {
	mu       sync.Mutex
	sessions map[string]*session
	limits   Limits
	now      func() time.Time
}

func NewHub(limits Limits) *Hub {
	return &Hub{sessions: map[string]*session{}, limits: limits, now: time.Now}
}

func randomCode() string {
	b := make([]byte, codeLength)
	for i := range b {
		n, _ := rand.Int(rand.Reader, big.NewInt(int64(len(codeAlphabet))))
		b[i] = codeAlphabet[n.Int64()]
	}
	return string(b)
}

func randomToken() string {
	b := make([]byte, 16)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

// Create opens a new session and returns its join code and host token.
func (h *Hub) Create() (code, token string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	for {
		code = randomCode()
		if _, taken := h.sessions[code]; !taken {
			break
		}
	}
	token = randomToken()
	h.sessions[code] = &session{
		code:       code,
		hostToken:  token,
		hostSubs:   map[chan Event]struct{}{},
		guestSubs:  map[string]map[chan Event]struct{}{},
		banned:     map[string]bool{},
		hits:       map[string][]time.Time{},
		lastActive: h.now(),
	}
	return code, token
}

func (h *Hub) get(code string) (*session, error) {
	h.mu.Lock()
	defer h.mu.Unlock()
	s, ok := h.sessions[code]
	if !ok {
		return nil, ErrNotFound
	}
	return s, nil
}

func (h *Hub) host(code, token string) (*session, error) {
	s, err := h.get(code)
	if err != nil {
		return nil, err
	}
	if token == "" || token != s.hostToken {
		return nil, ErrForbidden
	}
	return s, nil
}

// Snapshot returns the cached host snapshot (nil if the host never sent one).
func (h *Hub) Snapshot(code string) (json.RawMessage, error) {
	s, err := h.get(code)
	if err != nil {
		return nil, err
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.snapshot, nil
}

// PublishSnapshot caches the host's state and broadcasts it to all guests.
func (h *Hub) PublishSnapshot(code, token string, snap json.RawMessage) error {
	s, err := h.host(code, token)
	if err != nil {
		return err
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	s.snapshot = snap
	s.lastActive = h.now()
	ev := Event{Type: "snapshot", Data: snap}
	for _, subs := range s.guestSubs {
		for ch := range subs {
			send(ch, ev)
		}
	}
	return nil
}

// SendToGuest delivers a private host → guest message (search results, toasts).
func (h *Hub) SendToGuest(code, token, guestID string, data json.RawMessage) error {
	s, err := h.host(code, token)
	if err != nil {
		return err
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	s.lastActive = h.now()
	for ch := range s.guestSubs[guestID] {
		send(ch, Event{Type: "private", Data: data})
	}
	return nil
}

// Ban blocks a guest at the relay and closes their streams.
func (h *Hub) Ban(code, token, guestID string) error {
	s, err := h.host(code, token)
	if err != nil {
		return err
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	s.banned[guestID] = true
	for ch := range s.guestSubs[guestID] {
		send(ch, Event{Type: "banned", Data: []byte(`{}`)})
	}
	return nil
}

// End closes the session for everyone.
func (h *Hub) End(code, token string) error {
	s, err := h.host(code, token)
	if err != nil {
		return err
	}
	h.mu.Lock()
	delete(h.sessions, code)
	h.mu.Unlock()
	s.close()
	return nil
}

func (s *session) close() {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.ended = true
	for _, subs := range s.guestSubs {
		for ch := range subs {
			send(ch, Event{Type: "ended", Data: []byte(`{}`)})
			close(ch)
		}
	}
	for ch := range s.hostSubs {
		close(ch)
	}
	s.guestSubs = map[string]map[chan Event]struct{}{}
	s.hostSubs = map[chan Event]struct{}{}
}

// GuestMessage is what a guest may POST. Payload fields are passed through to
// the host untouched; the relay only looks at type and identity.
type GuestMessage struct {
	Type    string `json:"type"`
	GuestID string `json:"guestId"`
	Name    string `json:"name"`
}

var guestTypes = map[string]bool{"join": true, "propose": true, "vote": true, "veto": true, "search": true}

func validGuestID(id string) bool {
	if len(id) < 8 || len(id) > 40 {
		return false
	}
	for _, c := range id {
		ok := c == '-' || c == '_' || (c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
		if !ok {
			return false
		}
	}
	return true
}

// FromGuest validates, rate-limits and forwards a guest message to the host.
// While no host is connected, messages are queued (bounded) and flushed on
// the host's next connect.
func (h *Hub) FromGuest(code string, raw []byte) error {
	var msg GuestMessage
	if err := json.Unmarshal(raw, &msg); err != nil || !guestTypes[msg.Type] || !validGuestID(msg.GuestID) {
		return ErrBadMessage
	}
	if len([]rune(msg.Name)) > 32 {
		return ErrBadMessage
	}
	s, err := h.get(code)
	if err != nil {
		return err
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.banned[msg.GuestID] {
		return ErrBanned
	}
	if w, limited := h.window(msg.Type); limited {
		key := msg.Type + ":" + msg.GuestID
		now := h.now()
		kept := s.hits[key][:0]
		for _, t := range s.hits[key] {
			if now.Sub(t) < w.window {
				kept = append(kept, t)
			}
		}
		if len(kept) >= w.max {
			s.hits[key] = kept
			return ErrRateLimited
		}
		s.hits[key] = append(kept, now)
	}
	s.lastActive = h.now()
	ev := Event{Type: "guest", Data: raw}
	if len(s.hostSubs) == 0 {
		if len(s.backlog) >= hostBacklogMax {
			s.backlog = s.backlog[1:]
		}
		s.backlog = append(s.backlog, ev)
		return nil
	}
	for ch := range s.hostSubs {
		send(ch, ev)
	}
	return nil
}

func (h *Hub) window(kind string) (rateWindow, bool) {
	switch kind {
	case "propose":
		return rateWindow{10 * time.Minute, h.limits.ProposalsPer10Min}, true
	case "search":
		return rateWindow{time.Minute, h.limits.SearchesPerMin}, true
	case "vote", "veto":
		return rateWindow{time.Minute, h.limits.VotesPerMin}, true
	}
	return rateWindow{}, false
}

// SubscribeHost opens the host's event stream, flushing any queued guest
// messages first. The returned cancel func must be called on disconnect.
func (h *Hub) SubscribeHost(code, token string) (<-chan Event, func(), error) {
	s, err := h.host(code, token)
	if err != nil {
		return nil, nil, err
	}
	ch := make(chan Event, subBuffer+hostBacklogMax)
	s.mu.Lock()
	for _, ev := range s.backlog {
		ch <- ev
	}
	s.backlog = nil
	s.hostSubs[ch] = struct{}{}
	s.lastActive = h.now()
	s.mu.Unlock()
	return ch, func() {
		s.mu.Lock()
		defer s.mu.Unlock()
		if _, ok := s.hostSubs[ch]; ok {
			delete(s.hostSubs, ch)
			close(ch)
		}
	}, nil
}

// SubscribeGuest opens a guest's event stream, starting with the cached
// snapshot so a late joiner sees the party immediately.
func (h *Hub) SubscribeGuest(code, guestID string) (<-chan Event, func(), error) {
	if !validGuestID(guestID) {
		return nil, nil, ErrBadMessage
	}
	s, err := h.get(code)
	if err != nil {
		return nil, nil, err
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.banned[guestID] {
		return nil, nil, ErrBanned
	}
	ch := make(chan Event, subBuffer)
	if s.snapshot != nil {
		ch <- Event{Type: "snapshot", Data: s.snapshot}
	}
	if s.guestSubs[guestID] == nil {
		s.guestSubs[guestID] = map[chan Event]struct{}{}
	}
	s.guestSubs[guestID][ch] = struct{}{}
	return ch, func() {
		s.mu.Lock()
		defer s.mu.Unlock()
		if subs := s.guestSubs[guestID]; subs != nil {
			if _, ok := subs[ch]; ok {
				delete(subs, ch)
				close(ch)
			}
			if len(subs) == 0 {
				delete(s.guestSubs, guestID)
			}
		}
	}, nil
}

// HostOnline reports whether the host currently holds an event stream.
func (h *Hub) HostOnline(code string) bool {
	s, err := h.get(code)
	if err != nil {
		return false
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	return len(s.hostSubs) > 0
}

// GC drops sessions idle for longer than ttl.
func (h *Hub) GC(ttl time.Duration) int {
	h.mu.Lock()
	var stale []*session
	for code, s := range h.sessions {
		s.mu.Lock()
		idle := h.now().Sub(s.lastActive) > ttl && len(s.hostSubs) == 0
		s.mu.Unlock()
		if idle {
			stale = append(stale, s)
			delete(h.sessions, code)
		}
	}
	h.mu.Unlock()
	for _, s := range stale {
		s.close()
	}
	return len(stale)
}

// send never blocks: a slow subscriber loses frames rather than stalling the
// party. Snapshots are full state, so the next one heals any gap.
func send(ch chan Event, ev Event) {
	select {
	case ch <- ev:
	default:
	}
}
