//
//  MatchFoundViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/28/22.
//

import UIKit
import FirebaseAuth

class MatchFoundViewController: UIViewController {
    
    // MARK: - Properties
    
    var mainMenu = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        NotificationManager.observeMatchStart(observer: self, selector: #selector(onStart(notification:)))
        NotificationManager.observeMainMenu(observer: self, selector: #selector(onMainMenu))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if mainMenu {
            mainMenu = false
            self.presentingViewController?.presentingViewController?.dismiss(animated: true)
        }
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        guard let player = OnlineMatchManager.shared.player,
              let opponent = OnlineMatchManager.shared.opponent else { return }
        
        playerLabel.text = player
        opponentLabel.text = opponent
    }
    
    func presentMainMenu() {
        mainMenu = true
        
        BoardManager.shared.currentBoard = nil
        TurnManager.shared.setTurn(nil)
        TurnManager.shared.gameEnded = false
        TutorialManager.shared.reset()
    }
    
    @objc func onStart(notification: Notification) {
        guard let gameBoardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameBoard") as? GameBoardViewController,
              let info = notification.userInfo?["info"] as? (board: [[String]], turn: String),
              let username = Auth.auth().currentUser?.displayName else { return }
        
        gameBoardViewController.gameMode = .online
        TurnManager.shared.currentTurn = username == info.turn ? Turn(playerType: .local, turnType: .lPiece) : Turn(playerType: .online, turnType: .lPiece)
        BoardManager.shared.currentBoard = Board(pieces: info.board)
        
        gameBoardViewController.modalPresentationStyle = .fullScreen
        self.present(gameBoardViewController, animated: true)
    }
    
    @objc func onMainMenu() {
        presentMainMenu()
    }
}
