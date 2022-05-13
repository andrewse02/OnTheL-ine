//
//  BoardManager.swift
//  L Game
//
//  Created by Andrew Elliott on 4/12/22.
//

import Foundation

protocol BoardManagerDelegate: AnyObject {
    func currentBoardChanged()
}

class BoardManager {
    
    // MARK: - Properties
    
    static let shared = BoardManager()
    weak var delegate: BoardManagerDelegate?
    var currentBoard: Board? {
        didSet {
            guard let delegate = delegate else { return }
            delegate.currentBoardChanged()
        }
    }
    
    // MARK: - Helper Functions
    
    func createStartingBoard(player: PlayerType, opponent: PlayerType) -> Board {
        return Board(pieces: [
            [.neutral, opponent.pieceValue, opponent.pieceValue, .empty],
            [.empty,   player.pieceValue,   opponent.pieceValue, .empty],
            [.empty,   player.pieceValue,   opponent.pieceValue, .empty],
            [.empty,   player.pieceValue,   player.pieceValue,   .neutral]
        ])
    }
}
