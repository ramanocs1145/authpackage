//
//  Validation.swift
//  
//
//  Created by Ramanathan on 05/08/24.
//

import Foundation

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[0-9A-Za-z.]+@[a-z0-9.-]+\\.[a-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidName() -> Bool {
        let nameRegx = "^[A-Za-z]{3,29}$"
        let namePred = NSPredicate(format: "SELF MATCHES %@", nameRegx)
        return namePred.evaluate(with: self)
    }
    
    func isValidPhone() -> Bool {
        let phoneRegEx = "[0-9]{10}"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        // least one uppercase,
        // least one digit
        // least one lowercase
        // least one symbol
        //  min 6 characters total
        let password = self.trimmingCharacters(in: CharacterSet.whitespaces)
        let passwordRegx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^a-zA-Z\\d]).{6,}$"  //"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@",passwordRegx)
        return passwordCheck.evaluate(with: password)
    }
    
    func isValidPhoneNumber() -> Bool {
        //let phoneRegEx = "^[0-9+()\\- ]{6,15}$"
        let phoneRegEx = "^(\\+91|91|0)?[6-9][0-9]{9}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: self)
    }
}
