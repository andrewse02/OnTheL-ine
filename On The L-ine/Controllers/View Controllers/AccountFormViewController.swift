//
//  AccountFormViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/26/22.
//

import UIKit
import FirebaseAuth

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
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupGradients()
    }
    
    // MARK: - Actions
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
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
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let loadingScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Loading") as? LoadingViewController else { return }
        
        loadingScreen.modalPresentationStyle = .overCurrentContext
        self.present(loadingScreen, animated: true)
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            self.handleSubmit(usernameText: usernameText, passwordText: passwordText) { shouldDismiss, errorText in
                DispatchQueue.main.async {
                    loadingScreen.dismiss(animated: true) {
                        if shouldDismiss {
                            self.dismiss(animated: true )
                        } else {
                            guard let errorText = errorText else { return }

                            let toast = Toast.default(image: UIImage(systemName: "x.circle.fill") ?? UIImage(), title: errorText, backgroundColor: Colors.highlight ?? UIColor(), textColor: Colors.light ?? UIColor())
                            toast.show(haptic: .error)
                        }
                    }
                }
            }
        }
    }
    
    func handleSubmit(usernameText: String, passwordText: String, completion: @escaping (Bool, String?) -> Void) {
        var valid = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if usernameText.isEmpty {
                self.usernameTextField.layer.borderColor = Colors.highlight?.cgColor
                valid = false
            } else {
                self.usernameTextField.layer.borderColor = Colors.lightDark?.cgColor
            }
            
            if passwordText.count < 8 {
                self.passwordTextField.layer.borderColor = Colors.highlight?.cgColor
                valid = false
            } else { self.passwordTextField.layer.borderColor = Colors.lightDark?.cgColor }
        }
        
        if valid {
            if selected == signInButton {
                AuthManager.signIn(username: usernameText, password: passwordText) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let token):
                        AuthManager.signIn(token: token) { result, error in
                            if let error = error {
                                print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                            } else {
                                guard result?.user != nil else { return }
                                
                                completion(true, nil)
                            }
                        }
                    case .failure(let error):
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
                            errorText = "Username or password is incorrect!"

                            DispatchQueue.main.async {
                                self.usernameTextField.layer.borderColor = Colors.highlight?.cgColor
                                self.passwordTextField.layer.borderColor = Colors.highlight?.cgColor
                            }
                        }
                            
                        print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                        
                        completion(false, errorText)
                    }
                }
            } else if selected == signUpButton {
                AuthManager.signUp(username: usernameText, password: passwordText) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let token):
                        AuthManager.signIn(token: token) { result, error in
                            if let error = error {
                                print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                            } else {
                                guard result?.user != nil else { return }
                                
                                Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { token, error in
                                    if let error = error {
                                        print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                                    }
                                    
                                    AuthManager.setDisplayName(token: token!) { error in
                                        if let error = error {
                                            print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                                        } else {
                                            Auth.auth().currentUser?.reload(completion: { error in
                                                if let error = error {
                                                    print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                                                } else {
                                                    AuthManager.currentUser = Auth.auth().currentUser
                                                }
                                            })
                                        }
                                    }
                                })
                                
                                completion(true, nil)
                            }
                        }
                    case .failure(let error):
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
                            errorText = "Username is taken!"
                            
                            DispatchQueue.main.async {
                                self.usernameTextField.layer.borderColor = Colors.highlight?.cgColor
                            }
                        }
                        
                        print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)")
                        
                        completion(false, errorText)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = containerView.frame.height / 18
        containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        logoImageView.image = UIImage(named: "Logo")
        logoImageView.layer.cornerRadius = logoImageView.frame.height / 6.4
        
        usernameTextField.setupView()
        passwordTextField.setupView()
        
        self.underline = CALayer()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
    }
    
    func setupGradients() {
        containerView.verticalGradient(top: Colors.primaryMiddleDark, bottom: Colors.primary)
        submitButton.horizontalGradient()
        selected = signInButton
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
