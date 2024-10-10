//
//  CustomOTPView.swift
//
//
//  Created by OCS MAC-29 on 02/09/24.
//

import UIKit

public protocol CustomOTPViewDelegate: AnyObject {
    func showValidationAlert(errorMessage: String)
    func showRegisterForm()
    func makeRedirectToHomeSection(_ accessToken: String)
}

public class CustomOTPView: UIView {

    // UI Elements
    private var otpTextFieldView: OTPFieldView!
    private var emailTextField: UITextField!
    
    private var verificationCodeCheckCaptionLabel: UILabel!
    private var timerLabel: UILabel!
    private var recendOTPButton: UIButton!
    private var verifyOTPButton: UIButton!
    
    private var emailValue: String? = nil
    private var phoneNumberValue: String? = nil
    private var phoneOrEmailValue: String? = nil
    
    public var typingTimer: Timer?
    public var resendOptionTimer: Timer?
    public var remainingTime = 60 // Countdown duration in seconds

    public var fieldsCount: Int?
    public var displayType: DisplayType?
    public var secureEntry: Bool?
    
    public weak var delegate: CustomOTPViewDelegate?
    
    init(frame: CGRect, fieldsCount: Int = 6, displayType: DisplayType = .underlinedBottom, secureEntry: Bool = false, delegate: CustomOTPViewDelegate?, phoneOrEmail: String) {
        super.init(frame: frame)
        
        self.fieldsCount = fieldsCount
        self.displayType = displayType
        self.secureEntry = secureEntry
        self.delegate = delegate
        self.phoneOrEmailValue = phoneOrEmail

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // Setup Email TextField
    private func setupEmailOrPhoneNumberTextField() {
        let emailTextField = UITextField()
        emailTextField.placeholder = "Enter Email Or Phone Number"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.delegate = self
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.cornerRadius = 5.0
        emailTextField.becomeFirstResponder()
        
        self.emailTextField = emailTextField
    }
    
    private func setupOTPFieldView() {
        let otpTextFieldView = OTPFieldView(frame: frame)
        otpTextFieldView.fieldsCount = self.fieldsCount ?? 6
        otpTextFieldView.fieldBorderWidth = 2
        otpTextFieldView.defaultBorderColor = UIColor.white
        otpTextFieldView.filledBorderColor = UIColor.green
        otpTextFieldView.errorBorderColor = UIColor.red
        otpTextFieldView.cursorColor = UIColor.white
        otpTextFieldView.displayType = self.displayType ?? .underlinedBottom
        otpTextFieldView.fieldSize = 40
        otpTextFieldView.separatorSpace = 8
        otpTextFieldView.shouldAllowIntermediateEditing = false
        otpTextFieldView.delegate = self
        otpTextFieldView.secureEntry = true
        otpTextFieldView.initializeUI()
        otpTextFieldView.alpha = 0

        self.otpTextFieldView = otpTextFieldView
    }
    
    // Setup Login Button
    private func setupResendOTPButton() {
        let recendOTPButton = UIButton(type: .system)
        recendOTPButton.setTitle("RESEND OTP", for: .normal)
        recendOTPButton.setTitleColor(.black, for: .normal)
        recendOTPButton.addTarget(self, action: #selector(handleResendOTPAction), for: .touchUpInside)
        recendOTPButton.translatesAutoresizingMaskIntoConstraints = false
        recendOTPButton.backgroundColor = .systemGray
        recendOTPButton.layer.cornerRadius = 2
        recendOTPButton.layer.masksToBounds = true
        recendOTPButton.isEnabled = false // Disable the button initially
        
        self.recendOTPButton = recendOTPButton
    }
    
    // Setup Forgot Password Button
    private func setupVerifyOTPButton() {
        let verifyOTPButton = UIButton(type: .system)
        verifyOTPButton.setTitle("VERIFY OTP", for: .normal)
        verifyOTPButton.setTitleColor(.black  , for: .normal)
        verifyOTPButton.addTarget(self, action: #selector(handleVerifyOTPAction), for: .touchUpInside)
        verifyOTPButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.verifyOTPButton = verifyOTPButton
    }
    
    // Setup Verification Code Check Caption Label
    private func setupVerificationCodeCheckCaptionLabel() {
        let verificationCodeCheckCaptionLabel = UILabel()
        verificationCodeCheckCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        verificationCodeCheckCaptionLabel.text = "Check your " + (self.phoneOrEmailValue ?? "") + "to see the verification code."
        verificationCodeCheckCaptionLabel.font = UIFont.systemFont(ofSize: 12)
        verificationCodeCheckCaptionLabel.numberOfLines = 1
        verificationCodeCheckCaptionLabel.textColor = UIColor.gray
        verificationCodeCheckCaptionLabel.textAlignment = .center

        self.verificationCodeCheckCaptionLabel = verificationCodeCheckCaptionLabel
    }
    
    // Setup Resend Available Label
    private func setupResendAvailableCaptionLabel() {
        let timerLabel = UILabel()
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.font = UIFont.systemFont(ofSize: 12)
        timerLabel.numberOfLines = 1
        timerLabel.textColor = UIColor.gray
        timerLabel.textAlignment = .center

        self.timerLabel = timerLabel
    }
    
    private func setupView() {
        startOTPTimer() // Start the OTP timer when view loads
        
        // Setup UI Elements
        setupOTPFieldView()
//        setupEmailOrPhoneNumberTextField()
        setupVerificationCodeCheckCaptionLabel()
        setupResendOTPButton()
        setupResendAvailableCaptionLabel()
        setupVerifyOTPButton()
               
        self.addSubview(otpTextFieldView)
//        self.addSubview(emailTextField)
                        
        setupConstraints()
    }
        
    // Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // emailTextField Constraints
//            emailTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: (frame.height / 2) - 100),
//            emailTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            emailTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//            emailTextField.heightAnchor.constraint(equalToConstant: 44)
            
            
            // verificationCodeCheckCaptionLabel Constraints
            verificationCodeCheckCaptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: (frame.height / 2) - 100),
            verificationCodeCheckCaptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            verificationCodeCheckCaptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            verificationCodeCheckCaptionLabel.heightAnchor.constraint(equalToConstant: 28),
            
            // recendOTPButton Constraints
            recendOTPButton.topAnchor.constraint(equalTo: self.otpTextFieldView.bottomAnchor, constant: 50),
            recendOTPButton.widthAnchor.constraint(equalToConstant: 250),
            recendOTPButton.heightAnchor.constraint(equalToConstant: 44),
            recendOTPButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            // timerLabel Constraints
            timerLabel.topAnchor.constraint(equalTo: self.recendOTPButton.bottomAnchor, constant: 20),



        ])
    }
    
    private func startOTPTimer() {
        remainingTime = 60
        recendOTPButton?.isEnabled = false // Disable the button initially
        updateTimerLabel()
        
        resendOptionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    // Resend OTP Button Action
    @objc private func handleResendOTPAction() {
        startOTPTimer() // Restart the timer when OTP is resent
        // Add logic to resend the OTP
    }
    
    // Verify OTP Button Action
    @objc private func handleVerifyOTPAction() {
        
    }
    
    // Update Timer Action
    @objc private func updateTimer() {
        if remainingTime > 0 {
            remainingTime -= 1
            updateTimerLabel()
        } else {
            resendOptionTimer?.invalidate()
            resendOptionTimer = nil
            recendOTPButton?.isEnabled = true // Enable the button when timer ends
            timerLabel?.text = "You can resend the OTP now"
        }
    }

    func updateTimerLabel() {
        timerLabel?.text = "Resend available in \(remainingTime) seconds"
    }

}

