#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_google_places_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_google_places_plus'
  s.version          = '0.9.0'
  s.summary          = 'Modern Flutter plugin for Google Places SDK using latest native Swift and Kotlin.'
  s.description      = <<-DESC
Modern Flutter plugin for Google Places SDK built from scratch on top of the latest native Places SDK for Android (Kotlin) and Places SDK for iOS (Swift), supporting iOS Swift Package Manager (SPM).
                       DESC
  s.homepage         = 'https://github.com/gmedia/flutter_google_places_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Gmedia' => 'dev@gmedia.co.id' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_google_places_plus/Sources/flutter_google_places_plus/**/*'
  s.dependency 'Flutter'
  s.dependency 'GooglePlacesSwift', '~> 11.2'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_google_places_plus_privacy' => ['flutter_google_places_plus/Sources/flutter_google_places_plus/PrivacyInfo.xcprivacy']}
end
