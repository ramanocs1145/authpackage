//
//  LoginViewController.swift
//  
//
//  Created by Ramanathan on 07/08/24.
//

import UIKit

public protocol LoginViewControllerDelegate: AnyObject {
    func loginSuccessHandler(_ accessToken: String)
    func registerSuccessHandler(_ accessToken: String)
}

public class LoginViewController: UIViewController {
    
    public weak var delegate: LoginViewControllerDelegate?
        
    public init(delegate: LoginViewControllerDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple

        setupNavigationBackBarButtonAppearance()
        
        let loginView = LoginView(frame: self.view.bounds)
        loginView.delegate = self
        self.view.addSubview(loginView)
    }
    
    private func setupNavigationBackBarButtonAppearance() {
        // Create a custom back button
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
}

extension LoginViewController: LoginViewDelegate {
    public func makeRedirectToHomeSection(_ accessToken: String) {
        debugPrint("Required access token ==> \(accessToken)")
        UIAlertController_Extension.showSimpleAlert(from: self, title: "AuthUI", message: "SuccessFully Logged In")
        self.delegate?.loginSuccessHandler(accessToken)
    }
    
    public func showForgotPasswordSection() {
        self.navigationController?.pushViewController(ForgotPasswordViewController(), animated: true)
    }
    
    public func showRegisterForm() {
        // Instantiate the RegistrationViewController with a delegate
        let registrationVC = RegistrationViewController(delegate: self)
        self.navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    public func showValidationAlert(errorMessage: String) {
        UIAlertController_Extension.showSimpleAlert(from: self, title: "AuthUI", message: errorMessage)
    }
}

extension LoginViewController: RegistrationViewControllerDelegate {
    public func registrationSuccessHandler(_ accessToken: String) {
        self.delegate?.registerSuccessHandler(accessToken)
    }
}
