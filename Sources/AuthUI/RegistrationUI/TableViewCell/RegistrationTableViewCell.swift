//
//  RegistrationTableViewCell.swift
//  
//
//  Created by Ramanathan on 02/08/24.
//

import UIKit

protocol RegistrationTableViewCellDelegate: AnyObject {
    func textFieldShouldReturn(_ textField: UITextField)
    func makeUpdateRegisterFormWithUpdatedData(registrationFormData: RegisterFormData?)
}

class RegistrationTableViewCell: UITableViewCell {
    
    //MARK: - Constant
    enum Constant {
        static let innerPaddingTextField:CGRect = CGRect(x: 0, y: 0, width: 10, height: 0)
        static let textFieldMargin = UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)
        static let textFieldHeight: CGFloat = 40
        static let rightPaddingSecureField:CGRect = CGRect(x: 0, y: 0, width: 40, height: 0)
        static let errorMessageMargin = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
        static let eyeButtonMargin = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 10)
        static let eyeButtonWidth: CGFloat = 30
    }

    // MARK: - Properties
    private var hasSetupConstraints: Bool = false
    public weak var textField: UITextField!
    private weak var errorMessageLabel: UILabel!
    private weak var eyeButton: UIButton!
    
    private var eyeOpen = false
    
    var delegate: RegistrationTableViewCellDelegate?
    
    var registrationFormData: RegisterFormData? {
        didSet {
            guard let registrationFormDataUW = registrationFormData else { return }
            makeRenderInputFieldData(registrationFormData: registrationFormDataUW)
        }
    }
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: UI and Constraints
    func setupViews() {
        
        backgroundColor = .clear
        
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.delegate = self
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        let paddingView: UIView = UIView(frame: Constant.innerPaddingTextField)
        textField.leftView = paddingView
        textField.rightView = paddingView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.autocorrectionType = .no

        let errorMessageLabel = UILabel()
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.font = UIFont.systemFont(ofSize: 14)
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.textColor = UIColor.red
        errorMessageLabel.isHidden = true
        
        let eyeButton = UIButton(type: .custom)
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        eyeButton.layer.cornerRadius = 15
        eyeButton.setImage(UIImage(systemName: "eye")?.withTintColor(.gray,
                                                                     renderingMode: .alwaysOriginal), for: .normal)
        eyeButton.addTarget(self, action: #selector(passwordHideToggleAction), for: .touchUpInside)
        eyeButton.isHidden = true

        self.textField = textField
        self.errorMessageLabel = errorMessageLabel
        self.eyeButton = eyeButton
        
        self.contentView.addSubview(textField)
        self.contentView.addSubview(errorMessageLabel)
        self.contentView.addSubview(eyeButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.textField.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                                 constant: Constant.textFieldMargin.top),
            self.textField.leftAnchor.constraint(equalTo: self.contentView.leftAnchor,
                                                  constant: Constant.textFieldMargin.left),
            self.textField.rightAnchor.constraint(equalTo: self.contentView.rightAnchor,
                                                   constant: -Constant.textFieldMargin.right),
            self.textField.heightAnchor.constraint(equalToConstant: Constant.textFieldHeight),
            
            
            self.errorMessageLabel.topAnchor.constraint(equalTo: self.textField.bottomAnchor,
                                                        constant: Constant.errorMessageMargin.top),
            self.errorMessageLabel.leftAnchor.constraint(equalTo: self.textField.leftAnchor,
                                                         constant: Constant.errorMessageMargin.left),
            self.errorMessageLabel.rightAnchor.constraint(equalTo: self.textField.rightAnchor,
                                                          constant: -Constant.errorMessageMargin.right),
            self.errorMessageLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                                           constant: -Constant.errorMessageMargin.bottom),
            
            self.eyeButton.topAnchor.constraint(equalTo: self.textField.topAnchor,
                                                constant: Constant.eyeButtonMargin.top),
            self.eyeButton.widthAnchor.constraint(equalToConstant: Constant.eyeButtonWidth),
            self.eyeButton.rightAnchor.constraint(equalTo: self.textField.rightAnchor,
                                                  constant: -Constant.eyeButtonMargin.right),
            self.eyeButton.bottomAnchor.constraint(equalTo: self.textField.bottomAnchor,
                                                   constant: -Constant.eyeButtonMargin.bottom),
        ])
    }
    
    override func updateConstraints() {
        if hasSetupConstraints == false {
            setupConstraints()
            hasSetupConstraints = true
        }
        super.updateConstraints()
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension RegistrationTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        debugPrint("textFieldDidEndEditing ==> \(String(describing: textField.text))")
        guard let text = textField.text else { return }
        self.registrationFormData?.inPutValue = text
        self.delegate?.makeUpdateRegisterFormWithUpdatedData(registrationFormData: self.registrationFormData)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.textFieldShouldReturn(textField)
        return true
    }
}

extension RegistrationTableViewCell {
    
    @objc func passwordHideToggleAction() {
        self.eyeOpen = !self.eyeOpen
        textField.isSecureTextEntry = !self.eyeOpen
        eyeOpen ?
        eyeButton.setImage(UIImage(systemName: "eye.slash")?.withTintColor(.gray,
                                                                           renderingMode: .alwaysOriginal), for: .normal):
        eyeButton.setImage(UIImage(systemName: "eye")?.withTintColor(.gray,
                                                                     renderingMode: .alwaysOriginal), for: .normal)
    }
}

extension RegistrationTableViewCell {
    
    func setTagForCurrentTextField(_ tag: Int) {
        textField.tag = tag
    }
    
    private func makeRenderInputFieldData(registrationFormData: RegisterFormData) {
        
        //Constant
        textField.inputAccessoryView = .none
        textField.isSecureTextEntry = false
        textField.text = registrationFormData.inPutValue
                
        errorMessageLabel.text = ""
        errorMessageLabel.isHidden = registrationFormData.isPresentErrorMessage
        eyeButton.setImage(UIImage(systemName: "eye")?.withTintColor(.gray,
                                                                     renderingMode: .alwaysOriginal), for: .normal)
        eyeButton.isHidden = true
        
        //Dynamic
        textField.placeholder = registrationFormData.inPutField.placeHolder
        errorMessageLabel.text = registrationFormData.errorMessage
        errorMessageLabel.isHidden = !registrationFormData.isPresentErrorMessage
        
        switch registrationFormData.inPutField {
            
        case .firstName:
            textField.autocapitalizationType = .words
            textField.keyboardType = .default
            textField.returnKeyType = .next
            
        case .lastName:
            textField.autocapitalizationType = .words
            textField.keyboardType = .default
            textField.returnKeyType = .next
            
        case .phone:
            textField.keyboardType = .phonePad
            textField.returnKeyType = .next
            
        case .email:
            textField.autocapitalizationType = .none
            textField.keyboardType = .emailAddress
            textField.autocorrectionType = .no
            textField.returnKeyType = .next
            
        case .password:
            textField.isSecureTextEntry = true
            textField.returnKeyType = .next
            eyeButton.isHidden = false
            textField.rightView =  UIView(frame:Constant.rightPaddingSecureField)
            textField.rightViewMode = .always
            
        case .confirmPassword:
            textField.isSecureTextEntry = true
            textField.returnKeyType = .done
            eyeButton.isHidden = false
            textField.rightView =  UIView(frame:Constant.rightPaddingSecureField)
            textField.rightViewMode = .always
        }
    }
}
