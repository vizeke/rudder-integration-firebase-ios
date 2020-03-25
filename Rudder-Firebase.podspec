Pod::Spec.new do |s|
  s.name             = 'Rudder-Firebase'
  s.version          = '0.1.0-beta.2'
  s.summary          = 'Privacy and Security focused Segment-alternative. Firebase Native SDK integration support.'

  s.description      = <<-DESC
  Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC
  s.homepage         = 'https://github.com/rudderlabs/rudder-integration-firebase-ios'
  s.license          = { :type => "Apache", :file => "LICENSE" }
  s.author           = { 'RudderStack' => 'arnab@rudderlabs.com' }
  s.source           = { :git => 'https://github.com/rudderlabs/rudder-integration-firebase-ios.git' , :commit => 'ecc135d501c76874ab88144b0ec5b29dc7615a3a'}
  s.platform         = :ios, "9.0"
  s.requires_arc = true

  s.ios.deployment_target = '8.0'
                     
  s.source_files = 'Rudder-Firebase/Classes/**/*'

  s.static_framework = true
  
  s.dependency 'Rudder', '1.0.1-beta.4'
  s.dependency 'Firebase/Core'
  s.dependency 'FirebaseAnalytics'
end
