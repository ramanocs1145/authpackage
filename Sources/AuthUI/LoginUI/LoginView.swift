//
//  LoginView.swift
//
//
//  Created by Ramanathan on 01/08/24.
//

import UIKit

public protocol LoginViewDelegate: AnyObject {
    func showValidationAlert(errorMessage: String)
    func showForgotPasswordSection()
    func showRegisterForm()
    func makeRedirectToHomeSection(_ accessToken: String)
}

public class LoginView: UIView {
    
    // UI Elements
    private var containerView: UIView!
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!
    private var forgotPasswordButton: UIButton!
    private var loginButton: UIButton!
    private var registerButton: UIButton!

    public weak var delegate: LoginViewDelegate?
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // View background color
        self.backgroundColor = .systemPurple

        // Setup UI Elements
        setupContainerView()
        setupEmailTextField()
        setupPasswordTextField()
        setupForgotPasswordButton()
        setupLoginButton()
        setupRegisterButton()

        // Add UI Elements to the View
        self.addSubview(containerView)
        
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(forgotPasswordButton)
        containerView.addSubview(loginButton)
        
        self.addSubview(registerButton)

        // Set up constraints
        setupConstraints()
    }
    
    // Setup ContainerView TextField
    private func setupContainerView() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        
        self.containerView = containerView
    }
    
    // Setup Email TextField
    private func setupEmailTextField() {
        let emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        self.emailTextField = emailTextField
    }

    // Setup Password TextField
    private func setupPasswordTextField() {
        let passwordTextField = UITextField()
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        self.passwordTextField = passwordTextField
    }

    // Setup Login Button
    private func setupLoginButton() {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Sign-In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.backgroundColor = .systemPink
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        
        self.loginButton = loginButton
    }
    
    // Setup Forgot Password Button
    private func setupForgotPasswordButton() {
        let forgotPasswordButton = UIButton(type: .system)
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.setTitleColor(.white, for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.titleLabel?.textAlignment = .right
        
        self.forgotPasswordButton = forgotPasswordButton
    }

    // Setup Register Button
    private func setupRegisterButton() {
        let registerButton = UIButton(type: .system)
        registerButton.setTitle("Sign-Up", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.backgroundColor = .systemPink
        registerButton.layer.cornerRadius = 5
        registerButton.layer.masksToBounds = true
        
        self.registerButton = registerButton
    }

    // Login Button Action
    @objc private func handleLogin() {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        // Handle login logic here (validation, API call, etc.)
        debugPrint("Username: \(email ?? ""), Password: \(password ?? "")")
        guard let emailUW = email, !emailUW.isEmpty, let passwordUW = password, !passwordUW.isEmpty else {
            DispatchQueue.main.async {
                self.delegate?.showValidationAlert(errorMessage: "Empty Validation")
            }
            return
        }
        guard emailUW.isValidEmail() else {
            DispatchQueue.main.async {
                self.delegate?.showValidationAlert(errorMessage: "Enter a valid email")
            }
            return
        }
        let authService = AuthService(network: NetworkFactory())
        let credentials = AuthDataRepresentation(email: emailUW, password: passwordUW)
        authService.fetchAuthServiceRequest(credentialsData: credentials, 
                                            delegate: nil) { result in
            switch result {
            case .success(let response):
                // Handle successful response
                debugPrint("Received authentication response: \(response)")
                    
                // Store the logged user auth model
                let _ = KeychainHelper.store(model: response, key: Keys.userAuthModelKey)
                
                DispatchQueue.main.async {
                    self.delegate?.makeRedirectToHomeSection(response.accessToken ?? "")
                }
            case .failure(let error):
                // Handle error
                debugPrint("Failed with error: \(error)")
                DispatchQueue.main.async {
                    self.delegate?.showValidationAlert(errorMessage: error.errorMessage)
                }
            }
        }
    }
    
    // Forgot Password Action
    @objc private func handleForgotPassword() {
        delegate?.showForgotPasswordSection()
    }

    // Register Action
    @objc private func handleRegister() {
        delegate?.showRegisterForm()
    }
    
    // Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View Constraints
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 64),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: registerButton.topAnchor),

            // Email TextField Constraints
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Password TextField Constraints
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Forgot Password Button Constraints
            forgotPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 34),
            
            // Login Button Constraints
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 10),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            loginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Register Button Constraints
            registerButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -44),
            registerButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
 
