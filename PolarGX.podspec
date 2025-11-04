Pod::Spec.new do |s|
      s.name                = "PolarGX"
      s.module_name         = "PolarGX"
      s.version             = "3.0.3"
      s.summary             = "PolarGX"

      s.description         = <<-DESC
                            PolarGX SDK
                            DESC

      s.homepage            = "https://www.polargx.com"
      s.license             = "MIT"
      s.author              = { "Bohemian Innovation LLC" => "ift@bohemian.cc" }

      s.platform            = :ios, "15.0"
      s.source              = { :git => "git@github.com:polargx/polargx-swift-sdk.git", :tag => s.version }
      s.source_files        = "PolarGX-SDK/Classes/**/*.{h,m,swift}"
      
      s.pod_target_xcconfig = {
            'SWIFT_VERSION' => '5.3'
      }

      s.swift_version       = '5.3'

      s.resource_bundles    = {'Resources' => 'PolarGX-SDK/Resources/**/*.{storyboard,xib,xcassets,xcdatamodeld}' }

      s.header_dir          = 'PolarGX'
end
