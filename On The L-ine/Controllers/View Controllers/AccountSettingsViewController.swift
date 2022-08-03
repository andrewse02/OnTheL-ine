//
//  AccountSettingsViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 8/1/22.
//

import UIKit
import FirebaseAuth
import BLTNBoard

class AccountSettingsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradients()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupGradients()
    }
    
    // MARK: - Actions
    
    @IBAction func signOutTapped(_ sender: Any) {
        DispatchQueue.global(qos: .userInteractive).async {
            try? Auth.auth().signOut()
            AuthManager.currentUser = nil
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
        let deleteAlert = AlertCardManager.deleteAccount { item in
            item.manager?.dismissBulletin()
            
            let alertController = UIAlertController(title: "Really? Delete Account?", message: "Last chance, are you sure? We'd hate to see you go.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                alertController.dismiss(animated: true)
            }))
            alertController.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { _ in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    guard let self = self else { return }
                    
                    Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { token, error in
                        if let error = error {
                            print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                        }
                        
                        AuthManager.deleteAccount(token: token!) { [weak self] error in
                            if let error = error {
                                print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                                
                                var errorText = ""
                                
                                switch error {
                                case .invalidURL:
                                    errorText = "Provided URL was invalid!"
                                case .noData, .invalidResponse:
                                    errorText = "Unexpected response recieved!"
                                case .invalidRequest, .internalServerError, .userNotLoggedIn, .unableToDecode: break
                                case .thrownError(let error):
                                    errorText = "Error: \(error.localizedDescription)"
                                case .invalidCredentials:
                                    errorText = "You are unauthorized for this request!"
                                }
                                
                                let toast = Toast.default(image: UIImage(systemName: "x.circle.fill") ?? UIImage(), title: errorText, backgroundColor: Colors.highlight ?? UIColor(), textColor: Colors.light ?? UIColor())
                                return toast.show(haptic: .error)
                            } else {
                                try? Auth.auth().signOut()
                                AuthManager.currentUser = nil
                            }
                        }
                    })
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.dismiss(animated: true)
                    }
                }
            }))
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.present(alertController, animated: true)
            }
        }
        AlertCardManager.manager = BLTNItemManager(rootItem: deleteAlert)
        AlertCardManager.manager!.showBulletin(above: self)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        guard let username = Auth.auth().currentUser?.displayName else { return }
        
        usernameLabel.text = username
    }
    
    func setupGradients() {
        view.verticalGradient()
        
        signOutButton.customButton(titleText: "Sign Out", titleColor: Colors.light, backgroundColor: Colors.highlight, borderColor: Colors.light)
        deleteAccountButton.customButton(titleText: "Delete Account", titleColor: Colors.light, backgroundColor: Colors.highlight, borderColor: Colors.light)
    }
    
}
