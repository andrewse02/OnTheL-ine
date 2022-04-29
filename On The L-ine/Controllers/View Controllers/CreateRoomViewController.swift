//
//  CreateRoomViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/28/22.
//

import UIKit

class CreateRoomViewController: UIViewController {
    
    // MARK: - Properties
    
    var roomCode: String?
    var players: [String]?
    
    private let roomCodeText = "Room Code: "
    
    // MARK: - Outlets
    
    @IBOutlet weak var roomCodeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var inLobbyLabel: UILabel!
    @IBOutlet weak var playersLabel: UILabel!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: - Actions
    
    @IBAction func friendsTapped(_ sender: Any) {
    }
    
    @IBAction func messageTapped(_ sender: Any) {
    }
    
    @IBAction func qrCodeTapped(_ sender: Any) {
    }
    
    @IBAction func startTapped(_ sender: Any) {
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        guard let roomCode = roomCode else { return }
        
        roomCodeLabel.text = roomCodeText + roomCode
        startButton.customButton(titleText: "Start", titleColor: Colors.light, backgroundColor: Colors.green)
    }
    
    func updateRoomPlayers() {
        guard let players = players,
              !players.isEmpty else {
            [startButton, inLobbyLabel, playersLabel].forEach({ $0?.isHidden = true })
            return
        }
        
        playersLabel.text = players.first
        [startButton, inLobbyLabel, playersLabel].forEach({ $0?.isHidden = false })
    }

}
