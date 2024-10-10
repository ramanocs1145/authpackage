//
//  RegistrationViewRepository.swift
//
//
//  Created by Ramanathan on 05/08/24.
//

import Foundation
import Combine

public protocol RegistrationSeviceDelegate {
    func fetchRegisterRequest(registerFormData: RegisterFormDataRepresentation,
                              delegate: AuthServiceHelperDelegate?,
                              completionHandler: @escaping (Result<AuthenticationResponse, CustomError>) -> Void)
}

public final class RegistrationService: RegistrationSeviceDelegate {
    // MARK: - Variables
    private var cancellables = Set<AnyCancellable>()
    private let network: NetworkFactoryType
    
    // MARK: - Methods
    public init(network: NetworkFactoryType) {
        self.network = network
    }

    public func fetchRegisterRequest(registerFormData: RegisterFormDataRepresentation,
                                     delegate: AuthServiceHelperDelegate?,
                                     completionHandler: @escaping (Result<AuthenticationResponse, CustomError>) -> Void) {
        let publisher: AnyPublisher<AuthenticationResponse, CustomError> = network.fetch(
            requestConfig: RegistrationRequestConfig.details(registerFormData: registerFormData, apiVersion: Configuration.shared.apiVersion ?? "", bearerToken: nil, queryParams: nil, multipartData: nil),
            shouldCache: false,
            endpointUrl: Configuration.shared.baseURL ?? "", 
            delegate: delegate
        )
        
        publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    debugPrint("Request completed successfully.")
                case .failure(let error):
                    debugPrint("Request failed with error: \(error)")
                    completionHandler(.failure(error))
                }
            }, receiveValue: { (response: AuthenticationResponse) in
                debugPrint("Received response: \(response)")
                completionHandler(.success(response))
            })
            .store(in: &cancellables)
    }
}

enum RegistrationRequestConfig {
    case details(registerFormData: RegisterFormDataRepresentation, apiVersion: String, bearerToken: String?, queryParams: [String: String]?, multipartData: MultipartFormData?)
}

extension RegistrationRequestConfig: RequestConfig {
    var baseURL: URL {
        return URL(string: Configuration.shared.baseURL ?? "")! // Set your base URL here
    }
    
    var path: String {
        switch self {
        case .details(_, let apiVersion, _, _, _):
            return apiVersion + "/register-user"
        }
    }
    
    var method: HTTPMethod { .post }
    
    var parameters: [String: Any]? {
        switch self {
        case .details(let registerFormData, _, _, _, _):
            return registerFormData.dictionary()
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .details(_, _, let bearerToken, _, _):
            var headers = ["Content-Type": "application/json"]
            if let token = bearerToken {
                headers["Authorization"] = "Bearer \(token)"
            }
            return headers
        }
    }
    
    var bearerToken: String? {
        switch self {
        case .details(_, _, let token, _, _):
            return token
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .details(_, _, _, let queryParams, _):
            return queryParams
        }
    }
    
    var multipartData: MultipartFormData? {
        switch self {
        case .details(_, _, _, _, let multipartData):
            return multipartData
        }
    }
}
