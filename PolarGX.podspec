Pod::Spec.new do |spec|
  spec.name             = "PolarGX"
  spec.version          = "0.1.0"
  spec.summary          = "PolarGX"
  spec.description      = "PolarGX SDK"

  spec.homepage         = "https://www.polargx.com"

  spec.license          = "MIT"
  spec.author           = { "Bohemian Innovation LLC" => "ift@bohemian.cc" }

  spec.ios.deployment_target = "15.0"
  spec.swift_version    = '5.0'
  
  spec.source           = { :git => "git@github.com:infinitech-dev/LinkAttribution-SwiftSDK.git", :tag => "#{spec.version}" }

  spec.source_files     = 'PolarGX/Classes/**/*'
  spec.resources        = 'PolarGX/Resources/**/*'

end
