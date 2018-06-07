Pod::Spec.new do |s|
  s.name             = 'Nomosi'
  s.version          = '0.0.1'
  s.summary          = 'A protocol oriented way to handle network requests.'
  s.description      = <<-DESC
A protocol oriented way to handle network requests.
                       DESC
  s.swift_version = '4.1'
  s.homepage         = 'https://github.com/MarioIannotta/Nomosi'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MarioIannotta' => 'info@marioiannotta.com' }
  s.source           = { :git => 'https://github.com/MarioIannotta/Nomosi.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MarioIannotta'
  s.ios.deployment_target = '9.0'
  s.source_files = 'Nomosi/**/*.swift'
end