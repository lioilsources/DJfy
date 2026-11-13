# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(djfy_decoder_library VERSION 0.0.1 LANGUAGES C)

add_library(djfy_decoder SHARED
  "djfy_decoder.c"
)

set_target_properties(djfy_decoder PROPERTIES
  PUBLIC_HEADER djfy_decoder.h
  OUTPUT_NAME "djfy_decoder"
)

target_compile_definitions(djfy_decoder PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(djfy_decoder PRIVATE "-Wl,-z,max-page-size=16384")
endif()
