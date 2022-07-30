//
//  MainMenuViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/21/22.
//

import UIKit
import Firebase
import FirebaseAuth
import BLTNBoard
import Instructions

class MainMenuViewController: UIViewController {
    
    // MARK: - Properties
    
    var handle: AuthStateDidChangeListenerHandle?
    let coachMarksController = CoachMarksController()
    
    // MARK: - Outlets
    
    @IBOutlet weak var localButton: UIButton!
    @IBOutlet weak var computerButton: UIButton!
    @IBOutlet weak var onlineButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    
    @IBOutlet weak var musicButton: UIButton!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({ [weak self] auth, user in
            guard let self = self else { return }
            
            AuthManager.currentUser = user != nil ? user : nil
            self.updateAccountButton()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if DeepLinkManager.roomCode != nil {
            connectOnline()
        }
        
        handleLaunch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
        
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
        connectOnline()
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        // TODO: - Present Settings
    }
    
    @IBAction func musicButtonTapped(_ sender: Any) {
        guard SoundManager.shared.musicEnabled != nil else { return }
        
        SoundManager.shared.musicEnabled!.toggle()
        musicButton.tintColor = SoundManager.shared.musicEnabled! ? Colors.light : Colors.lightDarkTransparent
    }
    
    @IBAction func helpButtonTapped(_ sender: Any) {
        startTutorial()
    }
    
    @IBAction func accountButtonTapped(_ sender: Any) {
        if AuthManager.currentUser != nil {
            DispatchQueue.global(qos: .userInteractive).async {
                try? Auth.auth().signOut()
                AuthManager.currentUser = nil
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.updateAccountButton()
                }
            }
        } else {
            presentAccountForm()
        }
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
        view.verticalGradient()
        
        localButton.horizontalGradient()
        computerButton.horizontalGradient()
        onlineButton.horizontalGradient()
        
        localButton.customButton(titleText: "Local", titleColor: Colors.light)
        computerButton.customButton(titleText: "Computer", titleColor: Colors.light)
        onlineButton.customButton(titleText: "Online", titleColor: Colors.light)
        
        settingsButton.customOutlinedButton(titleText: "Settings", titleColor: Colors.light, borderColor: Colors.light)
        updateAccountButton()
        
        musicButton.tintColor = SoundManager.shared.musicEnabled! ? Colors.light : Colors.lightDarkTransparent
    }
    
    func handleLaunch() {
        let hasLaunched = UserDefaults.standard.bool(forKey: "HasLaunched")
        
        if UserDefaults.standard.string(forKey: "LastVersion") != Bundle.main.releaseVersionNumberPretty {
            if hasLaunched { AlertCardManager.changelog.showBulletin(above: self) }
            
            UserDefaults.standard.set(Bundle.main.releaseVersionNumberPretty, forKey: "LastVersion")
        }
        
        if !hasLaunched {
            startTutorial()
            UserDefaults.standard.set(true, forKey: "HasLaunched")
        }
    }
    
    func updateAccountButton() {
        if AuthManager.currentUser != nil {
            accountButton.customButton(titleText: "Sign Out", titleColor: Colors.light, backgroundColor: Colors.highlight, borderColor: Colors.light)
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
    
    func connectOnline() {
        if AuthManager.currentUser == nil {
            let toast = Toast.default(image: UIImage(systemName: "x.circle.fill") ?? UIImage(), title: "You must be logged in to play online!", backgroundColor: Colors.highlight ?? UIColor(), textColor: Colors.light ?? UIColor())
            return toast.show(haptic: .error)
        }
        
        guard let loadingScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Loading") as? LoadingViewController else { return }
        
        loadingScreen.modalPresentationStyle = .overCurrentContext
        self.present(loadingScreen, animated: true)
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            WebSocketManager.shared.connect { data, ack in
                DispatchQueue.main.async {
                    loadingScreen.dismiss(animated: true) {
                        self.presentOnlineMenu()
                    }
                }
            }
        }
    }
    
    func startTutorial() {
        let tutorial = AlertCardManager.tutorial { item in
            item.manager?.dismissBulletin()
            
            TutorialManager.shared.tutorialActive = true
            
            self.coachMarksController.start(in: .window(over: self))
        }
        AlertCardManager.manager = BLTNItemManager(rootItem: tutorial)
        AlertCardManager.manager!.showBulletin(above: self)
    }
}

extension MainMenuViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )
        
        coachViews.bodyView.hintLabel.text = TutorialManager.shared.mainMenuInstructions[index]
        coachViews.bodyView.nextLabel.text = "Next"
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0: return coachMarksController.helper.makeCoachMark(pointOfInterest: view.center, in: view)
        case 1: return coachMarksController.helper.makeCoachMark(forFrame: localButton.frame.union(computerButton.frame.union(onlineButton.frame)), in: view)
        case 2: return coachMarksController.helper.makeCoachMark(for: localButton)
        case 3: return coachMarksController.helper.makeCoachMark(for: computerButton)
        case 4: return coachMarksController.helper.makeCoachMark(for: onlineButton)
        default: return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return TutorialManager.shared.mainMenuInstructions.count
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        if !skipped {
            presentGameBoard(gameMode: .tutorial)
        }
    }
}
