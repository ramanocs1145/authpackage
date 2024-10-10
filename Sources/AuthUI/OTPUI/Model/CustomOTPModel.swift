//
//  CustomOTPModel.swift
//
//
//  Created by OCS MAC-29 on 05/09/24.
//

import Foundation

//Generate OTP Data Representation
public struct GenerateOTPDataRepresentation: Codable {
    public let email: String?
    public let phoneNumber: String?
}

public extension GenerateOTPDataRepresentation {
    func dictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let emailUW = email {
            dict["email"] = emailUW
        }
        
        if let phoneNumberUW = phoneNumber {
            dict["phone_number"] = phoneNumberUW
        }
        
        return dict
    }
}


//Verify OTP Data Representation
public struct VerifyOTPDataRepresentation: Codable {
    public let email: String?
    public let phoneNumber: String?
    public let otp: String?
}

public extension VerifyOTPDataRepresentation {
    func dictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let emailUW = email {
            dict["email"] = emailUW
        }
        
        if let phoneNumberUW = phoneNumber {
            dict["phone_number"] = phoneNumberUW
        }
        
        if let otpUW = otp {
            dict["otp"] = otpUW
        }
        
        return dict
    }
}
