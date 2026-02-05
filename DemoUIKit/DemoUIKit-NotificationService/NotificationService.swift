//
//  NotificationService.swift
//  DemoUIKit-NotificationService
//
//  Created by Duyen LE on 5/2/26.
//

import UserNotifications
import PolarGX_NotificationServiceExtension

class NotificationService: PolarNotificationService {
    
    override init() {
        super.init()
        
        PolarSettings.appGroupIdentifier = "group.com.bohemian.polar.mobilesdktest"
    }

}
