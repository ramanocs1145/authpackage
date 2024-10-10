//
//  RegistrationViewController.swift
//  
//
//  Created by Ramanathan on 07/08/24.
//

import UIKit

public protocol RegistrationViewControllerDelegate: AnyObject {
    func registrationSuccessHandler(_ accessToken: String)
}

class RegistrationViewController: UIViewController {
    
    public weak var delegate: RegistrationViewControllerDelegate?
    
    public init(delegate: RegistrationViewControllerDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPurple
        
        setupNavigationBarAppearance()
        
        let registrationView = AuthUI.RegistrationView(frame: self.view.bounds)
        registrationView.delegate = self
        self.view.addSubview(registrationView)
    }
    
    private func setupNavigationBarAppearance() {
        // Create an appearance object
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // or .configureWithTransparentBackground() for transparency
        
        // Customize the appearance
        appearance.backgroundColor = UIColor.systemPurple // Set background color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 32)]
        
        // Customize back button
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backButtonAppearance = backButtonAppearance

        
        // Apply the appearance to the navigation bar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white // This affects the bar button items and back button
                
        // Customize the back button image (optional)
        let backImage = UIImage(systemName: "arrow.backward")
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
        navigationItem.backButtonTitle = " " // This sets the title of the back button
        
        self.title = "Registration"
    }
}

extension RegistrationViewController: RegistrationViewDelegate {
    func showValidationAlert(errorMessage: String) {
        UIAlertController_Extension.showSimpleAlert(from: self, title: "AuthUI", message: errorMessage)
    }
    
    func makeRedirectToHomeSection(_ accessToken: String) {
        debugPrint("Required access token ==> \(accessToken)")
        UIAlertController_Extension.showSimpleAlert(from: self, title: "AuthUI", message: "SuccessFully Logged In")
        self.delegate?.registrationSuccessHandler(accessToken)
    }
}
