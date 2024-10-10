//
//  ForgotPasswordView.swift
//
//
//  Created by Ramanathan on 01/08/24.
//

import UIKit

public protocol ForgotPasswordViewDelegate: AnyObject {
    func makePopupNavigation()
    func showValidationAlert(errorMessage: String)
}

public class ForgotPasswordView: UIView {
    
    // UI Elements
    private var emailTextField: UITextField!
    private var sendButton: UIButton!
    
    public weak var delegate: ForgotPasswordViewDelegate?

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
        setupEmailTextField()
        setupSendButton()

        // Add UI Elements to the View
        self.addSubview(emailTextField)
        self.addSubview(sendButton)

        // Set up constraints
        setupConstraints()
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

    // Setup Send Button
    private func setupSendButton() {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.backgroundColor = .systemPink
        sendButton.layer.cornerRadius = 5
        sendButton.layer.masksToBounds = true
        
        self.sendButton = sendButton
    }

    // Send Action
    @objc private func handleSend() {
        guard let emailUW = emailTextField.text, !emailUW.isEmpty else {
            self.delegate?.showValidationAlert(errorMessage: "This Field is required")
            return
        }
        guard emailUW.isValidEmail() else {
            self.delegate?.showValidationAlert(errorMessage: "Enter a valid email")
            return
        }
        let forgotPasswordService = ForgotPasswordViewService(network: NetworkFactory())
        let forgotPasswordData = ForgotPasswordDataRepresentation(email: emailUW)
        forgotPasswordService.fetchForgotPasswordRequest(forgotPasswordData: forgotPasswordData, 
                                                         delegate: nil,
                                                         completionHandler: { (result) in
            switch result {
            case .success(let response):
                // Handle successful response
                debugPrint("Received Forgot Password Success Response: \(response)")
                DispatchQueue.main.async {
                    self.delegate?.makePopupNavigation()
                }
            case .failure(let error):
                // Handle error
                debugPrint("Failed with error: \(error)")
                DispatchQueue.main.async {
                    self.delegate?.showValidationAlert(errorMessage: error.errorMessage)
                }
            }
        })
    }

    // Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 144),
            emailTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
                        
            // Register Button Constraints
            sendButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
