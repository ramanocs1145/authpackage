//
//  ForgotPasswordViewController.swift
//  
//
//  Created by Ramanathan on 07/08/24.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPurple
        
        setupNavigationBarAppearance()
        
        let forgotPasswordView = AuthUI.ForgotPasswordView(frame: self.view.bounds)
        forgotPasswordView.delegate = self
        self.view.addSubview(forgotPasswordView)
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
        
        self.title = "Forgot Password"
    }
}

extension ForgotPasswordViewController: ForgotPasswordViewDelegate {
    func showValidationAlert(errorMessage: String) {
        UIAlertController_Extension.showSimpleAlert(from: self, title: "AuthUI", message: errorMessage)
    }
    
    func makePopupNavigation() {
        self.navigationController?.popViewController(animated: true)
    }
}
