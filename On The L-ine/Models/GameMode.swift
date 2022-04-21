//
//  GameMode.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/21/22.
//

import Foundation

enum GameMode {
    case local
    case computer
    case online
    
    func players() -> (player: PlayerType, opponent: PlayerType) {
        switch self {
        case .local:
            return (player: .player1, opponent: .player1.opposite)
        case .computer:
            return (player: .player, opponent: .player.opposite)
        case .online:
            return (player: .local, opponent: .local.opposite)
        }
    }
}
