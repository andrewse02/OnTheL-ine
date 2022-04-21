//
//  PlayerType.swift
//  L Game
//
//  Created by Andrew Elliott on 4/12/22.
//

import Foundation

enum PlayerType {
    case player1
    case player2
    case player
    case computer
    case local
    case online
    
    var opposite: PlayerType {
        switch self {
        case .player1:
            return .player2
        case .player2:
            return .player1
            
        case .player:
            return .computer
        case .computer:
            return .player
            
        case .local:
            return .online
        case .online:
            return .local
        }
    }
    
    var pieceValue: BoardPiece {
        switch self {
        case .player1:
            return .player1
        case .player2:
            return .player2
            
        case .player:
            return .player
        case .computer:
            return .computer
            
        case .local:
            return .local
        case .online:
            return .online
        }
    }
    
    var stringValue: String {
        switch self {
        case .player1:
            return "Player 1"
        case .player2:
            return "Player 2"
            
        case .player:
            return "You"
        case .computer:
            return "Computer"
            
        case .local:
            return "You"
        case .online:
            return "Opponent"
        }
    }
}
