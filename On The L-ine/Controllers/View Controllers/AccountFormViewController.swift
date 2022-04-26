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
        selected = signInButton
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        selected = signUpButton
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        containerView.verticalGradient(top: Colors.primaryMiddleDark, bottom: Colors.primary)
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = containerView.frame.height / 18
        
        logoImageView.image = UIImage(named: "AppIcon")
        
        usernameTextField.setupView()
        passwordTextField.setupView()
        
        selected = signInButton
        submitButton.horizontalGradient()
    }
    
    func updateButtons(selected: UIButton, notSelected: UIButton) {
        submitButton.customButton(titleText: signInButton == self.selected ? "Sign In" : "Sign Up", titleColor: Colors.light)
        
        selected.customTextButton(titleText: selected.titleLabel?.text ?? "", titleColor: Colors.light)
        notSelected.customTextButton(titleText: notSelected.titleLabel?.text ?? "", titleColor: Colors.light?.withAlphaComponent(0.5))
    }
}
