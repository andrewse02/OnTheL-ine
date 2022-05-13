//
//  SoundManager.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 5/3/22.
//

import Foundation
import AVFoundation

class SoundManager: NSObject, AVAudioPlayerDelegate {
    static let shared = SoundManager()
    static let pieceSoundName = "piece"
    static let musicSoundName = "music"
    
    private override init() { }
    
    var players: [URL: AVAudioPlayer] = [:]
    var duplicatePlayers: [AVAudioPlayer] = []
    
    func playSound(soundFileName: String, volume: Float = 1, loop: Bool = false) {
        
        guard let bundle = Bundle.main.path(forResource: soundFileName, ofType: "mp3") else { return }
        let soundFileNameURL = URL(fileURLWithPath: bundle)
        
        if let player = players[soundFileNameURL] { //player for sound has been found
            if !player.isPlaying { //player is not in use, so use that one
                player.volume = volume
                player.numberOfLoops = loop ? -1 : 0
                player.prepareToPlay()
                player.play()
            } else { // player is in use, create a new, duplicate, player and use that instead
                do {
                    let duplicatePlayer = try AVAudioPlayer(contentsOf: soundFileNameURL)
                    
                    duplicatePlayer.delegate = self
                    //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing
                    
                    duplicatePlayers.append(duplicatePlayer)
                    //add duplicate to array so it doesn't get removed from memory before finishing
                    
                    duplicatePlayer.volume = volume
                    player.numberOfLoops = loop ? -1 : 0
                    duplicatePlayer.prepareToPlay()
                    duplicatePlayer.play()
                } catch let error {
                    print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                }
                
            }
        } else { //player has not been found, create a new player with the URL if possible
            do {
                let player = try AVAudioPlayer(contentsOf: soundFileNameURL)
                players[soundFileNameURL] = player
                player.volume = volume
                player.numberOfLoops = loop ? -1 : 0
                player.prepareToPlay()
                player.play()
            } catch let error {
                print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
            }
        }
    }
    
    func playSounds(soundFileNames: [String]) {
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }
    
    func playSounds(soundFileNames: String...) {
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }
    
    func playSounds(soundFileNames: [String], withDelay: Double) { //withDelay is in seconds
        for (index, soundFileName) in soundFileNames.enumerated() {
            let delay = withDelay * Double(index)
            let _ = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(playSoundNotification(_:)), userInfo: ["fileName": soundFileName], repeats: false)
        }
    }
    
    @objc func playSoundNotification(_ notification: NSNotification) {
        if let soundFileName = notification.userInfo?["fileName"] as? String {
            playSound(soundFileName: soundFileName)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = duplicatePlayers.firstIndex(of: player) {
            duplicatePlayers.remove(at: index)
        }
    }
    
//    func startBackgroundMusic() {
//        if let bundle = Bundle.main.path(forResource: "music", ofType: "mp3") {
//            let backgroundMusic = NSURL(fileURLWithPath: bundle)
//            do {
//                audioPlayer = try AVAudioPlayer(contentsOf: backgroundMusic as URL)
//                guard let audioPlayer = audioPlayer else { return }
//                audioPlayer.numberOfLoops = -1
//                audioPlayer.volume = 0.4
//                audioPlayer.prepareToPlay()
//                audioPlayer.play()
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    func playPieceSoundEffect() {
//        if let bundle = Bundle.main.path(forResource: "piece", ofType: "mp3") {
//            let soundEffectUrl = NSURL(fileURLWithPath: bundle)
//            do {
//                audioPlayer = try AVAudioPlayer(contentsOf: soundEffectUrl as URL)
//                guard let audioPlayer = audioPlayer else { return }
//                audioPlayer.play()
//            } catch {
//                print(error)
//            }
//        }
//    }
}
