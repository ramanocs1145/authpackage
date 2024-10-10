//
//  CustomTextFieldList.swift
//
//
//  Created by Ramanathan on 05/08/24.
//

import Foundation

enum CustomTextFieldList: Int, CaseIterable {
    case firstName
    case lastName
    case email
    case phone
    case password
    case confirmPassword
    
    var placeHolder: String {
        switch self {
        case .firstName:
            return "Name"
        case .lastName:
            return "Last Name"
        case .phone:
            return "Mobile No"
        case .email:
            return "Email"
        case .password:
            return "Password"
        case .confirmPassword:
            return "ConfirmPassword"
        }
    }
}
