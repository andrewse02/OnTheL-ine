//
//  MatchFoundViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/28/22.
//

import UIKit

class MatchFoundViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        guard let player = OnlineMatchManager.shared.player,
              let opponent = OnlineMatchManager.shared.opponent else { return }
        
        playerLabel.text = player
        opponentLabel.text = opponent
    }

}
