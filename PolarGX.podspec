Pod::Spec.new do |s|
      s.name                = "PolarGX"
      s.module_name         = "PolarGX"
      s.version             = "3.2.0"
      s.summary             = "PolarGX"

      s.description         = <<-DESC
                            PolarGX SDK
                            DESC

      s.homepage            = "https://www.polargx.com"
      s.license             = "MIT"
      s.author              = { "Bohemian Innovation LLC" => "ift@bohemian.cc" }

      s.platform            = :ios, "15.0"
      s.source              = { :git => "git@github.com:polargx/polargx-swift-sdk.git", :tag => s.version }

      s.pod_target_xcconfig = {
            'SWIFT_VERSION' => '5.3'
      }

      s.swift_version       = '5.3'

      s.default_subspec     = 'Core'

      # Main SDK for the app (includes shared Core folder)
      s.subspec 'Core' do |core|
            core.source_files = "PolarGX-SDK/Classes/**/*.{h,m,swift}", "PolarGX-SDK/Core/**/*.{swift}"
            core.resource_bundles = {'Resources' => 'PolarGX-SDK/Resources/**/*.{storyboard,xib,xcassets,xcdatamodeld}' }
      end

      # Lightweight SDK for NotificationServiceExtension (includes shared Core folder)
      s.subspec 'NotificationServiceExtension' do |ext|
            ext.source_files = "PolarGX-SDK/PolarGX-NotificationServiceExtension/**/*.{swift}", "PolarGX-SDK/Core/**/*.{swift}"
      end

      s.header_dir          = 'PolarGX'
end
