const kLastFmApiKey = String.fromEnvironment('LASTFM_API_KEY');
const kGetSongBpmKey = String.fromEnvironment('GETSONGBPM_KEY');

// SoundCloud OAuth happens on the NAS token-proxy — the client secret never
// ships in the app. The app only fetches short-lived tokens from the proxy.
// See token-proxy/README.md.
const kTokenProxyUrl = String.fromEnvironment('TOKEN_PROXY_URL');
const kProxyApiKey = String.fromEnvironment('PROXY_API_KEY');

const kLastFmBaseUrl = 'https://ws.audioscrobbler.com/2.0/';
const kSoundCloudBaseUrl = 'https://api.soundcloud.com';
const kGetSongBpmBaseUrl = 'https://api.getsong.co';

const kGetSongBpmBacklinkUrl = 'https://getsongbpm.com';

const kJamendoClientId = String.fromEnvironment('JAMENDO_CLIENT_ID');
const kJamendoBaseUrl = 'https://api.jamendo.com/v3.0';
