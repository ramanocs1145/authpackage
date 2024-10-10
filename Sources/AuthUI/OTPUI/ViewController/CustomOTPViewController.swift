//
//  CustomOTPViewController.swift
//  
//
//  Created by OCS MAC-29 on 03/09/24.
//

import UIKit

public protocol CustomOTPViewControllerDelegate: AnyObject {
    func otpLoginSuccessHandler(_ accessToken: String)
    func otpRegisterSuccessHandler(_ accessToken: String)
}

public class CustomOTPViewController: UIViewController {
    
    private var otpView: CustomOTPView?
        
    public var fieldsCount: Int?
    public var displayType: DisplayType?
    public var secureEntry: Bool?
    
    public weak var delegate: CustomOTPViewControllerDelegate?
        
    public init(fieldsCount: Int = 6, displayType: DisplayType = .underlinedBottom, secureEntry: Bool = false, delegate: CustomOTPViewControllerDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.fieldsCount = fieldsCount
        self.displayType = displayType
        self.secureEntry = secureEntry
        self.delegate = delegate
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple

        setupNavigationBackBarButtonAppearance()

        let otpView = CustomOTPView(frame: self.view.bounds, fieldsCount: self.fieldsCount ?? 6, displayType: self.displayType ?? .underlinedBottom, secureEntry: self.secureEntry ?? false, delegate: self)
        self.view.addSubview(otpView)
        self.otpView = otpView
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Invalidate the timer when the view is about to disappear
        self.otpView?.typingTimer?.invalidate()
        self.otpView?.typingTimer = nil
    }
        
    private func setupNavigationBackBarButtonAppearance() {
        // Create a custom back button
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    deinit {
        // Invalidate the timer when the view controller is deallocated
        self.otpView?.typingTimer?.invalidate()
    }
}

extension CustomOTPViewController: CustomOTPViewDelegate {
    public func showRegisterForm() {
        // Instantiate the RegistrationViewController with a delegate
        let registrationVC = RegistrationViewController(delegate: self)
        self.navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    public func makeRedirectToHomeSection(_ accessToken: String) {
        debugPrint("Required access token ==> \(accessToken)")
        UIAlertController_Extension.showSimpleAlert(from: self, title: "AuthUI", message: "SuccessFully Logged In")
        self.delegate?.otpLoginSuccessHandler(accessToken)
    }
    
    public func showValidationAlert(errorMessage: String) {
        UIAlertController_Extension.showSimpleAlert(from: self, title: "AuthUI", message: errorMessage)
    }
}

extension CustomOTPViewController: RegistrationViewControllerDelegate {
    public func registrationSuccessHandler(_ accessToken: String) {
        self.delegate?.otpRegisterSuccessHandler(accessToken)
    }
}
