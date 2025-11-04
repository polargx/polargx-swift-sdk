//
//  AppDelegate.swift
//  DemoUIKit
//
//  Created by duyenlv on 20/1/25.
//

import UIKit
import PolarGX

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        PolarApp.isLoggingEnabled = true;
        PolarApp.initialize(appId: "40b59333-4350-4fc8-a59b-fdcab6bc0274", apiKey: "dev_HkP4KkjQ0i1z3t8BodVfPokPm5x3Qsm5JvrfUcKc") { link, data, error in
            print("\n[DEMO] detect clicked: \(link), data: \(data), error: \(error)\n")
        }
        
//        PolarApp.shared.updateUser(userID: "e1a3cb25-839e-4deb-95b0-2fb8ebd79401", attributes: [PolarEventKey.Name: "dl1", PolarEventKey.Email: "dl1@gmail.com"])
//        
        for i in 1...2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(i)/1, execute: {
                PolarApp.shared.updateUser(userID: "e1a3cb25-839e-4deb-95b0-2fb8ebd79402", attributes: [
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
        
        for i in 1...1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(i)/10, execute: {
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
        
        
        
        return true
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


    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        return PolarApp.shared.continueUserActivity(userActivity)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return PolarApp.shared.openUrl(url)
    }
}

