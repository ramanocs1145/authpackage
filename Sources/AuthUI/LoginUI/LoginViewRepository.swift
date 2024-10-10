//
//  LoginViewRepository.swift
//
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation
import Combine

public protocol AuthServicesDelegate {
    func fetchAuthServiceRequest(credentialsData: AuthDataRepresentation,
                                 delegate: AuthServiceHelperDelegate?,
                                 completionHandler: @escaping (Result<AuthenticationResponse, CustomError>) -> Void)
}

public final class AuthService: AuthServicesDelegate {
    // MARK: - Variables
    private var cancellables = Set<AnyCancellable>()
    private let network: NetworkFactoryType
    
    // MARK: - Methods
    public init(network: NetworkFactoryType) {
        self.network = network
    }
        
    public func fetchAuthServiceRequest(credentialsData: AuthDataRepresentation,
                                        delegate: AuthServiceHelperDelegate?,
                                        completionHandler: @escaping (Result<AuthenticationResponse, CustomError>) -> Void) {
        let publisher: AnyPublisher<AuthenticationResponse, CustomError> = network.fetch(
            requestConfig: AuthCredentialsRequestConfig.details(credentialsData: credentialsData, apiVersion: Configuration.shared.apiVersion ?? "", bearerToken: nil, queryParams: nil, multipartData: nil),
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

enum AuthCredentialsRequestConfig {
    case details(credentialsData: AuthDataRepresentation, apiVersion: String, bearerToken: String?, queryParams: [String: String]?, multipartData: MultipartFormData?)
}

extension AuthCredentialsRequestConfig: RequestConfig {
    var baseURL: URL {
        return URL(string: Configuration.shared.baseURL ?? "")! // Set your base URL here
    }
    
    var path: String {
        switch self {
        case .details(_, let apiVersion, _, _, _):
            return apiVersion + "/login"
        }
    }
    
    var method: HTTPMethod { .post }
    
    var parameters: [String: Any]? {
        switch self {
        case .details(let credentialsData, _, _, _, _):
            return credentialsData.dictionary()
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
