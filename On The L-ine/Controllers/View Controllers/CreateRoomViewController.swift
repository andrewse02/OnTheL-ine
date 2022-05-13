//
//  CreateRoomViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/28/22.
//

import UIKit
import FirebaseAuth

class CreateRoomViewController: UIViewController {
    
    // MARK: - Properties
    
    var roomCode: String?
    var players: [String] = [] {
        didSet {
            updateRoomPlayers()
        }
    }
    
    private let roomCodeText = "Room Code: "
    
    // MARK: - Outlets
    
    @IBOutlet weak var roomCodeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var inRoomLabel: UILabel!
    @IBOutlet weak var playersLabel: UILabel!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        NotificationManager.observePlayerJoinRoom(observer: self, selector: #selector(onRoomJoin(notification:)))
        NotificationManager.observeMatchStart(observer: self, selector: #selector(onMatchStart(notification:)))
    }
    
    // MARK: - Actions
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func friendsTapped(_ sender: Any) {
    }
    
    @IBAction func messageTapped(_ sender: Any) {
    }
    
    @IBAction func qrCodeTapped(_ sender: Any) {
    }
    
    @IBAction func startTapped(_ sender: Any) {
        WebSocketManager.shared.startGame()
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        guard let roomCode = roomCode else { return }
        
        roomCodeLabel.text = roomCodeText + roomCode
        startButton.customButton(titleText: "Start", titleColor: Colors.light, backgroundColor: Colors.green)
    }
    
    func updateRoomPlayers() {
        guard !players.isEmpty else {
            [startButton, inRoomLabel, playersLabel].forEach({ $0?.isHidden = true })
            return
        }
        
        playersLabel.text = players.first
        [startButton, inRoomLabel, playersLabel].forEach({ $0?.isHidden = false })
    }

    @objc func onRoomJoin(notification: Notification) {
        guard let opponent = notification.userInfo?["opponent"] as? String else { return }
        
        players.append(opponent)
    }
    
    @objc func onMatchStart(notification: Notification) {
        guard let gameBoardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameBoard") as? GameBoardViewController,
              let info = notification.userInfo?["info"] as? (board: [[String]], turn: String),
              let username = Auth.auth().currentUser?.displayName else { return }
        
        gameBoardViewController.gameMode = .online
        TurnManager.shared.currentTurn = username == info.turn ? Turn(playerType: .local, turnType: .lPiece) : Turn(playerType: .online, turnType: .lPiece)
        BoardManager.shared.currentBoard = Board(pieces: info.board)
        
        gameBoardViewController.modalPresentationStyle = .fullScreen
        self.present(gameBoardViewController, animated: true)
    }
}
