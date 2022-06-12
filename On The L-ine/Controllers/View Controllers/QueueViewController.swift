//
//  QueueViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/28/22.
//

import UIKit
import FirebaseAuth

class QueueViewController: UIViewController {

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationManager.observeMatchFound(observer: self, selector: #selector(foundMatch(notification:)))
    }
    
    // MARK: - Actions
    
    @IBAction func backTapped(_ sender: Any) {
        WebSocketManager.shared.leaveQueue()
        
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Functions
    
    @objc func foundMatch(notification: Notification) {
        guard let opponent = notification.userInfo?["opponent"] as? String,
              let currentUser = AuthManager.currentUser else { return }
        
        OnlineMatchManager.shared.player = currentUser.displayName
        OnlineMatchManager.shared.opponent = opponent
        
        presentMatchFound()
    }
    
    func presentMatchFound() {
        guard let matchFoundViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MatchFound") as? MatchFoundViewController else { return }
        
        matchFoundViewController.modalPresentationStyle = .fullScreen
        self.present(matchFoundViewController, animated: true)
    }
}
