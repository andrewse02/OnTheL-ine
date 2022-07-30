//
//  SelectionCollectionViewController.swift
//  SelectionTesting
//
//  Created by Andrew Elliott on 4/9/22.
//

import UIKit
import FirebaseAuth
import Instructions

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
    
    let coachMarksController = CoachMarksController()
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var rotateClockwiseButton: UIButton!
    @IBOutlet weak var rotateCounterClockwiseButton: UIButton!
    
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        NotificationManager.observeMainMenu(observer: self, selector: #selector(onMainMenuTapped))
        NotificationManager.observePlayAgain(observer: self, selector: #selector(onPlayAgainTapped))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if TutorialManager.shared.tutorialActive {
            self.coachMarksController.start(in: .window(over: self))
            NotificationManager.observeTutorialMove(observer: self, selector: #selector(onTutorialMoveMade))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
    }
    
    // MARK: - Actions
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                TurnManager.shared.progressTurn()
            }
            
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
                
                SoundManager.shared.playSound(soundFileName: SoundManager.pieceSoundName)
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
        
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        
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
        NotificationManager.observeTurnChanged(observer: self, selector: #selector(onTurnChanged))
        
        skipButton.customButton(titleText: "Skip", titleColor: Colors.dark)
        
        updateViews()
    }
    
    func updateViews() {
        guard let gameMode = gameMode,
              let currentTurn = TurnManager.shared.currentTurn,
              let player = currentTurn.playerType,
              let turnType = currentTurn.turnType else { return }
        let players = gameMode.players()
        
        if TurnManager.shared.gameEnded && !TutorialManager.shared.tutorialActive {
            guard let resultScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Result") as? ResultScreenViewController else { return }
            
            resultScreenViewController.gameMode = gameMode
            resultScreenViewController.didWin = player.opposite == players.player
            
            resultScreenViewController.modalPresentationStyle = .overCurrentContext
            Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { [weak self] timer in
                guard let self = self else { return }
                
                self.present(resultScreenViewController, animated: true)
            }
        } else {
            view.verticalGradient(top: player == players.player ? Colors.primaryDark : Colors.highlightDark, bottom: player == players.player ? Colors.primaryMiddleDark : Colors.highlightMiddleDark)
            
            turnLabel.text = "\([PlayerType.player, PlayerType.local].contains(player) ? "Your" : "\(player.stringValue)'s") Turn"
            
            guard player != .computer,
                  player != .online else { return tipLabel.text = "" }
            
            switch turnType {
            case .lPiece:
                tipLabel.text = "Move your L-piece"
            case .neutralPiece:
                tipLabel.text = "Move your neutral piece, or skip"
            case .waiting:
                tipLabel.text = ""
            }
        }
        
        skipButton.isHidden = turnType != .neutralPiece
        collectionView.reloadData()
    }
    
    func presentMainMenu() {
        self.dismiss(animated: true)
        
        guard let gameMode = gameMode else { return }
        let players = gameMode.players()
        
        BoardManager.shared.currentBoard = nil
        TurnManager.shared.setTurn(nil)
        TurnManager.shared.gameEnded = false
        TutorialManager.shared.reset()
        
        updateViews()
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
                guard TutorialManager.shared.gameBoardConstraints.isEmpty ||
                        TutorialManager.shared.gameBoardConstraints.contains(where: { $0 == pannedCell.index ?? (row: -1, column: -1) }) else { return }
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
                
                if !TutorialManager.shared.pause { TurnManager.shared.progressTurn() }
                updateViews()
                
                if TutorialManager.shared.tutorialActive {
                    coachMarksController.flow.showNext()
                }
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
                        
                        if !TutorialManager.shared.tutorialActive {
                            DispatchQueue.main.async {
                                TurnManager.shared.progressTurn()
                            }
                        }
                        
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
                
                SoundManager.shared.playSound(soundFileName: SoundManager.pieceSoundName)
            }
            
            if TutorialManager.shared.tutorialActive {
                coachMarksController.flow.showNext()
            }
        }
    }
    
    func onMoveComplete(data: [Any]) {
        
    }
    
    @objc func onTutorialMoveMade() {
        coachMarksController.flow.showNext()
        updateViews()
    }
    
    @objc func onMoveMade(notification: Notification) {
        guard let info = notification.userInfo?["info"] as? (board: [[String]], turn: String),
              let username = Auth.auth().currentUser?.displayName else { return }
        
        TurnManager.shared.currentTurn = username == info.turn ? Turn(playerType: .local, turnType: .lPiece) : Turn(playerType: .online, turnType: .lPiece)
        BoardManager.shared.currentBoard = Board(pieces: info.board)
        
        collectionView.reloadData()
        updateViews()
        
        SoundManager.shared.playSound(soundFileName: SoundManager.pieceSoundName)
        
        guard let currentBoard = BoardManager.shared.currentBoard else { return }
        
        _ = TurnManager.shared.checkGameEnded(for: .local, in: currentBoard)
    }
    
    @objc func onTurnChanged() {
        updateViews()
    }
    
    @objc func onMainMenuTapped() {
        presentMainMenu()
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
        updateViews()
    }
}

