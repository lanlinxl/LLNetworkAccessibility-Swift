
Pod::Spec.new do |s|
  s.name             = 'LLNetworkAccessibility-Swift'
  s.version          = '1.0.0'
  s.summary          = 'network authorization'

  s.description      = 'network authorization'

  s.homepage         = 'https://github.com/lanlinxl/LLNetworkAccessibility-Swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lanlinxl' => 'lanlin0806@icloud.com' }
  s.source           = { :git => 'https://github.com/lanlinxl/LLNetworkAccessibility-Swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'LLNetworkAccessibility-Swift/Classes/**/*'
  s.resource = 'LLNetworkAccessibility-Swift/LLNetworkAccessibility.bundle'
#  s.resource_bundles = {
#      'LLNetworkAccessibility-Swift' => ['LLNetworkAccessibility-Swift/Assets/*']
#    }
  s.swift_version = '5.0'

end
