//
//  BoardPiece.swift
//  L Game
//
//  Created by Andrew Elliott on 4/12/22.
//

import Foundation
import FirebaseAuth

enum BoardPiece {
    case empty
    case neutral
    case player1
    case player2
    case player
    case computer
    case local
    case online
    
    static func from(string: String) -> BoardPiece? {
        guard let username = Auth.auth().currentUser?.displayName else { return nil }
        
        switch string {
        case "#": return .empty
        case "*": return .neutral
        case username: return .local
        default: return .online
        }
    }
}
