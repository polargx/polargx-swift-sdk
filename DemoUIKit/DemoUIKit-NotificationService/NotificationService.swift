//
//  NotificationService.swift
//  DemoUIKit-NotificationService
//
//  Created by Duyen LE on 5/2/26.
//

import UserNotifications
import PolarGX_NotificationServiceExtension

class NotificationService: PolarNotificationService {
    
    override var appGroupIdentifier: String? {
        "group.com.bohemian.polar.mobilesdktest"
    }

}
