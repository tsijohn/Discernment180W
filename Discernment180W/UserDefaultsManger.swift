//
//  UserDefaultsManger.swift
//  Discernment180W
//
//  Created by John Kim on 9/12/24.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private init() {} // Prevents instantiation
    
    // Save activities
    func saveActivities(_ activities: [String]) {
        UserDefaults.standard.set(activities, forKey: "dailyActivities")
    }
    
    // Load activities
    func loadActivities() -> [String] {
        return UserDefaults.standard.array(forKey: "dailyActivities") as? [String] ?? []
    }
}
