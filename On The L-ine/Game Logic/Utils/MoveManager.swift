//
//  MoveValidator.swift
//  SelectionTesting
//
//  Created by Andrew Elliott on 4/10/22.
//

import Foundation
import UIKit

/*
 
 All Valid L's
 
 #      #  ###  ###
 ###  ###  #      #
 
 #    #  ##  ##
 #    #  #    #
 ##  ##  #    #
 
 */

typealias LPosition = (origin: CellIndex, shapeIndex: Int)
typealias NeutralMove = (origin: CellIndex, destination: CellIndex)

class MoveManager {
    static let validLs = [
        [["*", "#", "#"],
         ["*", "*", "*"]],
        
        [["#", "#", "*"],
         ["*", "*", "*"]],
        
        [["*", "*", "*"],
         ["*", "#", "#"]],
        
        [["*", "*", "*"],
         ["#", "#", "*"]],
        
        [["*", "#"],
         ["*", "#"],
         ["*", "*"]],
        
        [["#", "*"],
         ["#", "*"],
         ["*", "*"]],
        
        [["*", "*"],
         ["*", "#"],
         ["*", "#"]],
        
        [["*", "*"],
         ["#", "*"],
         ["#", "*"]]
    ]
    
    static let validLIndexes: [[CellIndex]] = [
        [(row: 0, column: 0), (row: 1, column: 0), (row: 1, column: 1), (row: 1, column: 2)],
        [(row: 0, column: 2), (row: 1, column: 0), (row: 1, column: 1), (row: 1, column: 2)],
        [(row: 0, column: 0), (row: 0, column: 1), (row: 0, column: 2), (row: 1, column: 0)],
        [(row: 0, column: 0), (row: 0, column: 1), (row: 0, column: 2), (row: 1, column: 2)],
        [(row: 0, column: 0), (row: 1, column: 0), (row: 2, column: 0), (row: 2, column: 1)],
        [(row: 0, column: 1), (row: 1, column: 1), (row: 2, column: 0), (row: 2, column: 1)],
        [(row: 0, column: 0), (row: 0, column: 1), (row: 1, column: 0), (row: 2, column: 0)],
        [(row: 0, column: 0), (row: 0, column: 1), (row: 1, column: 1), (row: 2, column: 1)]
    ]
    
    private static func isValidL(selections: [SelectionCollectionViewCell]) -> (Bool, Int) {
        let stringPattern = createStringPattern(from: selections)
        
        for (validLIndex, validL) in MoveManager.validLs.enumerated() {
            let containedIndex = checkIsContained(size: Constants.size, mat1: stringPattern, mat2: validL)
            if containedIndex.row != -1 && containedIndex.column != -1 {
                return (true, validLIndex)
            }
        }
        
        return (false, -1)
    }
    
    static func availableMoves(for player: PlayerType, in board: Board) -> [(lPosition: LPosition, neutralMove: NeutralMove?)] {
        let pattern = createAvailableMoveStringPattern(for: player, in: board)
        
        var result: [(lPosition: LPosition, neutralMove: NeutralMove?)] = []
        
        for (validIndex, validL) in validLIndexes.enumerated() {
            
            for(originY, _) in pattern.enumerated() {
                for (originX, _) in pattern.enumerated() {
                    
                    var found = true
                    var indexes: [CellIndex] = []
                    for(_, shape) in validL.enumerated() {
                        let finalY = originY + shape.row
                        let finalX = originX + shape.column
                        
                        found = pattern.indices.contains(finalY) && pattern[finalY].indices.contains(finalX)
                        && pattern[finalY][finalX] == "*"
                        
                        if !found {
                            indexes = []
                            break
                        } else {
                            indexes.append((row: finalY, column: finalX))
                        }
                    }
                    
                    if found && isNewPlacement(for: player, in: board, indexes: indexes) {
                        let lPosition = (origin: (row: originY, column: originX), shapeIndex: validIndex)
                        let newBoard = board.newBoard(for: player, lPosition: lPosition)
                        
                        var neutralIndexes: [CellIndex] = []
                        
                        for (row, _) in newBoard.pieces.enumerated() {
                            for (column, _) in newBoard.pieces[row].enumerated() {
                                if newBoard.piece(at: (row: row, column: column)) == .neutral {
                                    neutralIndexes.append((row: row, column: column))
                                    if neutralIndexes.count >= 2 { break }
                                }
                            }
                            if neutralIndexes.count >= 2 { break }
                        }
                        
                        for neutralIndex in neutralIndexes {
                            for (row, _) in newBoard.pieces.enumerated() {
                                for (column, _) in newBoard.pieces[row].enumerated() {
                                    if newBoard.piece(at: (row: row, column: column)) == .empty {
                                        let item = (lPosition: lPosition, neutralMove: (origin: (row: neutralIndex.row, column: neutralIndex.column), destination: (row: row, column: column)))
                                        result.append(item)
                                    }
                                }
                            }
                        }
                        let item: (lPosition: LPosition, neutralMove: NeutralMove?) = ((lPosition: lPosition, neutralMove: nil))
                        result.append(item)
                    }
                }
            }
        }
        
        return result
    }
    
    private static func isValidMove(for player: PlayerType, in board: Board, selections: [SelectionCollectionViewCell]) -> (Bool, Int) {
        guard TurnManager.shared.currentTurn?.playerType == player else { return (false, -1) }
        
        let isValidL = isValidL(selections: selections)
        
        guard isValidL.0 else { return (false, -1) }
        
        let isNewPlacement = isNewPlacement(for: player, selections: selections)
        
        return (isNewPlacement, isValidL.1)
    }
    
