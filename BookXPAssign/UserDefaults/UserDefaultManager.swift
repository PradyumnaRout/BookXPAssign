//
//  UserDefaultManager.swift
//  BookXPAssign
//
//  Created by vikash kumar on 22/06/25.
//

import Foundation

struct UserDefaultsManager {
    
    static var shared = UserDefaultsManager()
    
    private init() {}
    
    static let applicationDefaults = UserDefaults.standard
    
    var enableNotification: Bool {
        get {
            return UserDefaultsManager.applicationDefaults.bool(forKey: "enable_notification")
        }
        set {
            UserDefaultsManager.applicationDefaults.setValue(newValue, forKey: "enable_notification")
        }
    }
}
