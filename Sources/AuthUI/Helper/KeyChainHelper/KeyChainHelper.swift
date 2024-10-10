//
//  KeyChainHelper.swift
//
//
//  Created by Ramanathan on 05/08/24.
//

import Security
import Foundation

public class KeychainHelper {
    
    // MARK: - Private Keychain Operations
    public static func save(key: String, data: Data) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        // Delete any existing items
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public static func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == errSecSuccess else { return nil }
        return dataTypeRef as? Data
    }
    
    public static func delete(key: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

extension KeychainHelper {
    
    // MARK: - Generic Store Method
    public static func store<T: Codable>(model: T, key: String) -> Bool {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)
            return save(key: key, data: data)
        } catch {
            debugPrint("Failed to encode model: \(error)")
            return false
        }
    }

    // MARK: - Generic Retrieve Method
    public static func retrieve<T: Codable>(forKey key: String, modelType: T.Type) -> T? {
        guard let data = load(key: key) else { return nil }
        let decoder = JSONDecoder()
        do {
            let model = try decoder.decode(T.self, from: data)
            return model
        } catch {
            debugPrint("Failed to decode model: \(error)")
            return nil
        }
    }

    // MARK: - Generic Delete Method
    public static func delete(forKey key: String) -> Bool {
        return KeychainHelper.delete(key: key)
    }
    
    public static func clearAuthDataDuringLogout(accessToken: String, 
                                                 delegate: AuthServiceHelperDelegate?,
                                                 completionHandler: @escaping (Result<EmptyResponse, CustomError>) -> Void) {
        
        var requiredAccessToken: String? = nil
        
        // Retrieve the user auth model
        if let retrievedUserAuth: AuthenticationResponse = KeychainHelper.retrieve(forKey: Keys.userAuthModelKey, modelType: AuthenticationResponse.self) {
            debugPrint("Retrieved user: \(retrievedUserAuth)")
            if let accessTokenUW = retrievedUserAuth.accessToken, accessTokenUW.elementsEqual(accessToken) {
                requiredAccessToken = accessTokenUW
            }
        } else {
            debugPrint("No user found in Keychain")
        }
        
        let logoutService = LogoutService(network: NetworkFactory())
        logoutService.fetchLogoutServiceRequest(bearerToken: requiredAccessToken, 
                                                delegate: delegate,
                                                completionHandler: { (result) in
            switch result {
            case .success(let response):
                // Handle successful response
                debugPrint("Received authentication response: \(response)")
                DispatchQueue.main.async {
                    // Delete the user model.
                    let _ = KeychainHelper.delete(forKey: Keys.userAuthModelKey)
                }
                completionHandler(.success(response))
                
            case .failure(let error):
                // Handle error
                debugPrint("Failed with error: \(error)")
                completionHandler(.failure(error))
            }
        })
    }
    
    public static func storeUserAuthenticationResponse<T: Codable>(model: T) {
        let _ = KeychainHelper.delete(forKey: Keys.userAuthModelKey)
        let _ = KeychainHelper.store(model: model, key: Keys.userAuthModelKey)
    }
}
