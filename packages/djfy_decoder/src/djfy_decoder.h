#include <stddef.h>
#include <stdint.h>

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

// Decodes a whole MP3 file to interleaved 16-bit PCM. Returns NULL when the
// data isn't a decodable MP3. Free the result with djfy_free. Slow (about a
// second per track): call it off the main isolate.
FFI_PLUGIN_EXPORT int16_t* djfy_decode_mp3(const uint8_t* data, size_t size, uint32_t* channels,
                                           uint32_t* sample_rate, uint64_t* frames);

FFI_PLUGIN_EXPORT void djfy_free(void* pcm);
