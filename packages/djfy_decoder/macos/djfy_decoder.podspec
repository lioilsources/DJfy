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

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'djfy_decoder_privacy' => ['djfy_decoder/Sources/djfy_decoder/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
