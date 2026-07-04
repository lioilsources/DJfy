// Command dj-token-proxy is a tiny server that holds the SoundCloud client
// credentials and hands the DJfy app short-lived access tokens.
//
// The client_secret never leaves this process, so it is never compiled into
// the mobile app and cannot be extracted from a release artifact. The app only
// ships a PROXY_API_KEY, which merely grants access to this proxy and can be
// rotated/rate-limited independently.
package main

import (
	"context"
	"crypto/subtle"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"strings"
	"sync"
	"syscall"
	"time"
)

const defaultTokenURL = "https://api.soundcloud.com/oauth2/token"

type config struct {
	clientID     string
	clientSecret string
	proxyKey     string
	listenAddr   string
	tokenURL     string
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func loadConfig() (config, error) {
	c := config{
		clientID:     os.Getenv("SC_CLIENT_ID"),
		clientSecret: os.Getenv("SC_CLIENT_SECRET"),
		proxyKey:     os.Getenv("PROXY_API_KEY"),
		listenAddr:   getenv("LISTEN_ADDR", ":8080"),
		tokenURL:     getenv("SC_TOKEN_URL", defaultTokenURL),
	}
	var missing []string
	if c.clientID == "" {
		missing = append(missing, "SC_CLIENT_ID")
	}
	if c.clientSecret == "" {
		missing = append(missing, "SC_CLIENT_SECRET")
	}
	if c.proxyKey == "" {
		missing = append(missing, "PROXY_API_KEY")
	}
	if len(missing) > 0 {
		return c, fmt.Errorf("missing required env: %s", strings.Join(missing, ", "))
	}
	return c, nil
}

type scToken struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   int    `json:"expires_in"`
}

// tokenManager mints and caches a SoundCloud client_credentials token,
// refreshing it before expiry. Concurrent callers share one cached token.
type tokenManager struct {
	cfg    config
	client *http.Client

	mu      sync.Mutex
	token   string
	expires time.Time
}

func (m *tokenManager) get(ctx context.Context) (scToken, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	// Serve the cached token while it has comfortable life left.
	if remaining := time.Until(m.expires); m.token != "" && remaining > 90*time.Second {
		return scToken{AccessToken: m.token, ExpiresIn: int(remaining.Seconds())}, nil
	}

	form := url.Values{
		"grant_type":    {"client_credentials"},
		"client_id":     {m.cfg.clientID},
		"client_secret": {m.cfg.clientSecret},
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, m.cfg.tokenURL, strings.NewReader(form.Encode()))
	if err != nil {
		return scToken{}, err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("Accept", "application/json; charset=utf-8")

	resp, err := m.client.Do(req)
	if err != nil {
		return scToken{}, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
		return scToken{}, fmt.Errorf("soundcloud token endpoint %d: %s", resp.StatusCode, strings.TrimSpace(string(body)))
	}

	var tok scToken
	if err := json.NewDecoder(resp.Body).Decode(&tok); err != nil {
		return scToken{}, fmt.Errorf("decode token response: %w", err)
	}
	if tok.AccessToken == "" {
		return scToken{}, errors.New("soundcloud returned empty access_token")
	}
	if tok.ExpiresIn <= 0 {
		tok.ExpiresIn = 3600
	}

	m.token = tok.AccessToken
	m.expires = time.Now().Add(time.Duration(tok.ExpiresIn) * time.Second)
	log.Printf("minted new SoundCloud token, expires in %ds", tok.ExpiresIn)

	// Hand the client a shorter TTL than ours so it refreshes before we expire.
	clientTTL := tok.ExpiresIn - 120
	if clientTTL < 60 {
		clientTTL = 60
	}
	return scToken{AccessToken: tok.AccessToken, ExpiresIn: clientTTL}, nil
}

// authorized checks the shared proxy key from either X-Proxy-Key or a
// "Authorization: Bearer <key>" header, using a constant-time comparison.
func authorized(r *http.Request, key string) bool {
	presented := r.Header.Get("X-Proxy-Key")
	if presented == "" {
		if h := r.Header.Get("Authorization"); strings.HasPrefix(h, "Bearer ") {
			presented = strings.TrimPrefix(h, "Bearer ")
		}
	}
	if presented == "" {
		return false
	}
	return subtle.ConstantTimeCompare([]byte(presented), []byte(key)) == 1
}

func main() {
	healthcheck := flag.Bool("healthcheck", false, "probe /healthz on the configured port and exit 0/1")
	flag.Parse()
	if *healthcheck {
		os.Exit(runHealthcheck())
	}

	cfg, err := loadConfig()
	if err != nil {
		log.Fatalf("config: %v", err)
	}

	tm := &tokenManager{
		cfg:    cfg,
		client: &http.Client{Timeout: 15 * time.Second},
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		io.WriteString(w, "ok")
	})
	mux.HandleFunc("/sc/token", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		if !authorized(r, cfg.proxyKey) {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		ctx, cancel := context.WithTimeout(r.Context(), 20*time.Second)
		defer cancel()

		tok, err := tm.get(ctx)
		if err != nil {
			log.Printf("token fetch failed: %v", err)
			http.Error(w, "upstream token error", http.StatusBadGateway)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Cache-Control", "no-store")
		_ = json.NewEncoder(w).Encode(tok)
	})

	srv := &http.Server{
		Addr:              cfg.listenAddr,
		Handler:           withLogging(mux),
		ReadHeaderTimeout: 10 * time.Second,
	}

	go func() {
		log.Printf("dj-token-proxy listening on %s", cfg.listenAddr)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("server: %v", err)
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop

	log.Println("shutting down…")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_ = srv.Shutdown(ctx)
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.status = code
	r.ResponseWriter.WriteHeader(code)
}

// withLogging logs method, path, status and latency only — never headers or
// bodies, so proxy keys and tokens stay out of the logs.
func withLogging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		start := time.Now()
		next.ServeHTTP(rec, r)
		log.Printf("%s %s %d %s", r.Method, r.URL.Path, rec.status, time.Since(start).Round(time.Millisecond))
	})
}

func runHealthcheck() int {
	addr := getenv("LISTEN_ADDR", ":8080")
	_, port, err := net.SplitHostPort(addr)
	if err != nil || port == "" {
		port = "8080"
	}
	client := &http.Client{Timeout: 3 * time.Second}
	resp, err := client.Get("http://127.0.0.1:" + port + "/healthz")
	if err != nil {
		return 1
	}
	defer resp.Body.Close()
	if resp.StatusCode == http.StatusOK {
		return 0
	}
	return 1
}
