//
//  TokenManager.swift
//
//
//  Created by Ramanathan on 06/08/24.
//

import Foundation
import Combine

public class TokenManager {
    public static let shared = TokenManager()
    private init() {}

    var accessToken: String? {
        // Retrieve from secure storage (e.g., Keychain)
        if let retrievedUserAuth: AuthenticationResponse = KeychainHelper.retrieve(forKey: Keys.userAuthModelKey, modelType: AuthenticationResponse.self) {
            return retrievedUserAuth.accessToken
        } else {
            debugPrint("No access token found in Keychain")
            return nil
        }
    }

    var refreshToken: String? {
        // Retrieve from secure storage (e.g., Keychain)
        if let retrievedUserAuth: AuthenticationResponse = KeychainHelper.retrieve(forKey: Keys.userAuthModelKey, modelType: AuthenticationResponse.self) {
            return retrievedUserAuth.refreshToken
        } else {
            debugPrint("No refresh token found in Keychain")
            return nil
        }
    }
    
    var authenticationData: AuthenticationResponse? {
        // Retrieve from secure storage (e.g., Keychain)
        if let retrievedUserAuth: AuthenticationResponse = KeychainHelper.retrieve(forKey: Keys.userAuthModelKey, modelType: AuthenticationResponse.self) {
            return retrievedUserAuth
        } else {
            debugPrint("No authentication data found in Keychain")
            return nil
        }
    }
    
    public func fetchRefreshToken(_ accessToken: String?) -> String? {
        guard let retrievedUserAuth: AuthenticationResponse = KeychainHelper.retrieve(forKey: Keys.userAuthModelKey, modelType: AuthenticationResponse.self), let retrievedUserAccessToken = retrievedUserAuth.accessToken else {
            debugPrint("No refresh token found in Keychain")
            return nil
        }
        guard let accessTokenUW = accessToken else {
            debugPrint("No refresh token found in Keychain")
            return nil       
        }
        guard retrievedUserAccessToken.elementsEqual(accessTokenUW) else {
            debugPrint("No refresh token found in Keychain")
            return nil
        }
        return retrievedUserAuth.refreshToken
    }
    
    func handleRefreshToken() -> AnyPublisher<String, CustomError> {
        // Implement the refresh token request here
        // Assume you have a method for creating the refresh token request
        guard let request = RequestBuilder.buildRefreshTokenRequest() else {
            return Fail(error: CustomError.networkRequestBuildFailure).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                let tokenResponse = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
                // Save new tokens to secure storage
                let _ = KeychainHelper.storeUserAuthenticationResponse(model: tokenResponse)
                return tokenResponse.accessToken ?? ""
            }
            .mapError { error in
                CustomError.networkError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
