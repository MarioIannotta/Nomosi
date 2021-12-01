Pod::Spec.new do |s|
  s.name             = 'Nomosi'
  s.version          = '0.1.9'
  s.summary          = 'Declarative plug and play network services for your iOS and macOS apps.'
  s.description      = <<-DESC
## Features

* Declarative functional syntax
* Type-safe by design
* Easy to decorate (eg: token refresh) and/or invalidate requests
* Straightforward cache configuration with the layer of your choice (URLCache by default) 
* Discard invalid or redundant requests
* Mock support
* Develop and attach thirdy part components
* Prebaked UI Components (by adding Nomosi/UI)
                       DESC
  s.swift_version = '5'
  s.homepage         = 'https://github.com/MarioIannotta/Nomosi'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MarioIannotta' => 'info@marioiannotta.com' }
  s.source           = { :git => 'https://github.com/MarioIannotta/Nomosi.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MarioIannotta'
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target  = '10.15'
  
  s.subspec 'All' do |s|
      s.dependency 'Nomosi/Core'
      s.dependency 'Nomosi/UI'
      s.dependency 'Nomosi/CoreDataCache'
  end
  
  s.subspec 'Core' do |s|
      s.source_files = 'Nomosi/Core/**/*'
      s.exclude_files = 'Nomosi/UI/**/*'
  end
  
  s.subspec 'UI' do |s|
      s.ios.source_files = 'Nomosi/UI/**/*'
      s.dependency 'Nomosi/Core'
  end
  
  s.subspec 'CoreDataCache' do |s|
      s.ios.source_files = 'Nomosi/CoreDataCache/**/*.swift'
      s.dependency 'Nomosi/Core'
      s.resource_bundles = { 'CoreDataCache' => ['Nomosi/CoreDataCache/Resources/*.xcdatamodeld'] }
  end
  
  s.default_subspecs = 'All'
  
end
