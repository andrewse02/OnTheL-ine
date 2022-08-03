//
//  AppDelegate.swift
//  L Game
//
//  Created by Andrew Elliott on 4/12/22.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import AVFAudio
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 150.0
        
        FirebaseApp.configure()
        FirestoreManager.configure()
        
        var categoryError: NSError?
        var success: Bool
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
            success = true
        } catch let error as NSError {
            categoryError = error
            success = false
        }
        
        if !success {
            print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(categoryError!)\n\n\(categoryError!.localizedDescription)")
        }
        
        SoundManager.shared.playSound(soundFileName: SoundManager.musicSoundName, volume: 0.1, loop: true)
        SoundManager.shared.musicEnabled = UserDefaults.standard.object(forKey: "MusicEnabled") as? Bool ?? true
        
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            print("Tracking Granted: \(status == .authorized)")
        })
    }
}
