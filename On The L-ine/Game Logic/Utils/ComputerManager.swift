//
//  ComputerManager.swift
//  L Game
//
//  Created by Andrew Elliott on 4/19/22.
//

import Foundation

class ComputerManager {
    
    // MARK: - Properties
    
    var currentDifficulty: ComputerDifficulty?
    
    // MARK: - Helper Functions
    
    static func makeMove(with difficulty: ComputerDifficulty) {
        
    }
    
    // MARK: - Minimax Functions
    
    static func findBestMove(for player: PlayerType, in board: Board) -> (lPosition: LPosition, neutralMove: NeutralMove?)? {
        var bestEval = Int.max
        var bestMove: (lPosition: LPosition, neutralMove: NeutralMove?)?
        
        for (_, move) in MoveManager.availableMoves(for: player, in: board).enumerated() {
            var newBoard = board.newBoard(for: player, lPosition: move.lPosition)
            if let neutralMove = move.neutralMove {
                newBoard = newBoard.newBoard(for: player, neutralMove: neutralMove)
            }
            
            let result = minimax(board: newBoard, player: player.opposite, maximizing: false, depth: 0, alpha: Int.min, beta: Int.max)
            if result < bestEval {
                bestEval = result
                bestMove = move
            }
        }

        return bestMove
    }
    
    static func minimax(board: Board, player: PlayerType, maximizing: Bool, depth: Int, alpha: Int, beta: Int) -> Int {
        let availableMoves = MoveManager.availableMoves(for: player, in: board)
        
        if depth == 0 {
            return availableMoves.count
        }
        
        if maximizing {
            var bestEval = Int.min
            for move in availableMoves {
                var newBoard = board.newBoard(for: player, lPosition: move.lPosition)
                if let neutralMove = move.neutralMove {
                    newBoard = newBoard.newBoard(for: player, neutralMove: neutralMove)
                }
                
                let result = minimax(board: newBoard, player: player.opposite, maximizing: false, depth: depth - 1, alpha: alpha, beta: beta)
                bestEval = max(result, bestEval)
                
                if beta >= min(alpha, bestEval) {
                    break
                }
            }
            
            return bestEval
        } else {
            var worstEval = Int.max
            for move in availableMoves {
                var newBoard = board.newBoard(for: player, lPosition: move.lPosition)
                if let neutralMove = move.neutralMove {
                    newBoard = newBoard.newBoard(for: player, neutralMove: neutralMove)
                }
                
                let result = minimax(board: newBoard, player: player.opposite, maximizing: true, depth: depth - 1, alpha: alpha, beta: beta)
                worstEval = min(result, worstEval)
                
                if max(beta, worstEval) >= alpha {
                    break
                }
            }
            
            return worstEval
        }
    }
}

enum ComputerDifficulty {
    case veryEasy
    case easy
    case normal
    case hard
    case master
}
