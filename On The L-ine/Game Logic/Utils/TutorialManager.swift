//
//  TutorialManager.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 6/18/22.
//

import Foundation

class TutorialManager {
    static let shared = TutorialManager()
    
    var tutorialActive = false
    var currentStep = 0
    
    let mainMenuInstructions = [
        """
        Welcome to the tutorial!
        Let's first take a look around the Main Menu.
        """,
        """
        Here we have the game modes.
        """,
        """
        Local: Play against a friend (or yourself) on the same device.
        """,
        """
        Computer: Get some casual practice, or give yourself a challenge with the EXTREMELY intelligent Computer.
        """,
        """
        Online: Hop in the queue, or play with a friend in a private Room.
        """
    ]
    
    let gameBoardInstructions = [
        """
        This is the game board.
        """,
        """
        Each player has their own L-piece.
        """,
        """
        There are also two neutral pieces.
        """,
        """
        To make Blue's first move, drag your finger in an L-shape on the board to move your piece.
        """
    ]
    
    func reset() {
        tutorialActive = false
        currentStep = 0
    }
}
