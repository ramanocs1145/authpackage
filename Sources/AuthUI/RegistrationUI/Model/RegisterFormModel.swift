//
//  RegisterFormModel.swift
//
//
//  Created by Ramanathan on 05/08/24.
//

import Foundation

public struct RegisterFormDataRepresentation: Codable {
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let phoneNumber: String?
    public let password: String?
}

public extension RegisterFormDataRepresentation {
    func dictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let firstNameUW = firstName {
            dict["first_name"] = firstNameUW
        }
        
        if let lastNameUW = lastName {
            dict["last_name"] = lastNameUW
        }

        if let emailUW = email {
            dict["email"] = emailUW
        }
        
        if let phoneNumberUW = phoneNumber {
            dict["phone_number"] = phoneNumberUW
        }

        if let passwordUW = password {
            dict["password"] = passwordUW
        }
        return dict
    }
}
