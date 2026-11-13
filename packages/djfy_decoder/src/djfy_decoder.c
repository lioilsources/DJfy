#include "djfy_decoder.h"

#define DR_MP3_IMPLEMENTATION
#include "dr_mp3.h"

FFI_PLUGIN_EXPORT int16_t* djfy_decode_mp3(const uint8_t* data, size_t size, uint32_t* channels,
                                           uint32_t* sample_rate, uint64_t* frames) {
  drmp3_config config;
  drmp3_uint64 count = 0;
  drmp3_int16* pcm = drmp3_open_memory_and_read_pcm_frames_s16(data, size, &config, &count, NULL);
  if (pcm == NULL || count == 0) {
    drmp3_free(pcm, NULL);
    return NULL;
  }
  *channels = config.channels;
  *sample_rate = config.sampleRate;
  *frames = count;
  return pcm;
}

FFI_PLUGIN_EXPORT void djfy_free(void* pcm) { drmp3_free(pcm, NULL); }