extension CustomOTPView: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentText = textField.text as NSString? {
            let newText = currentText.replacingCharacters(in: range, with: string)
            
            // Invalidate the previous timer
            typingTimer?.invalidate()

            // Schedule a new timer to fire after 0.5 seconds of inactivity
            typingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                self?.validateAndHandleInput(newText)
            }
        }
        return true
    }
}

extension CustomOTPView {
    
    private func validateAndHandleInput(_ input: String) {
        let validationResult = validateInput(input)
        generateOTP(validatedInput: validationResult)
    }
    
    private func validateInput(_ input: String) -> String {
        if input.isValidEmail() {
            return "Email"
        } else if input.isValidPhoneNumber() {
            return "Phone Number"
        } else {
            return "Invalid Input"
        }
    }
    
    private func handleValidationResult(_ result: String) {
        switch result {
        case "Email", "Phone Number":
            emailTextField.layer.borderColor = UIColor.green.cgColor
            otpTextFieldView.alpha = 1.0
        case "Invalid Input":
            emailTextField.layer.borderColor = UIColor.red.cgColor
            shakeAndProvideHapticFeedback()
            otpTextFieldView.alpha = 0
        default:
            otpTextFieldView.alpha = 0
            break
        }
    }
    
    private func shakeAndProvideHapticFeedback() {
        // Shake animation
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = 4
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: emailTextField.center.x - 10, y: emailTextField.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: emailTextField.center.x + 10, y: emailTextField.center.y))
        emailTextField.layer.add(shake, forKey: "position")
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

