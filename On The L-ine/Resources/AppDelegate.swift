//
//  AppDelegate.swift
//  L Game
//
//  Created by Andrew Elliott on 4/12/22.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 150.0
        
        FirebaseApp.configure()
        FirestoreManager.configure()
        
//        SoundManager.shared.playSound(soundFileName: "music", volume: 0.2, loop: true)

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return false }
        
        guard let deepLink = DeepLink(rawValue: host) else { return false }
        
        if components.host == "join" {
            if let code = components.url?.pathComponents[1] {
                DeepLinkManager.roomCode = code
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
}
