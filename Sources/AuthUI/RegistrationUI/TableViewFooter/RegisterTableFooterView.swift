//
//  RegisterTableFooterView.swift
//
//
//  Created by Ramanathan on 05/08/24.
//

import UIKit

protocol RegisterTableFooterViewDelegate: AnyObject {
    func registerAction()
}

class RegisterTableFooterView: UITableViewHeaderFooterView {
    
    //MARK: - Constant
    enum Constant {
        static let registerButtonMargin = UIEdgeInsets(top: 25, left: 16, bottom: 10, right: 16)
        static let registerButtonHeight: CGFloat = 44
    }

    // MARK: - Properties
    private var hasSetupConstraints: Bool = false
    
    var delegate: RegisterTableFooterViewDelegate?
    
    private weak var registerButton: UIButton!

    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    //MARK: - UI and Constraints
    func setupViews() {
        let registerButton = UIButton(type: .system)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.backgroundColor = UIColor.systemBlue
        registerButton.layer.cornerRadius = 5
        registerButton.setTitle("SignUp", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        registerButton.addTarget(self, action: #selector(registerButtonAction), for: .touchUpInside)
        registerButton.backgroundColor = .systemPink
        
        self.registerButton = registerButton
        
        self.addSubview(registerButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.registerButton.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                                constant: Constant.registerButtonMargin.top),
            self.registerButton.leftAnchor.constraint(equalTo: self.contentView.leftAnchor,
                                                 constant: Constant.registerButtonMargin.left),
            self.registerButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor,
                                                  constant: -Constant.registerButtonMargin.right),
            self.registerButton.heightAnchor.constraint(equalToConstant: Constant.registerButtonHeight),
            self.registerButton.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                      constant: -Constant.registerButtonMargin.bottom)
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

extension RegisterTableFooterView {
    
    @objc func registerButtonAction() {
        self.delegate?.registerAction()
    }
}