extension CustomOTPView {
    
    // Generate OTP - To Make SignIn.
    private func generateOTP(validatedInput: String) {
        guard let inputValue = emailTextField.text, !inputValue.isEmpty else {
            self.delegate?.showValidationAlert(errorMessage: "Email or Phone Number is required")
            return
        }
        
        switch validatedInput {
        case "Email":
            emailValue = inputValue
            break
        case "Phone Number":
            phoneNumberValue = inputValue
            break
        case "Invalid Input":
            return
        default:
            break
        }
        
        let customOTPViewService = CustomOTPViewService(network: NetworkFactory())
        let generateOTPDataRepresentation = GenerateOTPDataRepresentation(email: emailValue, phoneNumber: phoneNumberValue)
        customOTPViewService.generateOTPRequest(generateOTPDataRepresentation: generateOTPDataRepresentation,
                                                delegate: nil,
                                                completionHandler: { (result) in
            switch result {
            case .success(let response):
                // Handle successful response
                debugPrint("Received Forgot Password Success Response: \(response)")
                DispatchQueue.main.async {
                    self.handleValidationResult(validatedInput)
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
    
    private func validateOTP(otpValue: String?, emailValue: String? = nil, phoneNumberValue: String? = nil) {
        guard let otpValueUW = otpValue, !otpValueUW.isEmpty else {
            self.delegate?.showValidationAlert(errorMessage: "Please Provide Valid OTP")
            return
        }
                
        let customOTPViewService = CustomOTPViewService(network: NetworkFactory())
        let verifyOTPDataRepresentation = VerifyOTPDataRepresentation(email: emailValue, phoneNumber: phoneNumberValue, otp: otpValueUW)
        customOTPViewService.verifyOTPRequest(verifyOTPDataRepresentation: verifyOTPDataRepresentation,
                                                delegate: nil,
                                                completionHandler: { (result) in
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
                    let _ = self.hasEnteredAllOTP(hasEnteredAll: false)
                }
            }
        })
    }
}

extension CustomOTPView: OTPFieldViewDelegate {
    public func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        debugPrint("otpTextFieldIndex \(index)")
        return true
    }
    
    public func enteredOTP(otp: String) {
        debugPrint("OTPString: \(otp)")
        validateOTP(otpValue: otp, emailValue: self.emailValue, phoneNumberValue: self.phoneNumberValue )
    }
    
    public func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        debugPrint("Has entered all OTP? \(hasEnteredAll)")
        return hasEnteredAll
    }
}
