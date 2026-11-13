#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint djfy_decoder.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'djfy_decoder'
  s.version          = '0.0.1'
  s.summary          = 'MP3 decoding for DJfy (dr_mp3 via FFI).'
  s.description      = <<-DESC
Whole-file MP3 decoding to 16-bit PCM (dr_mp3 via FFI).
                       DESC
  s.homepage         = 'https://github.com/lioilsources/DJfy'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'DJfy' => 'oldrich.vorechovsky.jr@gmail.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
