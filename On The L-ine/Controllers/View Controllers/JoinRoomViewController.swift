//
//  JoinRoomViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/29/22.
//

import UIKit
import FirebaseAuth

class JoinRoomViewController: UIViewController {
    
    // MARK: - Properties
    
    var players: [String] = [] {
        didSet {
            updateRoomPlayers()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var codeTextField: CustomTextField!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var inRoomLabel: UILabel!
    @IBOutlet weak var playersLabel: UILabel!
    
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        NotificationManager.observeMatchStart(observer: self, selector: #selector(onMatchStart(notification:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let roomCode = DeepLinkManager.roomCode {
            joinRoom(roomCode: roomCode)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func backTapped(_ sender: Any) {
        DeepLinkManager.roomCode = nil
        self.dismiss(animated: true)
    }
    
    @IBAction func joinTapped(_ sender: Any) {
        guard let roomCode = codeTextField.text,
              roomCode.count == 6 else { return }
        
        joinRoom(roomCode: roomCode)
    }
    
    @IBAction func qrCodeTapped(_ sender: Any) {
        
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        codeTextField.setupView()
        joinButton.customButton(titleText: "Join", titleColor: Colors.light, backgroundColor: Colors.green)
    }
    
    func updateRoomPlayers() {
        guard !players.isEmpty else {
            [inRoomLabel, playersLabel].forEach({ $0?.isHidden = true })
            return
        }
        
        playersLabel.text = players.first
        [inRoomLabel, playersLabel].forEach({ $0?.isHidden = false })
    }
    
    func joinRoom(roomCode: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            WebSocketManager.shared.joinRoom(roomCode: roomCode) { data in
                DispatchQueue.main.async {
                    guard let opponent = (data.first as? NSDictionary)?["opponent"] as? String else {
                        let toast = Toast.default(image: UIImage(systemName: "x.circle.fill") ?? UIImage(), title: "Could not join room!", backgroundColor: Colors.highlight ?? UIColor(), textColor: Colors.light ?? UIColor())
                        return toast.show(haptic: .error)
                    }
                    
                    self.players.append(opponent)
                }
            }
        }
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
