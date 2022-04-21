//
//  Board.swift
//  L Game
//
//  Created by Andrew Elliott on 4/18/22.
//

import Foundation

class Board {
    
    // MARK: - Properties
    
    var pieces: [[BoardPiece]] = []
    private var currentPositions: [PlayerType: LPosition] = [:]
    
    init(pieces: [[BoardPiece]]) {
        self.pieces = pieces
    }
    
    // MARK: - Helper Functions
    
    func copy() -> Board {
        return Board(pieces: pieces)
    }
    
    func piece(at index: CellIndex) -> BoardPiece? {
        return pieces[index.row][index.column]
    }
    
    func setCurrentPosition(for player: PlayerType, selections: [SelectionCollectionViewCell], shapeIndex: Int) {
        if var position = currentPositions[player] {
            position.origin = selections[0].index ?? (row: -1, column: -1)
            position.shapeIndex = shapeIndex
            
            currentPositions[player] = position
        } else {
            let origin = selections[0].index ?? (row: -1, column: -1)
            
            currentPositions[player] = (origin: origin, shapeIndex: shapeIndex)
        }
    }
    
    func currentPosition(for player: PlayerType) -> LPosition? {
        return currentPositions[player]
    }
    
    func currentNeutralPositions() -> [CellIndex] {
        var result: [CellIndex] = []
        
        for (row, _) in pieces.enumerated() {
            for (column, _) in pieces.enumerated() {
                if pieces[row][column] == .neutral {
                    result.append((row: row, column: column))
                    if result.count >= 2 { return result }
                }
            }
        }
        
        return result
    }
    
    func rotateClockwise() -> Board {
        let newBoard = copy()
        
        for (row, _) in newBoard.pieces.enumerated() {
            for (column, _) in newBoard.pieces.enumerated() {
                newBoard.pieces[row][column] = pieces[Constants.size - 1 - column][row]
            }
        }
        
        return newBoard
    }
    
    func rotateCounterClockwise() -> Board {
        let newBoard = copy()
        
        for (row, _) in newBoard.pieces.enumerated() {
            for (column, _) in newBoard.pieces.enumerated() {
                newBoard.pieces[row][column] = pieces[column][Constants.size - 1 - row]
            }
        }
        
        return newBoard
    }
    
    func newBoard(for player: PlayerType, lPosition: LPosition) -> Board {
        var newPieces = Array(repeating: Array(repeating: BoardPiece.empty, count: 4), count: 4)
        
        let indexes: [CellIndex] = MoveManager.validLIndexes[lPosition.shapeIndex].map { index in
            return (row: index.row + lPosition.origin.row, column: index.column + lPosition.origin.column)
        }
        
        for (row, _) in newPieces.enumerated() {
            for (column, _) in newPieces[row].enumerated() {
                if self.piece(at: (row: row, column: column)) == player.pieceValue && !indexes.contains(where: { $0 == (row: row, column: column) }) {
                    newPieces[row][column] = .empty
                } else if indexes.contains(where: { $0 == (row: row, column: column) }) {
                    newPieces[row][column] = player.pieceValue
                } else {
                    newPieces[row][column] = self.piece(at: (row: row, column: column)) ?? .empty
                }
            }
        }
        
        return Board(pieces: newPieces)
    }
    
    func newBoard(for player: PlayerType, neutralMove: NeutralMove) -> Board {
        let board = self.copy()
        
        board.pieces[neutralMove.origin.row][neutralMove.origin.column] = .empty
        board.pieces[neutralMove.destination.row][neutralMove.destination.column] = .neutral
        
        return board
    }
}
