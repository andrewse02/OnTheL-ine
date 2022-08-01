//
//  CreateRoomViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/28/22.
//

import UIKit
import MessageUI
import FirebaseAuth

class CreateRoomViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
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
    @IBOutlet weak var copyLabel: UILabel!
    
    @IBOutlet weak var qrCodeImage: UIImageView!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupGradients()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Actions
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func friendsTapped(_ sender: Any) {
    }
    
    @IBAction func messageTapped(_ sender: Any) {
        guard let roomCode = roomCode else { return }
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Join my room in On The L-ine!\notl://join/\(roomCode)"
            controller.messageComposeDelegate = self
            self.present(controller, animated: true)
        } else {
            let toast = Toast.default(image: UIImage(systemName: "x.circle.fill") ?? UIImage(), title: "Text messages are not enabled on this device!", backgroundColor: Colors.highlight ?? UIColor(), textColor: Colors.light ?? UIColor())
            toast.show(haptic: .error)
        }
    }
    
    @IBAction func qrCodeTapped(_ sender: Any) {
        guard let roomCode = roomCode,
              qrCodeImage.image == nil else { return }
        
        qrCodeImage.image = QRCodeManager.generateQRCodeImage(from: "otl://join/\(roomCode)")
        qrCodeImage.isHidden = false
    }
    
    @IBAction func startTapped(_ sender: Any) {
        WebSocketManager.shared.startGame()
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        guard let roomCode = roomCode else { return }
        
        roomCodeLabel.text = roomCodeText + roomCode
        startButton.customButton(titleText: "Start", titleColor: Colors.light, backgroundColor: Colors.green)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapToCopy))
        roomCodeLabel.addGestureRecognizer(tapGestureRecognizer)
        copyLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupGradients() {
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
    
    @objc func onTapToCopy() {
        guard let roomCode = roomCode else { return }

        UIPasteboard.general.string = roomCode
        
        let toast = Toast.default(image: UIImage(systemName: "checkmark.circle.fill") ?? UIImage(), title: "Code Copied!", backgroundColor: Colors.green ?? UIColor(), textColor: Colors.light ?? UIColor())
        return toast.show(haptic: .success)
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
    
    // MARK: - MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true)
    }
}