extension GameBoardViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )
    
        let attributes = [NSAttributedString.Key.font: UIFont(name: "RalewayRoman-Medium", size: 18) ?? UIFont(), NSAttributedString.Key.foregroundColor: Colors.dark ?? UIColor()] as [NSAttributedString.Key : Any]
        
        let hintAttributes = NSMutableAttributedString(string: TutorialManager.shared.gameBoardInstructions[index], attributes: attributes)
        let nextAttributes = NSMutableAttributedString(string: "Next", attributes: attributes)
        
        coachViews.bodyView.hintLabel.attributedText = hintAttributes
        coachViews.bodyView.nextLabel.attributedText = nextAttributes
        
        coachViews.bodyView.separator.isHidden = [4, 5, 6, 8].contains(index)
        coachViews.bodyView.nextLabel.isHidden = [4, 5, 6, 8].contains(index)
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        coachMarksController.overlay.isUserInteractionEnabledInsideCutoutPath = [4, 5, 6].contains(index)
        
        switch index {
        case 0: return coachMarksController.helper.makeCoachMark(for: collectionView)
        case 1:
            let topLeft = collectionView.cellForItem(at: IndexPath(row: 1, section: 0)) ?? UICollectionViewCell()
            let bottomRight = collectionView.cellForItem(at: IndexPath(row: 14, section: 0)) ?? UICollectionViewCell()
            
            return coachMarksController.helper.makeCoachMark(forFrame: topLeft.frame.union(bottomRight.frame), in: collectionView)
        case 2: return coachMarksController.helper.makeCoachMark(for: collectionView.cellForItem(at: IndexPath(row: 0, section: 0)))
        case 3: return coachMarksController.helper.makeCoachMark(for: collectionView.cellForItem(at: IndexPath(row: 15, section: 0)))
        case 4:
            let topLeft = collectionView.cellForItem(at: IndexPath(row: 4, section: 0)) ?? UICollectionViewCell()
            let bottomRight = collectionView.cellForItem(at: IndexPath(row: 13, section: 0)) ?? UICollectionViewCell()
            
            TutorialManager.shared.gameBoardConstraints = [
                (row: 1, column: 0),
                (row: 2, column: 0),
                (row: 3, column: 0),
                (row: 3, column: 1)
            ]
            
            let points: [CGPoint] = [
                CGPoint(x: topLeft.frame.minX-4, y: topLeft.frame.minY-4),
                CGPoint(x: topLeft.frame.minX-4, y: bottomRight.frame.maxY+4),
                CGPoint(x: bottomRight.frame.maxX+4, y: bottomRight.frame.maxY+4),
                CGPoint(x: bottomRight.frame.maxX+4, y: bottomRight.frame.minY-4),
                CGPoint(x: topLeft.frame.maxX+4, y: bottomRight.frame.minY-4),
                CGPoint(x: topLeft.frame.maxX+4, y: topLeft.frame.minY-4)
            ]
            
            let path = UIBezierPath()
            
            path.move(to: collectionView.convert(points[0], to: view))
            for point in points {
                path.addLine(to: collectionView.convert(point, to: view))
            }
            path.close()
            
            let pathMaker = { (frame: CGRect) -> UIBezierPath in
                return path
            }
            
            var coachMark = coachMarksController.helper.makeCoachMark(forFrame: topLeft.frame.union(bottomRight.frame), in: collectionView, cutoutPathMaker: pathMaker)
            coachMark.isUserInteractionEnabledInsideCutoutPath = true
            
            return coachMark
        case 5:
            TutorialManager.shared.gameBoardConstraints = [(row: 3, column: 3)]
            
            let bottomRight = collectionView.cellForItem(at: IndexPath(row: 15, section: 0)) ?? UICollectionViewCell()
            let points = [
                CGPoint(x: bottomRight.frame.minX-4, y: bottomRight.frame.minY-4),
                CGPoint(x: bottomRight.frame.minX-4, y: bottomRight.frame.maxY+4),
                CGPoint(x: bottomRight.frame.maxX+4, y: bottomRight.frame.maxY+4),
                CGPoint(x: bottomRight.frame.maxX+4, y: bottomRight.frame.minY-4)
            ]
            
            let path = UIBezierPath()
            
            path.move(to: collectionView.convert(points[0], to: view))
            for point in points {
                path.addLine(to: collectionView.convert(point, to: view))
            }
            path.close()
            
            let pathMaker = { (frame: CGRect) -> UIBezierPath in
                return path
            }
            
            var coachMark = coachMarksController.helper.makeCoachMark(forFrame: bottomRight.frame, in: collectionView, cutoutPathMaker: pathMaker)
            coachMark.isUserInteractionEnabledInsideCutoutPath = true
            
            
            return coachMark
        case 6:
            TutorialManager.shared.gameBoardConstraints = [(row: 1, column: 3)]
            
            let topRight = collectionView.cellForItem(at: IndexPath(row: 7, section: 0)) ?? UICollectionViewCell()
            let points = [
                CGPoint(x: topRight.frame.minX-4, y: topRight.frame.minY-4),
                CGPoint(x: topRight.frame.minX-4, y: topRight.frame.maxY+4),
                CGPoint(x: topRight.frame.maxX+4, y: topRight.frame.maxY+4),
                CGPoint(x: topRight.frame.maxX+4, y: topRight.frame.minY-4)
            ]
            
            let path = UIBezierPath()
            
            path.move(to: collectionView.convert(points[0], to: view))
            for point in points {
                path.addLine(to: collectionView.convert(point, to: view))
            }
            path.close()
            
            let pathMaker = { (frame: CGRect) -> UIBezierPath in
                return path
            }
            
            var coachMark = coachMarksController.helper.makeCoachMark(forFrame: topRight.frame, in: collectionView, cutoutPathMaker: pathMaker)
            coachMark.isUserInteractionEnabledInsideCutoutPath = true
            
            return coachMark
        case 7, 9: return coachMarksController.helper.makeCoachMark(for: collectionView)
        case 8:
            TurnManager.shared.progressTurn()
             
            return coachMarksController.helper.makeCoachMark(for: collectionView)
        case 10: return coachMarksController.helper.makeCoachMark(pointOfInterest: view.center, in: view)
        default: return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return TutorialManager.shared.gameBoardInstructions.count
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        presentMainMenu()
    }
}
