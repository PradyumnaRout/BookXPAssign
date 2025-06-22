//
//  AppDelegate.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import Foundation
import FirebaseCore
import UIKit


class AppDelegate: NSObject, UIApplicationDelegate {
    
    // DidFinishLunching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().setBadgeCount(0)
        requestNotificationPerfmission()
        return true
    }
    
}
