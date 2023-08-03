# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'whatsAppClone' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  # Pods for whatsAppClone
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'
  pod 'GoogleMaps'
  pod 'JGProgressHUD','~>2.0.3'
  pod 'SDWebImage', '~>4.4.2'
  pod 'ImageSlideshow', '~> 1.9.0'
  pod 'SwiftAudioPlayer'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
