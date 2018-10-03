Pod::Spec.new do |s|
  s.name             = 'Nomosi'
  s.version          = '0.0.2'
  s.summary          = 'Plug and play network services for your iOS app.'
  s.description      = <<-DESC
Plug and play network services for your iOS app.
                       DESC
  s.swift_version = '4.2'
  s.homepage         = 'https://github.com/MarioIannotta/Nomosi'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MarioIannotta' => 'info@marioiannotta.com' }
  s.source           = { :git => 'https://github.com/MarioIannotta/Nomosi.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MarioIannotta'
  s.ios.deployment_target = '9.0'
  
  s.subspec 'All' do |s|
      s.dependency 'Nomosi/Core'
      s.dependency 'Nomosi/UI'
  end
  
  s.subspec 'Core' do |s|
      s.source_files = 'Nomosi/Core/**/*'
      s.exclude_files = 'Nomosi/UI/**/*'
  end
  
  s.subspec 'UI' do |s|
      s.ios.source_files = 'Nomosi/UI/**/*'
      s.dependency 'Nomosi/Core'
  end
  
  s.default_subspecs = 'All'
  
end
