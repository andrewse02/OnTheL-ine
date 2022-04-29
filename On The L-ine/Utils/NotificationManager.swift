//
//  NotificationManager.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/22/22.
//

import Foundation

class NotificationManager {
    static let notificationCenter = NotificationCenter.default
    
    private static let matchFoundName = Notification.Name("MatchFound")
    
    static func observeMatchFound(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: matchFoundName, object: nil)
    }
    
    static func postMatchFound(opponent: String) {
        notificationCenter.post(name: matchFoundName, object: nil, userInfo: ["opponent": opponent])
    }
}
