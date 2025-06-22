//
//  AppDelegate + Extension.swift
//  BookXPAssign
//
//  Created by vikash kumar on 22/06/25.
//

import Foundation
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Request User Permisson
    func requestNotificationPerfmission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Permission Granted")
                UserDefaultsManager.shared.enableNotification = true
            } else {
                print("Permission Denied")
                UserDefaultsManager.shared.enableNotification = false
            }
        }
    }
    
    
    // Shows Notification In Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [[.badge, .sound, .banner, .list]]
    }
    
    // On Notification Action
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print(response.notification.request.content)
    }
}
