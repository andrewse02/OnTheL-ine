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
    private static let playerJoinRoomName = Notification.Name("PlayerJoinRoom")
    private static let roomJoinName = Notification.Name("RoomJoin")
    private static let matchStartName = Notification.Name("MatchStart")
    private static let moveMadeName = Notification.Name("MoveMade")
    private static let playAgainName = Notification.Name("PlayAgain")
    private static let mainMenuName = Notification.Name("MainMenu")
    private static let tutorialMoveName = Notification.Name("TutorialMove")
    private static let turnChangedName = Notification.Name("TurnChanged")
    
    static func observeMatchFound(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: matchFoundName, object: nil)
    }
    
    static func postMatchFound(opponent: String) {
        notificationCenter.post(name: matchFoundName, object: nil, userInfo: ["opponent": opponent])
    }
    
    // Player joins a room you created
    static func observePlayerJoinRoom(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: playerJoinRoomName, object: nil)
    }
    
    // Player joins a room you created
    static func postPlayerJoinRoom(opponent: String) {
        notificationCenter.post(name: playerJoinRoomName, object: nil, userInfo: ["opponent": opponent])
    }
    
    // You successfully join a room another player created
    static func observeRoomJoin(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: roomJoinName, object: nil)
    }
    
    // You successfully join a room another player created
    static func postRoomJoin(opponent: String) {
        notificationCenter.post(name: roomJoinName, object: nil, userInfo: ["opponent": opponent])
    }
    
    static func observeMatchStart(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: matchStartName, object: nil)
    }
    
    static func postMatchStart(result: (board: [[String]], turn: NSString)) {
        notificationCenter.post(name: matchStartName, object: nil, userInfo: ["info": result])
    }
    
    static func observeMoveMade(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: moveMadeName, object: nil)
    }
    
    static func postMoveMade(result: (board: [[String]], turn: NSString)) {
        notificationCenter.post(name: moveMadeName, object: nil, userInfo: ["info": result])
    }
    
    static func observePlayAgain(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: playAgainName, object: nil)
    }
    
    static func postPlayAgain() {
        notificationCenter.post(name: playAgainName, object: nil)
    }
    
    static func observeMainMenu(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: mainMenuName, object: nil)
    }
    
    static func postMainMenu() {
        notificationCenter.post(name: mainMenuName, object: nil)
    }
    
    static func observeTutorialMove(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: tutorialMoveName, object: nil)
    }
    
    static func postTutorialMove() {
        notificationCenter.post(name: tutorialMoveName, object: nil)
    }
    
    static func observeTurnChanged(observer: Any, selector: Selector) {
        notificationCenter.addObserver(observer, selector: selector, name: turnChangedName, object: nil)
    }
    
    static func postTurnChanged() {
        notificationCenter.post(name: turnChangedName, object: nil)
    }
}
