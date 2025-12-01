# PolarGX iOS SDK Installation Guide

A complete guide for integrating **PolarGX SDK** into your **Swift** or **Objective‑C** iOS app.

### 1. Create Polar project:
[TABS:Admin Portal:sdks/ios/ios-create-project.md]

### 2. Configure Xcode project

[TABS:Xcode project:sdks/ios/ios-configure-xcodeproject.md]

### 3. Add PolarGX SDK

[TABS:Swift Package Manager:sdks/ios/ios-spm.md,CocoaPods:sdks/ios/ios-cocoapods.md]


### 4. Using PolarGX SDK

[TABS:Using the SDK in Swift:sdks/ios/ios-swift.md,Using the SDK in Objective-C:sdks/ios/ios-objectivec.md]

### 5. Push Notifications

PolarGX SDK supports push notifications via **APNS** (Apple Push Notification Service) and **GCM/FCM** (Google Cloud Messaging / Firebase Cloud Messaging). The SDK automatically registers and manages push tokens for your users.

#### 5.1. Configure Push Service

[TABS:APNS:sdks/ios/ios-push-apns-configuration.md,GCM:sdks/ios/ios-push-gcm-configuration.md]

**Note**: _You can create multiple push services for different environments (e.g., one for Production and one for Development). Each service should have a unique Service Name and appropriate configuration._

#### 5.2. Configure PolarGX SDK for Push Notifications

[TABS:APNS with Swift:sdks/ios/ios-push-apns-swift.md,APNS with Objective-C:sdks/ios/ios-push-apns-objectivec.md,GCM with Swift:sdks/ios/ios-push-gcm-swift.md,GCM with Objective-C:sdks/ios/ios-push-gcm-objectivec.md]
