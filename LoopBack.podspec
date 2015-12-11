Pod::Spec.new do |s|
  s.name     = 'LoopBack'
  s.version  = '1.3.0'
  s.license  = { :type=> 'MIT & StrongLoop', :file=>'LICENSE' }
  s.summary  = 'iOS SDK for LoopBack.'
  s.homepage = 'https://github.com/strongloop/loopback-ios'
  s.authors  = { 'StrongLoop' => 'callback@strongloop.com' }
  s.source   = { :git => 'https://github.com/strongloop/loopback-sdk-ios.git', :tag => '1.3.0' }
  s.source_files = 'LoopBack/*.{h,m}', 'SLRemoting/*.{h,m}', 'SLAFNetworking/*.{h,m}'
  s.requires_arc = true

  s.ios.deployment_target = '6.1'
  s.ios.frameworks = 'UIKit', 'Foundation', 'MobileCoreServices', 'SystemConfiguration', 'CoreLocation'

end
