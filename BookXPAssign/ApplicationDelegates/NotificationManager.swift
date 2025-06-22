//
//  NotificationManager.swift
//  BookXPAssign
//
//  Created by vikash kumar on 22/06/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    // Properties
    static let shared = NotificationManager()
    
    // Initializer
    private init() {}
    
    // Notify the user when delete
    func notifyItemDeletion(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // Trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        // Request.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(){
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
