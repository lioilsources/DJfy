# djfy_decoder

Whole-file MP3 → interleaved 16-bit PCM for DJfy's scratch decks, via
[dr_mp3](https://github.com/mackron/dr_libs) (public domain / MIT-0, pinned in
`src/dr_mp3.COMMIT`). The PCM stays in native memory and is freed by a
finalizer; decoding runs in a background isolate.
