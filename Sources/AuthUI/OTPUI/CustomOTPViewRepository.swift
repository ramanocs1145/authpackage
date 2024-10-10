//
//  CustomOTPViewRepository.swift
//  
//
//  Created by OCS MAC-29 on 05/09/24.
//

import Foundation
import Combine

public protocol CustomOTPViewSeviceDelegate {
    func generateOTPRequest(generateOTPDataRepresentation: GenerateOTPDataRepresentation,
                            delegate: AuthServiceHelperDelegate?,
                            completionHandler: @escaping (Result<EmptyResponse, CustomError>) -> Void)
    
    func verifyOTPRequest(verifyOTPDataRepresentation: VerifyOTPDataRepresentation,
                          delegate: AuthServiceHelperDelegate?,
                          completionHandler: @escaping (Result<AuthenticationResponse, CustomError>) -> Void)
}

public final class CustomOTPViewService: CustomOTPViewSeviceDelegate {
    // MARK: - Variables
    private var cancellables = Set<AnyCancellable>()
    private let network: NetworkFactoryType
    
    // MARK: - Methods
    public init(network: NetworkFactoryType) {
        self.network = network
    }
    
    public func generateOTPRequest(generateOTPDataRepresentation: GenerateOTPDataRepresentation,
                                   delegate: AuthServiceHelperDelegate?,
                                   completionHandler: @escaping (Result<EmptyResponse, CustomError>) -> Void) {
        let publisher: AnyPublisher<EmptyResponse, CustomError> = network.fetch(
            requestConfig: OTPViewRequestConfig.details(generateOTPDataRepresentation: generateOTPDataRepresentation, apiVersion: Configuration.shared.apiVersion ?? "", bearerToken: nil, queryParams: nil, multipartData: nil),
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
            }, receiveValue: { (response: EmptyResponse) in
                debugPrint("Received response: \(response)")
                completionHandler(.success(response))
            })
            .store(in: &cancellables)
    }
    
    public func verifyOTPRequest(verifyOTPDataRepresentation: VerifyOTPDataRepresentation,
                                 delegate: AuthServiceHelperDelegate?,
                                 completionHandler: @escaping (Result<AuthenticationResponse, CustomError>) -> Void) {
        let publisher: AnyPublisher<AuthenticationResponse, CustomError> = network.fetch(
            requestConfig: OTPViewRequestConfig.verifyOTPDetails(verifyOTPDataRepresentation: verifyOTPDataRepresentation, apiVersion: Configuration.shared.apiVersion ?? "", bearerToken: nil, queryParams: nil, multipartData: nil),
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

enum OTPViewRequestConfig {
    case details(generateOTPDataRepresentation: GenerateOTPDataRepresentation, apiVersion: String, bearerToken: String?, queryParams: [String: String]?, multipartData: MultipartFormData?)
    case verifyOTPDetails(verifyOTPDataRepresentation: VerifyOTPDataRepresentation, apiVersion: String, bearerToken: String?, queryParams: [String: String]?, multipartData: MultipartFormData?)
}

extension OTPViewRequestConfig: RequestConfig {
    var baseURL: URL {
        return URL(string: Configuration.shared.baseURL ?? "")! // Set your base URL here
    }
    
    var path: String {
        switch self {
        case .details(_, let apiVersion, _, _, _):
            return apiVersion + "/generate-otp"
            
        case .verifyOTPDetails(_, let apiVersion, _, _, _):
            return apiVersion + "/verify-otp"
        }
    }
    
    var method: HTTPMethod { .post }
    
    var parameters: [String: Any]? {
        switch self {
        case .details(let generateOTPData, _, _, _, _):
            return generateOTPData.dictionary()
        case .verifyOTPDetails(let verifyOTPData, _, _, _, _):
            return verifyOTPData.dictionary()
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
        case .verifyOTPDetails(_, _, let bearerToken, _, _):
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
        case .verifyOTPDetails(_, _, let token, _, _):
            return token
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .details(_, _, _, let queryParams, _):
            return queryParams
        case .verifyOTPDetails(_, _, _, let queryParams, _):
            return queryParams
        }
    }
    
    var multipartData: MultipartFormData? {
        switch self {
        case .details(_, _, _, _, let multipartData):
            return multipartData
        case .verifyOTPDetails(_, _, _, _, let multipartData):
            return multipartData
        }
    }
}
