//
//  NetworkResponse.swift
//
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation

public struct EmptyResponse: Codable {}

public protocol NetworkResponse: Codable {}

public struct ErrorResponse: Codable {
    let statusCode: Int?
    let message: String?
    
    public init(statusCode: Int?, message: String?) {
        self.statusCode = statusCode
        self.message = message
    }
    
    private enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case message
    }
}

public struct AuthenticationResponse: NetworkResponse {
    public let tokenType: String?
    public let expiresIn: Double?
    public let accessToken: String?
    public let refreshToken: String?
    
    public init(tokenType: String?, expiresIn: Double?, accessToken: String?, refresToken: String?) {
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.accessToken = accessToken
        self.refreshToken = refresToken
    }
    
    private enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

public struct AuthDataRepresentation: Codable {
    public let email: String?
    public let password: String?
}

public extension AuthDataRepresentation {
    func dictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let email = email {
            dict["email"] = email
        }
        if let password = password {
            dict["password"] = password
        }
        return dict
    }
}

