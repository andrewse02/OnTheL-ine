//
//  SelectionCollectionViewController.swift
//  SelectionTesting
//
//  Created by Andrew Elliott on 4/9/22.
//

import UIKit
import FirebaseAuth

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
    
    var currentLIndexes: [CellIndex]?
    var tappedCell: SelectionCollectionViewCell?
    
    let cellSpacing: CGFloat = 3
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        NotificationManager.observeMainMenu(observer: self, selector: #selector(onMainMenuTapped))
        NotificationManager.observePlayAgain(observer: self, selector: #selector(onPlayAgainTapped))
    }
    
    // MARK: - Actions
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            TurnManager.shared.progressTurn()
            
            if self.gameMode == .online {
                guard let lIndexes = self.currentLIndexes else { return }
                
                
                if let selectedNeutral = TurnManager.shared.selectedNeutral,
                   let tappedCell = self.tappedCell {
                    WebSocketManager.shared.sendMove(lIndexes: lIndexes, neutralMove: (origin: selectedNeutral.index!, destination: tappedCell.index!), completion: self.onMoveComplete)
                } else {
                    WebSocketManager.shared.sendMove(lIndexes: lIndexes, neutralMove: nil, completion: self.onMoveComplete)
                }
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.updateViews()
                
                SoundManager.shared.playSound(soundFileName: "piece")
            }
        }
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
    
    @IBAction func backButtonTapped(_ sender: Any) {
        guard let gameMode = gameMode else { self.dismiss(animated: true); return }

        if gameMode == .online {
            // TODO: - Call function to send a leave game event to the server
        }
        
        onMainMenuTapped()
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        BoardManager.shared.delegate = self
        
        guard let gameMode = gameMode else { return }
        let players = gameMode.players()
        
        if BoardManager.shared.currentBoard == nil {
            BoardManager.shared.currentBoard = BoardManager.shared.createStartingBoard(player: players.player, opponent: players.opponent)
        }
        
        if TurnManager.shared.currentTurn == nil {
            TurnManager.shared.setTurn(Turn(playerType: players.player, turnType: .lPiece))
        }
        
        self.collectionView.register(SelectionCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.canCancelContentTouches = false
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        collectionView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        collectionView.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationManager.observeMoveMade(observer: self, selector: #selector(onMoveMade(notification:)))
        
        skipButton.customButton(titleText: "Skip", titleColor: Colors.dark)
        
        updateViews()
    }
    
    func updateViews() {
        guard let gameMode = gameMode,
              let currentTurn = TurnManager.shared.currentTurn,
              let player = currentTurn.playerType,
              let turnType = currentTurn.turnType else { return }
        let players = gameMode.players()
        
        if TurnManager.shared.gameEnded {
            guard let resultScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Result") as? ResultScreenViewController else { return }
            
            resultScreenViewController.didWin = player.opposite == players.player
            
            resultScreenViewController.modalPresentationStyle = .overCurrentContext
            Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { [weak self] timer in
                guard let self = self else { return }
                
                self.present(resultScreenViewController, animated: true)
            }
        } else {
            turnLabel.text = "\([PlayerType.player, PlayerType.local].contains(player) ? "Your" : "\(player.stringValue)'s") Turn"
            switch turnType {
            case .lPiece:
                tipLabel.text = "Move your L-piece"
            case .neutralPiece:
                tipLabel.text = "Move your neutral piece, or skip"
            case .waiting:
                tipLabel.text = ""
            }
            
            view.verticalGradient(top: player == players.player ? Colors.primaryDark : Colors.highlightDark, bottom: player == players.player ? Colors.primaryMiddleDark : Colors.highlightMiddleDark)
        }
        
        skipButton.isHidden = turnType != .neutralPiece
        collectionView.reloadData()
    }
    
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        guard !TurnManager.shared.gameEnded,
              let currentTurn = TurnManager.shared.currentTurn,
              currentTurn.playerType != .online,
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
            
            guard BoardManager.shared.currentBoard != nil else { return }
            let move = MoveManager.makeMove(for: currentPlayer, in: BoardManager.shared.currentBoard!, selections: selections.toArray())
            
            if move.0 != nil {
                BoardManager.shared.currentBoard!.setCurrentPosition(for: currentPlayer, selections: selections.toArray(), shapeIndex: move.1)
                
                TurnManager.shared.progressTurn()
                updateViews()
            }
            
            collectionView.reloadData()
            currentLIndexes = selections.toArray().map({ return $0.index ?? (row: -1, column: -1) })
            selections.clear()
        }
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        guard !TurnManager.shared.gameEnded,
              let board = BoardManager.shared.currentBoard,
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
                    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                        guard let self = self else { return }
                        
                        TurnManager.shared.progressTurn()
                        DispatchQueue.main.async {
                            self.updateViews()
                        }
                    }
                }
                
                collectionView.reloadData()
                
                if gameMode == .online {
                    guard let lIndexes = currentLIndexes else { return }
                    self.tappedCell = tappedCell
                    
                    WebSocketManager.shared.sendMove(lIndexes: lIndexes, neutralMove: (origin: selectedNeutral.index!, destination: tappedCell.index!), completion: onMoveComplete)
                }
                
                SoundManager.shared.playSound(soundFileName: "piece")
            }
        }
    }
    
    func onMoveComplete(data: [Any]) {
        
    }
    
    @objc func onMoveMade(notification: Notification) {
        guard let info = notification.userInfo?["info"] as? (board: [[String]], turn: String),
              let username = Auth.auth().currentUser?.displayName else { return }
        
        TurnManager.shared.currentTurn = username == info.turn ? Turn(playerType: .local, turnType: .lPiece) : Turn(playerType: .online, turnType: .lPiece)
        BoardManager.shared.currentBoard = Board(pieces: info.board)
        
        collectionView.reloadData()
        updateViews()
        
        SoundManager.shared.playSound(soundFileName: "piece")
    }
    
    @objc func onMainMenuTapped() {
        self.dismiss(animated: true)
        
        guard let gameMode = gameMode else { return }
        let players = gameMode.players()
        
        BoardManager.shared.currentBoard = nil
        TurnManager.shared.setTurn(nil)
        TurnManager.shared.gameEnded = false
        
        updateViews()
    }
    
    @objc func onPlayAgainTapped() {
        guard let gameMode = gameMode else { return }
        let players = gameMode.players()
        
        BoardManager.shared.currentBoard = BoardManager.shared.createStartingBoard(player: players.player, opponent: players.opponent)
        TurnManager.shared.setTurn(Turn(playerType: players.player, turnType: .lPiece))
        TurnManager.shared.gameEnded = false
        
        updateViews()
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
