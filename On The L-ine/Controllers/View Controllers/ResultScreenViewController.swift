//
//  ResultScreenViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 5/5/22.
//

import UIKit

class ResultScreenViewController: UIViewController {
    
    // MARK: - Properties
    
    var didWin: Bool = true
    var gameMode: GameMode?
    
    var labelCenter: CGPoint = CGPoint.zero
    var stackCenter: CGPoint = CGPoint.zero
    
    // MARK: - Outlets
    
    @IBOutlet weak var blur: UIView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var endOptionsStackView: UIStackView!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        animateViews()
    }
    
    // MARK: - Actions
    
    @IBAction func mainMenuTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            NotificationManager.postMainMenu()
        }
    }
    
    @IBAction func playAgainTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            NotificationManager.postPlayAgain()
        }
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        guard let gameMode = gameMode else { return }
        
        labelCenter = resultLabel.center
        resultLabel.center.y = -100
        resultLabel.font = resultLabel.font.withSize(gameMode != .local ? 48 : 36)
        resultLabel.text = gameMode != .local ? didWin ? "👑 You Win! 👑" : "👎 You Lost! 👎" : didWin ? "👑 Player 1 Wins! 👑" : "👑 Player 2 Wins! 👑"
        resultLabel.textColor = didWin ? Colors.primary ?? UIColor() : Colors.highlight ?? UIColor()
        
        stackCenter = endOptionsStackView.center
        endOptionsStackView.center.y = blur.frame.height + 100
        mainMenuButton.customButton(titleText: "Main Menu", titleColor: Colors.dark)
        playAgainButton.customButton(titleText: "Play Again", titleColor: Colors.dark)
    }
    
    func animateViews() {
        UIView.animate(withDuration: 1.5, delay: 0.25, options: [], animations: { [weak self] in
            guard let self = self else { return }
            
            self.resultLabel.center = self.labelCenter
            self.endOptionsStackView.center = self.stackCenter
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            
            
        })
    }
}
