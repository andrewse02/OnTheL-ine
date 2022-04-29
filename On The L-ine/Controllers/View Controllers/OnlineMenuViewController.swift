//
//  OnlineMenuViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/28/22.
//

import UIKit

class OnlineMenuViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var quickMatchButton: UIButton!
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var joinRoomButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - Actions
    
    @IBAction func quickMatchTapped(_ sender: Any) {
        WebSocketManager.shared.joinQueue { data in
            guard let queueViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Queue") as? QueueViewController else { return }
            
            queueViewController.modalPresentationStyle = .fullScreen
            self.present(queueViewController, animated: true)
        }
    }
    
    @IBAction func createRoomTapped(_ sender: Any) {
        WebSocketManager.shared.createRoom { data in
            guard let roomCode = (data.first as? NSDictionary)?["match_code"] as? String,
                  let createRoomViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateRoom") as? CreateRoomViewController else { return }
            
            createRoomViewController.modalPresentationStyle = .fullScreen
            createRoomViewController.roomCode = roomCode
            self.present(createRoomViewController, animated: true)
        }
    }
    
    @IBAction func joinRoomTapped(_ sender: Any) {
    }
    
    @IBAction func friendsTapped(_ sender: Any) {
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        view.verticalGradient()
        
        quickMatchButton.horizontalGradient()
        friendsButton.horizontalGradient()
        
        quickMatchButton.customButton(titleText: "Quick Match", titleColor: Colors.light)
        friendsButton.customButton(titleText: "Friends", titleColor: Colors.light)
    }

}
