// Command djfy is the DJfy party relay: sessions, guest proposals/votes and a
// snapshot cache. The host phone stays the source of truth.
package main

import (
	"bytes"
	"embed"
	"encoding/json"
	"errors"
	"io"
	"io/fs"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
)

//go:embed web
var webFS embed.FS

const (
	maxBody       = 256 << 10 // snapshots carry the whole queue
	maxGuestBody  = 4 << 10
	sseHeartbeat  = 20 * time.Second
	sessionTTL    = 12 * time.Hour
	createPerHour = 20
)

func main() {
	addr := envOr("DJFY_ADDR", ":8097")
	hub := NewHub(DefaultLimits)

	go func() {
		for range time.Tick(time.Minute) {
			if n := hub.GC(sessionTTL); n > 0 {
				log.Printf("gc: dropped %d idle sessions", n)
			}
		}
	}()

	srv := &http.Server{
		Addr:              addr,
		Handler:           NewServer(hub, os.Getenv("DJFY_TRUST_PROXY") == "1"),
		ReadHeaderTimeout: 10 * time.Second,
	}
	log.Printf("djfy relay listening on %s", addr)
	log.Fatal(srv.ListenAndServe())
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

type server struct {
	hub        *Hub
	trustProxy bool

	mu      sync.Mutex
	creates map[string][]time.Time
}

func NewServer(hub *Hub, trustProxy bool) http.Handler {
	s := &server{hub: hub, trustProxy: trustProxy, creates: map[string][]time.Time{}}
	static, _ := fs.Sub(webFS, "web")
	mux := http.NewServeMux()

	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) { io.WriteString(w, "ok") })
	mux.HandleFunc("POST /api/sessions", s.create)
	mux.HandleFunc("GET /api/sessions/{code}", s.snapshot)
	mux.HandleFunc("DELETE /api/sessions/{code}", s.end)
	mux.HandleFunc("GET /api/sessions/{code}/host/events", s.hostEvents)
	mux.HandleFunc("POST /api/sessions/{code}/host/snapshot", s.publish)
	mux.HandleFunc("POST /api/sessions/{code}/host/send", s.sendToGuest)
	mux.HandleFunc("POST /api/sessions/{code}/host/ban", s.ban)
	mux.HandleFunc("GET /api/sessions/{code}/events", s.guestEvents)
	mux.HandleFunc("POST /api/sessions/{code}/messages", s.guestMessage)

	mux.Handle("GET /static/", http.StripPrefix("/static/", http.FileServerFS(static)))
	mux.HandleFunc("GET /manifest.webmanifest", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/manifest+json")
		http.ServeFileFS(w, r, static, "manifest.webmanifest")
	})
	mux.HandleFunc("GET /j/{code}", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-cache")
		http.ServeFileFS(w, r, static, "index.html")
	})
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFileFS(w, r, static, "landing.html")
	})
	return mux
}

func code(r *http.Request) string { return strings.ToUpper(r.PathValue("code")) }

func bearer(r *http.Request) string {
	return strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")
}

