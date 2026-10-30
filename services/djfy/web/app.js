// DJfy guest PWA. The host phone owns the party; this page only shows its
// snapshot and sends join / search / propose / vote / veto messages through
// the relay. Everything user-supplied is rendered with textContent.
(() => {
  'use strict';

  const code = (location.pathname.split('/')[2] || '').toUpperCase();
  const api = `/api/sessions/${encodeURIComponent(code)}`;
  const $ = (id) => document.getElementById(id);
  const EMOJI = ['🎧', '🪩', '🕺', '💃', '🔥', '🦄', '🐸', '🍕', '🌈', '🚀', '🎸', '🥁', '🍹', '😎'];
  const OFFLINE_AFTER_MS = 35_000; // host republishes every 10 s

  const store = {
    get(k, d) { try { const v = localStorage.getItem(`djfy:${k}`); return v == null ? d : JSON.parse(v); } catch { return d; } },
    set(k, v) { try { localStorage.setItem(`djfy:${k}`, JSON.stringify(v)); } catch { /* private mode */ } },
  };

  const guestId = store.get('guestId', null) || (() => {
    const bytes = new Uint8Array(12);
    crypto.getRandomValues(bytes);
    const id = 'g-' + Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
    store.set('guestId', id);
    return id;
  })();

  let profile = store.get('profile', null); // { name, emoji }
  let snapshot = null;
  let myVotes = store.get(`votes:${code}`, {}); // entryId → 1 / -1
  let proposed = new Set();
  let pendingSearch = null;
  let es = null;

  const displayName = () => profile ? `${profile.emoji} ${profile.name || 'Host'}`.trim() : 'Host';

  // ── Relay I/O ──────────────────────────────────────────────────────────────

  async function send(type, payload = {}) {
    const res = await fetch(`${api}/messages`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type, guestId, name: displayName(), ...payload }),
    });
    if (res.status === 429) throw new Error(type === 'propose'
      ? 'Moc návrhů najednou – zkus to za pár minut'
      : 'Zpomal trochu 🙂');
    if (res.status === 403) { showGone('Hostitel tě zablokoval', 'Na tuhle party už nemůžeš.'); throw new Error('banned'); }
    if (res.status === 404) { showGone('Party nenalezena', 'Zkontroluj odkaz nebo naskenuj QR znovu.'); throw new Error('gone'); }
    if (!res.ok) throw new Error('Něco se pokazilo, zkus to znovu');
    return res.json();
  }

  function connect() {
    es = new EventSource(`${api}/events?guest=${encodeURIComponent(guestId)}`);
    es.addEventListener('snapshot', (e) => { snapshot = JSON.parse(e.data); render(); });
    es.addEventListener('private', (e) => onPrivate(JSON.parse(e.data)));
    es.addEventListener('banned', () => { es.close(); showGone('Hostitel tě zablokoval', 'Na tuhle party už nemůžeš.'); });
    es.addEventListener('ended', () => { es.close(); showGone('Party skončila', 'Díky, žes byl(a) u toho.'); });
    es.onerror = async () => {
      // EventSource retries on its own; just make sure the session still exists.
      if (es.readyState === EventSource.CLOSED) {
        const r = await fetch(api).catch(() => null);
        if (r && r.status === 404) showGone('Party nenalezena', 'Zkontroluj odkaz nebo naskenuj QR znovu.');
        else setTimeout(connect, 3000);
      }
      renderStatus();
    };
  }

  function onPrivate(msg) {
    if (msg.type === 'toast') toast(msg.text);
    if (msg.type === 'searchResults' && pendingSearch && msg.reqId === pendingSearch) {
      pendingSearch = null;
      renderResults(msg.results || []);
    }
  }

  // ── Rendering ──────────────────────────────────────────────────────────────

  function el(tag, props = {}, ...kids) {
    const n = document.createElement(tag);
    for (const [k, v] of Object.entries(props)) {
      if (k === 'class') n.className = v;
      else if (k === 'text') n.textContent = v;
      else if (k.startsWith('on')) n.addEventListener(k.slice(2), v);
      else n.setAttribute(k, v);
    }
    kids.flat().forEach((c) => c && n.append(c));
    return n;
  }

  function art(url, size) {
    const img = el('img', { class: 'art', width: size, height: size, alt: '', loading: 'lazy' });
    if (typeof url === 'string' && url.startsWith('https://')) img.src = url;
    return img;
  }

  function render() {
    if (!snapshot) return;
    $('party-name').textContent = snapshot.name || 'Party';
    document.title = `${snapshot.name || 'Party'} · DJfy`;
    renderStatus();
    renderNow();
    renderQueue();
  }

  function renderStatus() {
    const s = $('status');
    const stale = !snapshot || Date.now() - snapshot.updatedAt > OFFLINE_AFTER_MS;
    s.classList.toggle('off', stale);
    s.textContent = stale ? '● hostitel offline' : `● ${snapshot.guests || 1} na party`;
  }

  function renderNow() {
    const np = snapshot.nowPlaying;
    const img = $('now-art');
    img.removeAttribute('src');
    if (np && typeof np.artworkUrl === 'string' && np.artworkUrl.startsWith('https://')) img.src = np.artworkUrl;
    $('now-title').textContent = np ? np.title : 'Ticho před bouří';
    $('now-sub').textContent = np
      ? [np.artist, np.bpm && `${np.bpm} BPM`, np.proposedByName && `přidal(a) ${np.proposedByName}`].filter(Boolean).join(' · ')
      : 'Zatím nic nehraje';
    tickProgress();
  }

  function tickProgress() {
    const np = snapshot && snapshot.nowPlaying;
    let pct = 0;
    if (np && np.durationMs > 0) {
      const drift = snapshot.isPlaying ? Date.now() - snapshot.updatedAt : 0;
      pct = Math.min(100, ((np.positionMs + drift) / np.durationMs) * 100);
    }
    $('now-bar').style.width = `${pct}%`;
  }

  function renderQueue() {
    const list = $('queue');
    const q = snapshot.queue || [];
    const isCoDj = (snapshot.coDjs || []).includes(guestId);
    $('queue-empty').hidden = q.length > 0;
    const mood = $('mood');
    mood.hidden = !snapshot.moodLock;
    if (snapshot.moodLock) mood.textContent = `🔒 Mood lock ${snapshot.moodLock.minBpm}–${snapshot.moodLock.maxBpm} BPM`;

    list.replaceChildren(...q.map((e, i) => {
      const mine = myVotes[e.entryId] || 0;
      const vote = (v) => async () => {
        const next = mine === v ? 0 : v;
        try {
          await send('vote', { entryId: e.entryId, value: next });
          myVotes[e.entryId] = next;
          store.set(`votes:${code}`, myVotes);
          renderQueue();
        } catch (err) { toast(err.message); }
      };
      const sub = [e.track.artist, e.track.bpm && `${e.track.bpm} BPM`, e.proposedByName].filter(Boolean).join(' · ');
      return el('li', { class: `item${e.blocked ? ' blocked' : ''}` },
        el('span', { class: 'rank', text: e.pinned ? '📌' : String(i + 1) }),
        art(e.track.artworkUrl, 44),
        el('div', { class: 'meta' },
          el('div', { class: 'title', text: e.track.title }),
          el('div', { class: 'sub', text: sub }),
          e.reasons && e.reasons.length ? el('div', { class: 'why', text: e.reasons.join(' · ') }) : null,
          isCoDj ? el('button', {
            class: 'veto', text: 'veto',
            onclick: () => send('veto', { entryId: e.entryId }).catch((err) => toast(err.message)),
          }) : null),
        el('div', { class: 'votes' },
          el('button', { class: `vote up${mine > 0 ? ' on' : ''}`, 'aria-label': 'Palec nahoru', text: `👍 ${e.up}`, onclick: vote(1) }),
          el('button', { class: `vote down${mine < 0 ? ' on' : ''}`, 'aria-label': 'Palec dolů', text: `👎 ${e.down}`, onclick: vote(-1) })));
    }));
  }

  function renderResults(results) {
    $('search-hint').textContent = results.length ? '' : 'Nic jsme nenašli. Zkus jiný dotaz.';
    const queued = new Set((snapshot?.queue || []).map((e) => e.track.id));
    $('results').replaceChildren(...results.map((t) => {
      const done = queued.has(t.id) || proposed.has(t.id);
      const btn = el('button', { class: 'add', text: done ? '✓' : 'Navrhnout' });
      btn.disabled = proposed.has(t.id);
      btn.addEventListener('click', async () => {
        btn.disabled = true;
        try {
          await send('propose', { trackId: t.id });
          proposed.add(t.id);
          btn.textContent = '✓';
        } catch (err) {
          btn.disabled = false;
          toast(err.message);
        }
      });
      return el('li', { class: 'item' },
        art(t.artworkUrl, 44),
        el('div', { class: 'meta' },
          el('div', { class: 'title', text: t.title }),
          el('div', { class: 'sub', text: [t.artist, t.bpm && `${t.bpm} BPM`].filter(Boolean).join(' · ') })),
        btn);
    }));
  }

  let toastTimer;
  function toast(text) {
    const t = $('toast');
    t.textContent = text;
    t.hidden = false;
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => { t.hidden = true; }, 3500);
  }

  function show(id) {
    for (const s of document.querySelectorAll('.screen')) s.hidden = s.id !== id;
  }

  function showGone(title, text) {
    $('gone-title').textContent = title;
    $('gone-text').textContent = text;
    show('gone');
  }

  // ── Wiring ─────────────────────────────────────────────────────────────────

  function enterParty() {
    show('party');
    $('party-code').textContent = code;
    send('join').catch((err) => toast(err.message));
    connect();
    setInterval(() => { tickProgress(); renderStatus(); }, 1000);
  }

  document.querySelectorAll('.tabs button').forEach((b) => b.addEventListener('click', () => {
    document.querySelectorAll('.tabs button').forEach((x) => x.setAttribute('aria-selected', String(x === b)));
    $('tab-queue').hidden = b.dataset.tab !== 'queue';
    $('tab-search').hidden = b.dataset.tab !== 'search';
    if (b.dataset.tab === 'search') $('q').focus();
  }));

  $('search-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const q = $('q').value.trim();
    if (q.length < 2) return;
    pendingSearch = Math.random().toString(36).slice(2);
    $('search-hint').textContent = 'Hledám…';
    $('results').replaceChildren();
    const reqId = pendingSearch;
    try {
      const res = await send('search', { q, reqId });
      if (!res.hostOnline) $('search-hint').textContent = 'Hostitel je zrovna offline, výsledky dorazí, až se vrátí.';
    } catch (err) {
      $('search-hint').textContent = err.message;
      return;
    }
    setTimeout(() => {
      if (pendingSearch === reqId) $('search-hint').textContent = 'Hostitel neodpovídá. Zkus to znovu za chvíli.';
    }, 10_000);
  });

  let emoji = profile?.emoji || EMOJI[Math.floor(Math.random() * EMOJI.length)];
  $('emoji').textContent = emoji;
  $('emoji').addEventListener('click', () => {
    emoji = EMOJI[(EMOJI.indexOf(emoji) + 1) % EMOJI.length];
    $('emoji').textContent = emoji;
  });
  $('join-form').addEventListener('submit', (e) => {
    e.preventDefault();
    profile = { name: $('name').value.trim().slice(0, 24), emoji };
    store.set('profile', profile);
    enterParty();
  });

  if (!/^[A-Z0-9]{4}$/.test(code)) {
    showGone('Neplatný odkaz', 'Naskenuj QR kód od hostitele.');
  } else if (profile) {
    enterParty();
  } else {
    fetch(api).then((r) => {
      if (r.status === 404) return showGone('Party nenalezena', 'Zkontroluj odkaz nebo naskenuj QR znovu.');
      return r.json().then((s) => { if (s && s.name) $('join-title').textContent = s.name; show('join'); });
    }).catch(() => show('join'));
  }
})();
