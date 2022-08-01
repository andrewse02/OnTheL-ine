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
    var pause = false
    
    let mainMenuInstructions: [String] = [
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
    
    let gameBoardInstructions: [String] = [
        """
        This is the game board.
        """,
        """
        Each player has their own L-piece.
        """,
        """
        There are also two Neutral pieces.
        """,
        """
        These act as obstacles in the way of your L-piece.
        """,
        """
        To make Blue's first move, drag your finger in an L-shape on the board to move your piece.
        """,
        """
        Now, tap on the Neutral piece to select it.
        """,
        """
        Tap to move the Neutral piece to the selected space to block Red from moving there.
        """,
        """
        Now it's Red's turn.
        """,
        """
        Red is moving...
        """,
        """
        As you can see, there are no available places to move Blue's L-piece.
        If you can't move anywhere, the other player wins.
        """,
        """
        And that concludes the tutorial! Thanks for playing the game, enjoy!
        """
    ]
    
    var gameBoardConstraints: [CellIndex] = []
    
    func reset() {
        tutorialActive = false
        pause = false
        gameBoardConstraints = []
    }
}
