//
//  RegistrationView.swift
//  
//
//  Created by Ramanathan on 02/08/24.
//

import UIKit

struct RegisterFormData {
    let inPutField: CustomTextFieldList
    var inPutValue: String
    var errorMessage: String
    var isPresentErrorMessage: Bool
}

struct RegisterFormModel: Codable {
    let firstName: String?
    let lastName: String?
    let email: String?
    let phoneNumber: String?
    let password: String?
}

public protocol RegistrationViewDelegate: AnyObject {
    func showValidationAlert(errorMessage: String)
    func makeRedirectToHomeSection(_ accessToken: String)
}

public class RegistrationView: UIView {
    
    private weak var tableView: UITableView!
    
    private var registrationFormData: [RegisterFormData]?
    
    public weak var delegate: RegistrationViewDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - UI and Constraint
    private func setupView() {
        // View background color
        self.backgroundColor = .systemPurple
        
        self.registrationFormData = loadRegistrationFormData()
        
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .onDragWithAccessory
        tableView.register(RegistrationTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(RegisterTableFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
        
        self.tableView = tableView
        
        self.addSubview(tableView)
        
        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.topAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

extension RegistrationView {
    
    private func loadRegistrationFormData() -> [RegisterFormData] {
        var registrationFormData = [RegisterFormData]()
        
        registrationFormData.append(RegisterFormData(inPutField: .firstName, inPutValue: "", errorMessage: "", isPresentErrorMessage: false))
        registrationFormData.append(RegisterFormData(inPutField: .lastName, inPutValue: "", errorMessage: "", isPresentErrorMessage: false))
        registrationFormData.append(RegisterFormData(inPutField: .phone, inPutValue: "", errorMessage: "", isPresentErrorMessage: false))
        registrationFormData.append(RegisterFormData(inPutField: .email, inPutValue: "", errorMessage: "", isPresentErrorMessage: false))
        registrationFormData.append(RegisterFormData(inPutField: .password, inPutValue: "", errorMessage: "", isPresentErrorMessage: false))
        registrationFormData.append(RegisterFormData(inPutField: .confirmPassword, inPutValue: "", errorMessage: "", isPresentErrorMessage: false))

        return registrationFormData
    }
}


//MARK: - UITableViewDataSource
extension RegistrationView: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.registrationFormData?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RegistrationTableViewCell
        cell.delegate = self
        cell.setTagForCurrentTextField(indexPath.row)
        cell.registrationFormData = self.registrationFormData![indexPath.item]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let FooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer") as! RegisterTableFooterView
        FooterView.delegate = self
        return FooterView
    }
}

//MARK: - UITableViewDelegate
extension RegistrationView: UITableViewDelegate {}

//MARK: - RegistrationTableViewCellDelegate
extension RegistrationView: RegistrationTableViewCellDelegate {
    
    func makeUpdateRegisterFormWithUpdatedData(registrationFormData: RegisterFormData?) {
        
        if let registrationFormDataUW = registrationFormData, let currentIndex = self.registrationFormData?.firstIndex(where: { (registerFormDataInfo) in
            return registerFormDataInfo.inPutField == registrationFormDataUW.inPutField
        }) {
            self.registrationFormData?.remove(at: currentIndex)
            self.registrationFormData?.insert(registrationFormDataUW, at: currentIndex)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) {
        // Find the current text field's index path
        guard let cell = textField.superview?.superview as? RegistrationTableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        // Determine the next index path
        let nextRow = indexPath.row + 1

        // If it's the last row, dismiss the keyboard
        if nextRow >= tableView.numberOfRows(inSection: indexPath.section) {
            textField.resignFirstResponder()
            if textField.tag == 5 {
                self.handleDoneAction()
            }
        } else {
            // Otherwise, move to the next text field
            let nextIndexPath = IndexPath(row: nextRow, section: indexPath.section)
            if let nextCell = tableView.cellForRow(at: nextIndexPath) as? RegistrationTableViewCell {
                nextCell.textField.becomeFirstResponder()
            }
        }
    }
    
    private func handleDoneAction() {
        self.registerAction()
    }
}

//MARK: - RegisterTableFooterViewDelegate
extension RegistrationView: RegisterTableFooterViewDelegate{
    func registerAction() {
        self.endEditing(true)
        var isErrorMessageSet = false
        
        guard let registrationFormDataUW = self.registrationFormData else {
            self.tableView.reloadData()
            return
        }
        
        var firstName = ""
        var lastName = ""
        var email = ""
        var phoneNumber = ""
        var password = ""
        
        registrationFormDataUW.forEach { errorCase in
            // Reset error state
            var errorCaseUW = errorCase
            
            errorCaseUW.errorMessage = ""
            errorCaseUW.isPresentErrorMessage = false
            self.makeUpdateErrorMessageDetails(updatedFormData: errorCaseUW)

            // Helper function to set error
            func setError(message: String) {
                errorCaseUW.errorMessage = message
                errorCaseUW.isPresentErrorMessage = true
                self.makeUpdateErrorMessageDetails(updatedFormData: errorCaseUW)
            }
            // Common logic for validation
            if errorCaseUW.inPutValue.isEmpty {
                if !isErrorMessageSet {
                    setError(message: "This Field is required")
                    isErrorMessageSet = true
                }
                return
            }
            switch errorCaseUW.inPutField {
            case .firstName:
                if !errorCaseUW.inPutValue.isValidName() {
                    setError(message: "Enter a valid name ")
                    isErrorMessageSet = true
                }
                firstName = errorCaseUW.inPutValue
            case .lastName:
                if !errorCaseUW.inPutValue.isValidName() {
                    setError(message: "Enter a valid name ")
                    isErrorMessageSet = true
                }
                lastName = errorCaseUW.inPutValue

            case .phone:
                if !errorCaseUW.inPutValue.isValidPhone() {
                    setError(message: "Enter a valid Mobile No")
                    isErrorMessageSet = true
                }
                phoneNumber = errorCaseUW.inPutValue
                
            case .email:
                if !errorCaseUW.inPutValue.isValidEmail() {
                    setError(message: "Enter a valid email")
                    isErrorMessageSet = true
                }
                email = errorCaseUW.inPutValue

            case .password:
                if !errorCaseUW.inPutValue.isValidPassword() {
                    setError(message: "Enter a valid password")
                    isErrorMessageSet = true
                }

            case .confirmPassword:
                let passwordValue = registrationFormDataUW.first { $0.inPutField == .password }?.inPutValue
                if errorCaseUW.inPutValue != passwordValue {
                    setError(message: "Password doesn't match")
                    isErrorMessageSet = true
                }
                password = errorCaseUW.inPutValue
            }
        }
        
        if isErrorMessageSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            if !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, !password.isEmpty {
                let registerService = RegistrationService(network: NetworkFactory())
                let registerFormData = RegisterFormDataRepresentation(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, password: password)
                registerService.fetchRegisterRequest(registerFormData: registerFormData, 
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
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    private func makeUpdateErrorMessageDetails(updatedFormData: RegisterFormData) {
        if let currentIndex = self.registrationFormData?.firstIndex(where: { (registerFormDataInfo) in
            return updatedFormData.inPutField == registerFormDataInfo.inPutField
        }) {
            self.registrationFormData?.remove(at: currentIndex)
            self.registrationFormData?.insert(updatedFormData, at: currentIndex)
        }
    }
}