    static func isNewPlacement(for player: PlayerType, selections: [SelectionCollectionViewCell]) -> Bool {
        var result = false
        
        for selection in selections {
            guard let type = selection.type else { return false }
            
            if type == .empty {
                result = true
                break
            }
        }
        
        return result
    }
    
    static func isNewPlacement(for player: PlayerType, in board: Board, indexes: [CellIndex]) -> Bool {
        var result = false
        
        for index in indexes {
            guard let type = board.piece(at: (row: index.row, column: index.column)) else { return false }
            
            if type == .empty {
                result = true
                break
            }
        }
        
        return result
    }
    
    static func makeMove(for player: PlayerType, in board: Board, selections: [SelectionCollectionViewCell]) -> (Board?, Int) {
        let isValidMove = isValidMove(for: player, in: board, selections: selections)
        if isValidMove.0 {
            let newBoard = board.copy()
            
            var newPieces = Array(repeating: Array(repeating: BoardPiece.empty, count: 4), count: 4)
            let indexes = selections.map { return $0.index ?? (row: -1, column: -1) }
            
            for (row, _) in newBoard.pieces.enumerated() {
                for (column, piece) in newBoard.pieces[row].enumerated() {
                    if indexes.contains(where: { $0 == (row: row, column: column) }) {
                        newPieces[row][column] = player.pieceValue
                    } else if piece == player.pieceValue {
                        newPieces[row][column] = .empty
                    } else {
                        newPieces[row][column] = piece
                    }
                }
            }
            
            BoardManager.shared.currentBoard = Board(pieces: newPieces)
            return (newBoard, isValidMove.1)
        } else { return (nil, -1) }
    }
    
    static func makeMove(player: PlayerType, newBoard: Board) {
        BoardManager.shared.currentBoard = newBoard
        TurnManager.shared.progressTurn()
    }
    
    static func makeNeutralMove(in board: Board, origin: SelectionCollectionViewCell, destination: SelectionCollectionViewCell) -> Board? {
        let newBoard = board.copy()
        
        guard let originIndex = origin.index,
              let destinationIndex = destination.index else { return nil }
        
        newBoard.pieces[originIndex.row][originIndex.column] = .empty
        newBoard.pieces[destinationIndex.row][destinationIndex.column] = .neutral
        
        BoardManager.shared.currentBoard = newBoard
        return newBoard
    }
    
    static func createStringPattern(from indexes: [[Int]]) -> [[String]] {
        let indexes = indexes
        
        let rows = indexes[Constants.size - 1][0] + 1
        let columns = Constants.size - indexes[Constants.size - 1][0]
        
        var resultArray = Array(repeating: Array(repeating: "#", count: rows), count: columns)
        
        for index in indexes {
            if !(resultArray.indices.contains(index[0]) && resultArray.indices.contains(index[1])) { continue }
            resultArray[index[0]][index[1]] = "*"
        }
        
        return resultArray
    }
    
    static func createStringPattern(from cells: [SelectionCollectionViewCell]) -> [[String]] {
        var indexes = cells.map { cell in
            return cell.index
        }
        
        indexes.sort { index1, index2 in
            if let index1 = index1,
               let index2 = index2 {
                if index1 == index2 { return true }
                
                let sum1 = index1.row + index1.column
                let sum2 = index2.row + index2.column
                
                if sum1 != sum2 {
                    return sum1 < sum2
                } else {
                    if index1.row == index2.row {
                        return index1.column < index2.column
                    } else {
                        return index1.row < index2.row
                    }
                }
            } else {
                return false
            }
        }
        
        var resultArray = Array(repeating: Array(repeating: "#", count: 4), count: 4)
        var result = ""
        
        for index in indexes {
            guard let index = index else { continue }
            resultArray[index.row][index.column] = "*"
        }
        
        for (index, _) in resultArray.enumerated() {
            for column in resultArray[index] {
                result.append(column)
            }
            result.append("\n")
        }
        
        return resultArray
    }
    
    static func createAvailableMoveStringPattern(for player: PlayerType, in board: Board) -> [[String]] {
        var resultArray = Array(repeating: Array(repeating: "#", count: 4), count: 4)
        let availableTypes = [BoardPiece.empty, player.pieceValue]
        
        for (row, _) in resultArray.enumerated() {
            for (column, _) in resultArray[row].enumerated() {
                guard let piece = board.piece(at: (row: row, column: column)) else { return [] }
                
                if availableTypes.contains(piece) {
                    resultArray[row][column] = "*"
                }
            }
        }
        
        return resultArray
    }
    
    private static func checkIsContained(size: Int, mat1: [[String]], mat2: [[String]]) -> CellIndex {
        for i in 0..<mat1.count - 1 {
            for j in 0..<mat1[0].count - 1 {
                
                if j < 2 && mat2.count == 2 && mat2[0].count == 3 {
                    //                    if j >= 2 { continue }
                    if(!(mat1[i][j] == mat2[0][0] && mat1[i][j+1] == mat2[0][1] && mat1[i][j+2] == mat2[0][2])) { continue }
                    if(!(mat1[i+1][j] == mat2[1][0] && mat1[i+1][j+1] == mat2[1][1] && mat1[i+1][j+2] == mat2[1][2])) { continue }
                    return (row: i, column: j)
                } else if i < 2 && mat2.count == 3 && mat2[0].count == 2 {
                    //                    if i >= 2 { continue }
                    if(!(mat1[i][j] == mat2[0][0] && mat1[i][j+1] == mat2[0][1])) { continue }
                    if(!(mat1[i+1][j] == mat2[1][0] && mat1[i+1][j+1] == mat2[1][1])) { continue }
                    if(!(mat1[i+2][j] == mat2[2][0] && mat1[i+2][j+1] == mat2[2][1])) { continue }
                    
                    return (row: i, column: j)
                }
            }
        }
        return (row: -1, column: -1)
    }
}
