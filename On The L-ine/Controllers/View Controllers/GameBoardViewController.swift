//
//  SelectionCollectionViewController.swift
//  SelectionTesting
//
//  Created by Andrew Elliott on 4/9/22.
//

import UIKit

private let reuseIdentifier = "selectionCell"

class GameBoardViewController: UIViewController {
    
    // MARK: - Properties
    
    var gameMode: GameMode?
    
    var selections = Stack<SelectionCollectionViewCell>() {
        didSet {
            guard let cells = collectionView.visibleCells as? [SelectionCollectionViewCell],
                  let currentTurn = TurnManager.shared.currentTurn,
                  let playerType = currentTurn.playerType else { return }
            for item in cells {
                if selections.contains(element: item) {
                    switch playerType {
                    case .player1:
                        item.backgroundColor = Colors.mixedPrimary
                    case .player2:
                        item.backgroundColor = Colors.mixedHighlight
                    case .player:
                        item.backgroundColor = Colors.mixedPrimary
                    case .computer:
                        item.backgroundColor = Colors.mixedHighlight
                    case .local:
                        item.backgroundColor = Colors.mixedPrimary
                    case .online:
                        item.backgroundColor = Colors.mixedHighlight
                    }
                }
            }
        }
    }
    let cellSpacing: CGFloat = 3
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - Actions
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        TurnManager.shared.progressTurn()
        updateSkipButton()
    }
    
    @IBAction func rotateClockwiseButtonTapped(_ sender: Any) {
        guard let board = BoardManager.shared.currentBoard else { return }
        BoardManager.shared.currentBoard = board.rotateClockwise()
        collectionView.reloadData()
    }
    
    @IBAction func rotateCounterClockwiseButtonTapped(_ sender: Any) {
        guard let board = BoardManager.shared.currentBoard else { return }
        BoardManager.shared.currentBoard = board.rotateCounterClockwise()
        collectionView.reloadData()
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        BoardManager.shared.delegate = self
        
        guard let gameMode = gameMode else { return }
        let players = gameMode.players()
        
        if BoardManager.shared.currentBoard == nil { BoardManager.shared.currentBoard = BoardManager.shared.createStartingBoard(player: players.player, opponent: players.opponent) }
        TurnManager.shared.setTurn(Turn(playerType: players.player, turnType: .lPiece))
        
        self.collectionView.register(SelectionCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.canCancelContentTouches = false
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        collectionView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        collectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func updateSkipButton() {
        skipButton.isHidden = TurnManager.shared.currentTurn?.turnType != .neutralPiece
    }
    
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        guard let currentTurn = TurnManager.shared.currentTurn,
              currentTurn.turnType == .lPiece else { return }
        
        if sender.state == .changed || sender.state == .began{
            let location = sender.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: location),
               let pannedCell = collectionView.cellForItem(at: indexPath) as? SelectionCollectionViewCell {
                if selections.peek(elements: 2) != pannedCell {
                    guard !selections.contains(element: pannedCell),
                          selections.size() < 4 else { return }
                    
                    selections.push(pannedCell)
                } else {
                    _ = selections.pop()
                }
            }
        } else if sender.state == .ended {
            guard let currentPlayer = currentTurn.playerType else { return }
            
            guard let board = BoardManager.shared.currentBoard else { return }
            let move = MoveManager.makeMove(for: currentPlayer, in: board, selections: selections.toArray())
            
            if move.0 != nil {
                board.setCurrentPosition(for: currentPlayer, selections: selections.toArray(), shapeIndex: move.1)
                
                TurnManager.shared.progressTurn()
                updateSkipButton()
            }
            
            collectionView.reloadData()
            selections.clear()
        }
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        guard let board = BoardManager.shared.currentBoard,
              let currentTurn = TurnManager.shared.currentTurn,
              currentTurn.turnType == .neutralPiece else { return }
        
        let location = sender.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location),
           let tappedCell = collectionView.cellForItem(at: indexPath) as? SelectionCollectionViewCell {
            let tappedPieceType = board.piece(at: (row: indexPath.row / Constants.size, column: indexPath.row % Constants.size))
            if tappedPieceType == .neutral {
                TurnManager.shared.selectedNeutral = TurnManager.shared.selectedNeutral == tappedCell ? nil : tappedCell
            } else if tappedPieceType == .empty {
                guard let selectedNeutral = TurnManager.shared.selectedNeutral else { return }
                
                if let _ = MoveManager.makeNeutralMove(in: board, origin: selectedNeutral, destination: tappedCell) {
                    DispatchQueue.global(qos: .userInitiated).async {
                        TurnManager.shared.progressTurn()
                    }
                    
                    updateSkipButton()
                }
                
                collectionView.reloadData()
            }
        }
    }
}

extension GameBoardViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.size * Constants.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SelectionCollectionViewCell,
              let board = BoardManager.shared.currentBoard else { return UICollectionViewCell() }
        
        cell.type = board.pieces[indexPath.row / Constants.size][indexPath.row % Constants.size]
        cell.index = (indexPath.row / Constants.size, indexPath.row % Constants.size)
        cell.pieceSelected = TurnManager.shared.selectedNeutral == cell
        cell.updateViews()
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / Double(Constants.size) - cellSpacing, height: collectionView.frame.size.width / Double(Constants.size) - cellSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}

extension GameBoardViewController: BoardManagerDelegate {
    func currentBoardChanged() {
        collectionView.reloadData()
    }
}
