//
//  TurnManager.swift
//  L Game
//
//  Created by Andrew Elliott on 4/12/22.
//

import Foundation

class TurnManager {
    
    // MARK: - Properties
    
    static let shared = TurnManager()
    
    var gameEnded = false
    var currentTurn: Turn?
    var selectedNeutral: SelectionCollectionViewCell? {
        willSet {
            selectedNeutral?.pieceSelected = false
        }
        didSet {
            selectedNeutral?.pieceSelected = true
        }
    }
    
    // MARK: - Helper Functions
    
    func setTurn(_ turn: Turn) {
        currentTurn = turn
    }
    
    func setTurnPlayer(_ playerType: PlayerType) {
        guard let currentTurn = currentTurn else { return }
        
        currentTurn.playerType = playerType
    }
    
    private func changeTurn() {
        guard let board = BoardManager.shared.currentBoard,
              let currentTurn = currentTurn,
              var player = currentTurn.playerType else { return }
        
        player = player.opposite
        currentTurn.playerType = player
        currentTurn.turnType = .lPiece
        
        let availableMoves = MoveManager.availableMoves(for: player, in: board)
        print(availableMoves.count)
        
        if availableMoves.count <= 0 {
            gameEnded = true
        } else if player == .computer {
            var bestMove: (lPosition: LPosition, neutralMove: NeutralMove?)?
            Benchmarkers().printTimeElapsedWhenRunningCode(title: "Minimax") {
                bestMove = ComputerManager.findBestMove(for: player, in: board)
            }
            guard let bestMove = bestMove else { return }
            
            var newBoard = board.newBoard(for: player, lPosition: bestMove.lPosition)
            if let neutralMove = bestMove.neutralMove {
                newBoard = newBoard.newBoard(for: player, neutralMove: neutralMove)
            }
            
            DispatchQueue.main.async {
                BoardManager.shared.currentBoard = newBoard
                self.changeTurn()
            }
        }
    }
    
    func progressTurn() {
        guard let currentTurn = currentTurn else { return }
        
        if currentTurn.turnType == .lPiece {
            currentTurn.turnType = .neutralPiece
        } else if currentTurn.turnType == .neutralPiece {
            changeTurn()
        }
        
        DispatchQueue.main.async {
            self.selectedNeutral = nil
        }
    }

}

enum TurnType {
    case lPiece
    case neutralPiece
    case waiting
}

class Turn {
    
    // MARK: - Properties
    
    var playerType: PlayerType?
    var turnType: TurnType?
    
    init(playerType: PlayerType, turnType: TurnType) {
        self.playerType = playerType
        self.turnType = turnType
    }
}
