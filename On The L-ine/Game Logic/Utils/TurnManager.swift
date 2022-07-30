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
    
    func setTurn(_ turn: Turn?) {
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
        
        guard !checkGameEnded(for: player, in: board) else { return }
        
        if player == .computer {
            var bestMove: (lPosition: LPosition, neutralMove: NeutralMove?)?
            Benchmarkers().printTimeElapsedWhenRunningCode(title: "Minimax") {
                bestMove = ComputerManager.findBestMove(for: player, in: board)
            }
            guard let bestMove = bestMove else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...3)) {
                var newBoard = board.newBoard(for: player, lPosition: bestMove.lPosition)
                BoardManager.shared.currentBoard = newBoard
                SoundManager.shared.playSound(soundFileName: SoundManager.pieceSoundName)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...2)) {
                    if let neutralMove = bestMove.neutralMove {
                        newBoard = newBoard.newBoard(for: player, neutralMove: neutralMove)
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        BoardManager.shared.currentBoard = newBoard
                        SoundManager.shared.playSound(soundFileName: SoundManager.pieceSoundName)
                        
                        if TutorialManager.shared.tutorialActive {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                NotificationManager.postTutorialMove()
                            }
                        }
                        
                        self.changeTurn()
                    }
                }
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.selectedNeutral = nil
        }
    }

    func checkGameEnded(for player: PlayerType, in board: Board) -> Bool {
        let availableMoves = MoveManager.availableMoves(for: player, in: board)
        
        if availableMoves.count <= 0 {
            gameEnded = true
            NotificationManager.postTurnChanged()
            
            return true
        }
        
        return false
    }
}

enum TurnType {
    case lPiece
    case neutralPiece
    case waiting
}

class Turn {
    
    // MARK: - Properties
    
    var playerType: PlayerType? {
        didSet {
            NotificationManager.postTurnChanged()
        }
    }
    var turnType: TurnType?
    
    init(playerType: PlayerType, turnType: TurnType) {
        self.playerType = playerType
        self.turnType = turnType
    }
}
