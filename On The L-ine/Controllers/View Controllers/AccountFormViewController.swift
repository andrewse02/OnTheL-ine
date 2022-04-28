//
//  AccountFormViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/26/22.
//

import UIKit

class AccountFormViewController: UIViewController {
    
    // MARK: - Properties
    
    var selected: UIButton? {
        didSet {
            updateButtons(selected: selected!, notSelected: selected == signInButton ? signUpButton : signInButton)
        }
    }
    
    var underline: CALayer?

    // MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    // MARK: - Actions
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if selected == signInButton { return }
        
        selected = signInButton
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        if selected == signUpButton { return }
        
        selected = signUpButton
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let usernameText = usernameTextField.text,
              let passwordText = passwordTextField.text else { return }
        
        var valid = true
        
        if usernameText.isEmpty {
            usernameTextField.layer.borderColor = Colors.highlight?.cgColor
            valid = false
        } else {
            usernameTextField.layer.borderColor = Colors.lightDark?.cgColor
        }
        
        if passwordText.count < 8 {
            passwordTextField.layer.borderColor = Colors.highlight?.cgColor
            valid = false
        } else { passwordTextField.layer.borderColor = Colors.lightDark?.cgColor }
        
        if valid {
            if selected == signInButton {
                AuthManager.signIn(username: usernameText, password: passwordText) { result in
                    switch result {
                    case .success(let token):
                        AuthManager.signIn(token: token) { result, error in
                            if let error = error {
                                print(error)
                            } else {
                                guard result?.user != nil else { return print("User not there? Who knows why honestly.") }
                                self.dismiss(animated: true)
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            } else if selected == signUpButton {
                AuthManager.signUp(username: usernameText, password: passwordText) { result in
                    switch result {
                    case .success(let token):
                        AuthManager.signIn(token: token) { result, error in
                            if let error = error {
                                print(error)
                            } else {
                                guard result?.user != nil else { return print("User not there? Who knows why honestly.") }
                                self.dismiss(animated: true)
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        containerView.verticalGradient(top: Colors.primaryMiddleDark, bottom: Colors.primary)
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = containerView.frame.height / 18
        
        logoImageView.image = UIImage(named: "AppIcon")
        
        usernameTextField.setupView()
        passwordTextField.setupView()
        
        
        self.underline = CALayer()
        selected = signInButton
        
        submitButton.horizontalGradient()
        
        view.keyboardLayoutGuide.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func updateButtons(selected: UIButton, notSelected: UIButton) {
        submitButton.customButton(titleText: signInButton == self.selected ? "Sign In" : "Sign Up", titleColor: Colors.light)
        
        selected.customTextButton(titleText: selected.titleLabel?.text ?? "", titleColor: Colors.light)
        notSelected.customTextButton(titleText: notSelected.titleLabel?.text ?? "", titleColor: Colors.light?.withAlphaComponent(0.5))
        
        selected.addUnderline(underline: underline ?? CALayer())
    }
}
