//
//  LogoutRepository.swift
//
//
//  Created by Ramanathan on 08/08/24.
//

import Foundation
import Combine

public protocol LogoutServicesDelegate {
    func fetchLogoutServiceRequest(bearerToken: String?, 
                                   delegate: AuthServiceHelperDelegate?,
                                   completionHandler: @escaping (Result<EmptyResponse, CustomError>) -> Void)
}

public final class LogoutService: LogoutServicesDelegate {
    // MARK: - Variables
    private var cancellables = Set<AnyCancellable>()
    private let network: NetworkFactoryType
    
    // MARK: - Methods
    public init(network: NetworkFactoryType) {
        self.network = network
    }
    
    public func fetchLogoutServiceRequest(bearerToken: String?, 
                                          delegate: AuthServiceHelperDelegate?,
                                          completionHandler: @escaping (Result<EmptyResponse, CustomError>) -> Void) {
        let publisher: AnyPublisher<EmptyResponse, CustomError> = network.fetch(
            requestConfig: LogoutRequestConfig.details(apiVersion: Configuration.shared.apiVersion ?? "", bearerToken: bearerToken, queryParams: nil, multipartData: nil),
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
}

enum LogoutRequestConfig {
    case details(apiVersion: String, bearerToken: String?, queryParams: [String: String]?, multipartData: MultipartFormData?)
}

extension LogoutRequestConfig: RequestConfig {
    var baseURL: URL {
        return URL(string: Configuration.shared.baseURL ?? "")! // Set your base URL here
    }
    
    var path: String {
        switch self {
        case .details(let apiVersion, _, _, _):
            return apiVersion + "/logout"
        }
    }
    
    var method: HTTPMethod { .get }
    
    var parameters: [String: Any]? {
        switch self {
        case .details(_, _, _, _):
            return nil
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .details(_, let bearerToken, _, _):
            var headers = ["Content-Type": "application/json"]
            if let token = bearerToken {
                headers["Authorization"] = "Bearer \(token)"
            }
            return headers
        }
    }
    
    var bearerToken: String? {
        switch self {
        case .details(_, let token, _, _):
            return token
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .details(_, _, let queryParams, _):
            return queryParams
        }
    }
    
    var multipartData: MultipartFormData? {
        switch self {
        case .details(_, _, _, let multipartData):
            return multipartData
        }
    }
}
