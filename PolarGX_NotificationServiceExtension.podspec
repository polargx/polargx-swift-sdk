Pod::Spec.new do |s|
      s.name                = "PolarGX_NotificationServiceExtension"
      s.version             = "3.3.0"
      s.summary             = "PolarGX Notification Service Extension SDK"

      s.description         = <<-DESC
                            Lightweight SDK for Apple Push Notification Service Extensions.
                            Tracks push notification delivery and enables rich media attachments.
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

      # Extension SDK files (includes shared Core folder)
      s.source_files        = "PolarGX-SDK/PolarGX-NotificationServiceExtension/**/*.{swift}",
                              "PolarGX-SDK/Core/**/*.{swift}"
end
