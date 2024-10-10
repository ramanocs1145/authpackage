//
//  ForgotPasswordModel.swift
//  
//
//  Created by Ramanathan on 06/08/24.
//

import Foundation

public struct ForgotPasswordDataRepresentation: Codable {
    public let email: String?
}

public extension ForgotPasswordDataRepresentation {
    func dictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let emailUW = email {
            dict["email"] = emailUW
        }
        
        return dict
    }
}
