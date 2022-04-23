//
//  MainMenuViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/21/22.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var localButton: UIButton!
    @IBOutlet weak var computerButton: UIButton!
    @IBOutlet weak var onlineButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - Actions
    
    @IBAction func localButtonTapped(_ sender: Any) {
        presentGameBoard(gameMode: .local)
    }
    
    @IBAction func computerButtonTapped(_ sender: Any) {
        presentGameBoard(gameMode: .computer)
    }
    
    @IBAction func onlineButtonTapped(_ sender: Any) {
        // TODO: - Present Online Modes
        presentGameBoard(gameMode: .online)
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        // TODO: - Present Settings
    }
    
    @IBAction func helpButtonTapped(_ sender: Any) {
        // TODO: - Present Tutorial
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        view.verticalGradient()
        
        localButton.horizontalGradient()
        computerButton.horizontalGradient()
        onlineButton.horizontalGradient()
        
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = Colors.light?.cgColor
        
        localButton.layer.cornerRadius = localButton.frame.height / 4
        computerButton.layer.cornerRadius = computerButton.frame.height / 4
        onlineButton.layer.cornerRadius = onlineButton.frame.height / 4
        settingsButton.layer.cornerRadius = settingsButton.frame.height / 4
        
        localButton.titleLabel?.font = UIFont(name: "RalewayRoman-SemiBold", size: 18)
        computerButton.titleLabel?.font = UIFont(name: "RalewayRoman-SemiBold", size: 18)
        onlineButton.titleLabel?.font = UIFont(name: "RalewayRoman-SemiBold", size: 18)
        settingsButton.titleLabel?.font = UIFont(name: "RalewayRoman-SemiBold", size: 18)
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "RalewayRoman-SemiBold", size: 18) ?? UIFont(), NSAttributedString.Key.foregroundColor: Colors.light ?? UIColor()] as [NSAttributedString.Key : Any]
        
        let localAttributes = NSMutableAttributedString(string: "Local", attributes: attributes)
        localButton.setAttributedTitle(localAttributes, for: .normal)
        
        let computerAttributes = NSMutableAttributedString(string: "Computer", attributes: attributes)
        computerButton.setAttributedTitle(computerAttributes, for: .normal)
        
        let onlineAttributes = NSMutableAttributedString(string: "Online", attributes: attributes)
        onlineButton.setAttributedTitle(onlineAttributes, for: .normal)
        
        let settingsAttributes = NSMutableAttributedString(string: "Settings", attributes: attributes)
        settingsButton.setAttributedTitle(settingsAttributes, for: .normal)
    }
    
    func presentGameBoard(gameMode: GameMode) {
        guard let gameBoardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameBoard") as? GameBoardViewController else { return }
        
        gameBoardViewController.gameMode = gameMode
        
        gameBoardViewController.modalPresentationStyle = .fullScreen
        self.present(gameBoardViewController, animated: true)
    }
}
