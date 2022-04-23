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
        
        localButton.customButton(titleText: "Local", titleColor: Colors.light)
        computerButton.customButton(titleText: "Computer", titleColor: Colors.light)
        onlineButton.customButton(titleText: "Online", titleColor: Colors.light)
        settingsButton.customOutlinedButton(titleText: "Settings", titleColor: Colors.light, borderColor: Colors.light)
    }
    
    func presentGameBoard(gameMode: GameMode) {
        guard let gameBoardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameBoard") as? GameBoardViewController else { return }
        
        gameBoardViewController.gameMode = gameMode
        
        gameBoardViewController.modalPresentationStyle = .fullScreen
        self.present(gameBoardViewController, animated: true)
    }
}
