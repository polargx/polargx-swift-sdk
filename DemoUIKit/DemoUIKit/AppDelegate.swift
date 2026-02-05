//
//  AppDelegate.swift
//  DemoUIKit
//
//  Created by duyenlv on 20/1/25.
//

import UIKit
import PolarGX
import UserNotifications

//TODO: issue: the pushDevice is not sending at the time request notification and push token

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func verifyExtensionInstalled() {
        print("\n=== 🔍 Extension Installation Check ===")

        guard let appBundlePath = Bundle.main.bundlePath as String? else {
            print("❌ Cannot get app bundle path")
            return
        }

        let plugInsPath = (appBundlePath as NSString).appendingPathComponent("PlugIns")
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: plugInsPath) {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: plugInsPath)

                if contents.contains("DemoUIKit-NotificationService.appex") {
                    print("✅ Notification Service Extension IS INSTALLED")
                    print("   Extension will be triggered for notifications with 'mutable-content': 1")
                    print("   Notifications should show title with [edited] suffix")
                } else {
                    print("❌ Extension NOT FOUND in PlugIns!")
                    print("   Found: \(contents)")
                }
            } catch {
                print("❌ Error reading PlugIns: \(error)")
            }
        } else {
            print("❌ PlugIns folder does NOT exist - NO EXTENSIONS INSTALLED")
            print("   You need to rebuild and reinstall the app")
        }

        print("=== End Extension Check ===\n")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        regularInitialization()
        
        return true
    }
    
    func regularInitialization() {
        PolarSettings.appGroupIdentifier = "group.com.bohemian.polar.mobilesdktest"
        PolarSettings.isLoggingEnabled = true;

        // VERIFY: Check if notification service extension is installed
        verifyExtensionInstalled()

        PolarApp.initialize(appId: "1d5c7883-00ef-4b83-88b7-3ca6a7031f9b", apiKey: "dev_dZIqMUTVE945yyZFoUto48pRXOZHDqm940abQ4nd") { link, data, error in
            print("\n[DEMO] detect clicked: \(link), data: \(data), error: \(error)\n")
        }
        
        PolarApp.shared.updateUser(userID: "test-user-1", attributes: [
            PolarEventKey.Name: "DL",
            PolarEventKey.Email: "dl1@infinitech.dev"
        ])
        
        
        let center = UNUserNotificationCenter.current()
        center.delegate = PolarQuickIntegration.userNotificationCenterDelegateImpl
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
                return
            }
            
            if granted {
                print("Notification permissions granted")
                // Register for remote notifications on the main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permissions denied")
            }
        }
    }
    
    func testInitialization() {
        
        PolarSettings.isLoggingEnabled = true;
        PolarApp.initialize(appId: "40b59333-4350-4fc8-a59b-fdcab6bc0274", apiKey: "deb_HkP4KkjQ0i1z3t8BodVfPokPm5x3Qsm5JvrfUcKc") { link, data, error in
            print("\n[DEMO] detect clicked: \(link), data: \(data), error: \(error)\n")
        }
        
        UNUserNotificationCenter.current().delegate = PolarQuickIntegration.userNotificationCenterDelegateImpl;
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            DispatchQueue.main.async{
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
//        PolarApp.shared.updateUser(userID: "e1a3cb25-839e-4deb-95b0-2fb8ebd79401", attributes: [PolarEventKey.Name: "dl1", PolarEventKey.Email: "dl1@gmail.com"])
//        
        for i in 1...1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(i)/1, execute: {
                PolarApp.shared.updateUser(userID: "e1a3cb25-839e-4deb-95b0-2fb8ebd7941\(i)", attributes: [
                    PolarEventKey.Name: "dl2",
                    PolarEventKey.Email: "dl2@gmail.com",
                    "datap1": [
                        "datasub1": i,
                        "datasub2": false,
                        "datasub3": "hele",
                        "datasub4": UInt(3),
                        "datasub5": Float(5),
                        "datasub6": Decimal(1000)
                    ]
                ])
            })
        }
        PolarApp.shared.setGCM(fcmToken: "fcm_token_test")
        
        for i in 1...100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(i)/100000, execute: {
                PolarApp.shared.trackEvent(name: "DL event", attributes: [
                    "datap1": [
                        "datasub1": i,
                        "datasub2": false,
                        "datasub3": "hele",
                        "datasub4": UInt(3),
                        "datasub5": Float(5),
                        "datasub6": Decimal(1000)
                    ]
                ])
            })
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: {
            PolarApp.shared.updateUser(userID: nil, attributes: nil)
        })
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PolarApp.shared.setAPNS(deviceToken: deviceToken)
    }


    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        return PolarApp.shared.continueUserActivity(userActivity)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return PolarApp.shared.openUrl(url)
    }
}