func (s *server) clientIP(r *http.Request) string {
	if s.trustProxy {
		// Cloudflare overwrites CF-Connecting-IP; X-Forwarded-For only gets
		// appended to, so its first entry is whatever the client sent.
		if ip := r.Header.Get("CF-Connecting-IP"); ip != "" {
			return ip
		}
		if fwd := r.Header.Get("X-Forwarded-For"); fwd != "" {
			parts := strings.Split(fwd, ",")
			return strings.TrimSpace(parts[len(parts)-1])
		}
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

func (s *server) create(w http.ResponseWriter, r *http.Request) {
	ip := s.clientIP(r)
	now := time.Now()
	s.mu.Lock()
	kept := s.creates[ip][:0]
	for _, t := range s.creates[ip] {
		if now.Sub(t) < time.Hour {
			kept = append(kept, t)
		}
	}
	if len(kept) >= createPerHour {
		s.creates[ip] = kept
		s.mu.Unlock()
		writeErr(w, ErrRateLimited)
		return
	}
	s.creates[ip] = append(kept, now)
	s.mu.Unlock()

	c, token := s.hub.Create()
	writeJSON(w, http.StatusCreated, map[string]string{"code": c, "hostToken": token})
}

func (s *server) snapshot(w http.ResponseWriter, r *http.Request) {
	snap, err := s.hub.Snapshot(code(r))
	if err != nil {
		writeErr(w, err)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	if snap == nil {
		io.WriteString(w, "null")
		return
	}
	w.Write(snap)
}

func (s *server) end(w http.ResponseWriter, r *http.Request) {
	if err := s.hub.End(code(r), bearer(r)); err != nil {
		writeErr(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *server) publish(w http.ResponseWriter, r *http.Request) {
	body, ok := readJSON(w, r, maxBody)
	if !ok {
		return
	}
	if err := s.hub.PublishSnapshot(code(r), bearer(r), body); err != nil {
		writeErr(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *server) sendToGuest(w http.ResponseWriter, r *http.Request) {
	body, ok := readJSON(w, r, maxBody)
	if !ok {
		return
	}
	var req struct {
		GuestID string          `json:"guestId"`
		Data    json.RawMessage `json:"data"`
	}
	if err := json.Unmarshal(body, &req); err != nil || req.GuestID == "" || req.Data == nil {
		writeErr(w, ErrBadMessage)
		return
	}
	if err := s.hub.SendToGuest(code(r), bearer(r), req.GuestID, req.Data); err != nil {
		writeErr(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *server) ban(w http.ResponseWriter, r *http.Request) {
	body, ok := readJSON(w, r, maxGuestBody)
	if !ok {
		return
	}
	var req struct {
		GuestID string `json:"guestId"`
	}
	if err := json.Unmarshal(body, &req); err != nil || req.GuestID == "" {
		writeErr(w, ErrBadMessage)
		return
	}
	if err := s.hub.Ban(code(r), bearer(r), req.GuestID); err != nil {
		writeErr(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *server) guestMessage(w http.ResponseWriter, r *http.Request) {
	body, ok := readJSON(w, r, maxGuestBody)
	if !ok {
		return
	}
	if err := s.hub.FromGuest(code(r), body); err != nil {
		writeErr(w, err)
		return
	}
	writeJSON(w, http.StatusAccepted, map[string]bool{"hostOnline": s.hub.HostOnline(code(r))})
}

func (s *server) hostEvents(w http.ResponseWriter, r *http.Request) {
	ch, cancel, err := s.hub.SubscribeHost(code(r), bearer(r))
	if err != nil {
		writeErr(w, err)
		return
	}
	defer cancel()
	stream(w, r, ch)
}

func (s *server) guestEvents(w http.ResponseWriter, r *http.Request) {
	ch, cancel, err := s.hub.SubscribeGuest(code(r), r.URL.Query().Get("guest"))
	if err != nil {
		writeErr(w, err)
		return
	}
	defer cancel()
	stream(w, r, ch)
}

func stream(w http.ResponseWriter, r *http.Request, ch <-chan Event) {
	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming unsupported", http.StatusInternalServerError)
		return
	}
	h := w.Header()
	h.Set("Content-Type", "text/event-stream")
	h.Set("Cache-Control", "no-cache")
	h.Set("X-Accel-Buffering", "no") // nginx/caddy: don't buffer SSE
	io.WriteString(w, ": connected\n\n")
	flusher.Flush()

	tick := time.NewTicker(sseHeartbeat)
	defer tick.Stop()
	for {
		select {
		case <-r.Context().Done():
			return
		case <-tick.C:
			io.WriteString(w, ": ping\n\n")
			flusher.Flush()
		case ev, open := <-ch:
			if !open {
				return
			}
			io.WriteString(w, "event: "+ev.Type+"\ndata: ")
			w.Write(ev.Data)
			io.WriteString(w, "\n\n")
			flusher.Flush()
			if ev.Type == "banned" || ev.Type == "ended" {
				return
			}
		}
	}
}

// readJSON reads a bounded body and checks it is valid JSON. Snapshot data is
// re-emitted verbatim as a single SSE data line, which is safe because
// json.Compact strips every newline.
func readJSON(w http.ResponseWriter, r *http.Request, limit int64) (json.RawMessage, bool) {
	body, err := io.ReadAll(http.MaxBytesReader(w, r.Body, limit))
	if err != nil {
		http.Error(w, "body too large", http.StatusRequestEntityTooLarge)
		return nil, false
	}
	var compact bytes.Buffer
	if err := json.Compact(&compact, body); err != nil {
		writeErr(w, ErrBadMessage)
		return nil, false
	}
	return compact.Bytes(), true
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func writeErr(w http.ResponseWriter, err error) {
	status := http.StatusInternalServerError
	switch {
	case errors.Is(err, ErrNotFound):
		status = http.StatusNotFound
	case errors.Is(err, ErrForbidden):
		status = http.StatusUnauthorized
	case errors.Is(err, ErrBanned):
		status = http.StatusForbidden
	case errors.Is(err, ErrRateLimited):
		status = http.StatusTooManyRequests
	case errors.Is(err, ErrBadMessage):
		status = http.StatusBadRequest
	}
	writeJSON(w, status, map[string]string{"error": err.Error()})
}
