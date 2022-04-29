//
//  MainMenuViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/21/22.
//

import UIKit
import Firebase
import FirebaseAuth

class MainMenuViewController: UIViewController {
    
    // MARK: - Properties
    
    var handle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Outlets
    
    @IBOutlet weak var localButton: UIButton!
    @IBOutlet weak var computerButton: UIButton!
    @IBOutlet weak var onlineButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            AuthManager.currentUser = user != nil ? user : nil
            self.updateAccountButton()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func localButtonTapped(_ sender: Any) {
        presentGameBoard(gameMode: .local)
    }
    
    @IBAction func computerButtonTapped(_ sender: Any) {
        presentGameBoard(gameMode: .computer)
    }
    
    @IBAction func onlineButtonTapped(_ sender: Any) {
        WebSocketManager.shared.connect { data, ack in
            print("Connected")
            self.presentOnlineMenu()
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        // TODO: - Present Settings
    }
    
    @IBAction func helpButtonTapped(_ sender: Any) {
        // TODO: - Present Tutorial
    }
    
    @IBAction func accountButtonTapped(_ sender: Any) {
        if AuthManager.currentUser != nil {
            DispatchQueue.global(qos: .userInitiated).async {
                try? Auth.auth().signOut()
                AuthManager.currentUser = nil
                
                DispatchQueue.main.async {
                    self.updateAccountButton()
                }
            }
        } else {
            presentAccountForm()
        }
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
        updateAccountButton()
    }
    
    func updateAccountButton() {
        if AuthManager.currentUser != nil {
            accountButton.customButton(titleText: "Sign Out", titleColor: Colors.light, backgroundColor: Colors.highlight)
        } else {
            accountButton.customOutlinedButton(titleText: "Sign In/Sign Up", titleColor: Colors.light, borderColor: Colors.light)
        }
    }
    
    func presentGameBoard(gameMode: GameMode) {
        guard let gameBoardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameBoard") as? GameBoardViewController else { return }
        
        gameBoardViewController.gameMode = gameMode
        
        gameBoardViewController.modalPresentationStyle = .fullScreen
        self.present(gameBoardViewController, animated: true)
    }
    
    func presentAccountForm() {
        guard let accountFormViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountForm") as? AccountFormViewController else { return }
        
        accountFormViewController.modalPresentationStyle = .fullScreen
        self.present(accountFormViewController, animated: true)
    }
    
    func presentOnlineMenu() {
        guard let onlineMenuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnlineMenu") as? OnlineMenuViewController else { return }
        
        onlineMenuViewController.modalPresentationStyle = .fullScreen
        self.present(onlineMenuViewController, animated: true)
    }
}
