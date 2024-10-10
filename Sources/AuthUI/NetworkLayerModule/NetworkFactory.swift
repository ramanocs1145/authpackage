//
//  NetworkFactory.swift
//  
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation
import Combine

public protocol NetworkFactoryType {
    func fetch<T: Decodable>(
        requestConfig: RequestConfig,
        shouldCache: Bool,
        endpointUrl: String,
        delegate: AuthServiceHelperDelegate?
    ) -> AnyPublisher<T, CustomError>
}

public final class NetworkFactory: NetworkFactoryType {
    // MARK: - Variables
    private static let retries: Int = 3
    
    public weak var delegate: AuthServiceHelperDelegate?
    
    // MARK: - Init
    public init() {}
    
    // MARK: - Execute Request
    public func fetch<T: Decodable>(
        requestConfig: RequestConfig,
        shouldCache: Bool,
        endpointUrl: String,
        delegate: AuthServiceHelperDelegate? = nil
    ) -> AnyPublisher<T, CustomError> {
        self.delegate = delegate
        guard let request = RequestBuilder.buildRequest(with: requestConfig, and: endpointUrl) else {
            return Fail(error: CustomError.networkRequestBuildFailure)
                .eraseToAnyPublisher()
        }
        
        if shouldCache, let cachedResponse = CacheManager.loadCachedResponse(for: request),
           let decodedObject: T = try? ResponseDecoder.decodeData(cachedResponse.data) {
            return Just(decodedObject)
                .setFailureType(to: CustomError.self)
                .eraseToAnyPublisher()
        }
        
        NetworkLogger.logRequest(request: request)
        
        let session = SessionManager.createSession(cache: CacheManager.cache)
        
        return NetworkExecutor.execute(request: request, with: session)
            .tryMap { data, response in
                NetworkLogger.logResponse(response: response, data: data)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw CustomError.networkInvalidResponse
                }
                // Check if data is empty
                if data.isEmpty {
                    switch httpResponse.statusCode {
                    case 200..<300:
                        // No Content - Return a default value if appropriate
                        if T.self == EmptyResponse.self {
                            return EmptyResponse() as! T
                        }
                        throw CustomError.networkEmptyResponse
                    default:
                        throw CustomError.networkResponseDecodingFailure(NSError(
                            domain: NSCocoaErrorDomain,
                            code: 3840,
                            userInfo: [NSLocalizedDescriptionKey: "Empty response data"]
                        ))
                    }
                }
                let decodedObject: T = try ResponseDecoder.decodeResponse(data: data, response: response)
                if shouldCache {
                    CacheManager.storeCachedResponse(response: response, data: data, for: request)
                }
                return decodedObject
            }
            .mapError { error in
                ErrorHandler.handleError(error, url: request.url)
            }
            .retry(Self.retries)
            .catch { error -> AnyPublisher<T, CustomError> in
                if case .unauthorized = error {
                    return self.handleTokenRefreshAndRetry(requestConfig: requestConfig, shouldCache: shouldCache, endpointUrl: endpointUrl, delegate: self.delegate)
                }
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func handleTokenRefreshAndRetry<T: Decodable>(
        requestConfig: RequestConfig,
        shouldCache: Bool,
        endpointUrl: String,
        delegate: AuthServiceHelperDelegate? = nil
    ) -> AnyPublisher<T, CustomError> {
        return TokenManager.shared.handleRefreshToken()
            .flatMap { newAccessToken -> AnyPublisher<T, CustomError> in
                
                //To send latest access token to client source for the purpose of update stored access token replacing by the new one.
                self.delegate?.didReceiveAccessToken(newAccessToken)
                
                // Retry original request with new access token
                guard let request = RequestBuilder.buildRequest(with: requestConfig, and: endpointUrl) else {
                    return Fail(error: CustomError.networkRequestBuildFailure)
                        .eraseToAnyPublisher()
                }
                // Set the new access token in the request headers
                var modifiedRequest = request
                modifiedRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")

                NetworkLogger.logRequest(request: modifiedRequest)

                let session = SessionManager.createSession(cache: CacheManager.cache)

                return NetworkExecutor.execute(request: modifiedRequest, with: session)
                    .tryMap { data, response in
                        
                        NetworkLogger.logResponse(response: response, data: data)
                        
                        guard let httpResponse = response as? HTTPURLResponse else {
                            throw CustomError.networkInvalidResponse
                        }
                        // Check if data is empty
                        if data.isEmpty {
                            switch httpResponse.statusCode {
                            case 200..<300:
                                // No Content - Return a default value if appropriate
                                if T.self == EmptyResponse.self {
                                    return EmptyResponse() as! T
                                }
                                throw CustomError.networkEmptyResponse
                            default:
                                throw CustomError.networkResponseDecodingFailure(NSError(
                                    domain: NSCocoaErrorDomain,
                                    code: 3840,
                                    userInfo: [NSLocalizedDescriptionKey: "Empty response data"]
                                ))
                            }
                        }
                        let decodedObject: T = try ResponseDecoder.decodeResponse(data: data, response: response)
                        if shouldCache {
                            CacheManager.storeCachedResponse(response: response, data: data, for: request)
                        }
                        return decodedObject
                    }
                    .mapError { error in
                        CustomError.networkError(error.localizedDescription)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
