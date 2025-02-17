Pod::Spec.new do |spec|
  spec.name             = "LinkAttribution"
  spec.version          = "0.1.0"
  spec.summary          = "LinkAttribution"
  spec.description      = "LinkAttribution"

  spec.homepage         = "https://github.com/infinitech-dev/LinkAttribution-SwiftSDK"

  spec.license          = "MIT"
  spec.author           = { "Bohemian Innovation LLC" => "ift@bohemian.cc" }

  spec.ios.deployment_target = "15.0"
  spec.swift_version    = '5.0'
  
  spec.source           = { :git => "git@github.com:infinitech-dev/LinkAttribution-SwiftSDK.git", :tag => "#{spec.version}" }

  spec.source_files     = 'LinkAttributionSDK/Classes/**/*'
  spec.resources        = 'LinkAttributionSDK/Resources/**/*'

end
