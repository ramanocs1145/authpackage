//
//  RequestBuilder.swift
//
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation

final class RequestBuilder {
    // MARK: - Methods
    static func buildRequest(with requestConfig: RequestConfig, and endpointUrl: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: endpointUrl + requestConfig.path) else {
            return nil
        }

        // Add query parameters to URL
        if let queryParams = requestConfig.queryParams {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = requestConfig.method.rawValue
        
        // Add Bearer Token to headers if available
        var headers = requestConfig.headers ?? [:]
        if let bearerToken = requestConfig.bearerToken {
            headers["Authorization"] = "Bearer \(bearerToken)"
        }
        
        // Handle multipart form data
        if let multipartData = requestConfig.multipartData {
            headers["Content-Type"] = "multipart/form-data; boundary=\(multipartData.boundary)"
            request.httpBody = multipartData.createBody()
        } else {
            request.httpBody = httpBody(requestConfig)
        }
        
        request.allHTTPHeaderFields = requestConfig.headers
        
        /*if let headers = requestConfig.headers {
            for (headerField, headerValue) in headers {
                request.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }*/
        
        request.httpBody = httpBody(requestConfig)
        request.timeoutInterval = 10
        return request
    }
    
    private static func httpBody(_ requestConfig: RequestConfig) -> Data? {
        guard let parameters = requestConfig.parameters else {
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
    
    static func buildRefreshTokenRequest() -> URLRequest? {
        guard let refreshToken = TokenManager.shared.refreshToken else { return nil }
        let endpointUrl = (Configuration.shared.baseURL ?? "") +  "/" + (Configuration.shared.apiVersion ?? "") + "/refresh-token"
        var request = URLRequest(url: URL(string: endpointUrl)!)
        request.httpMethod = "POST"
        
        // Set headers if needed
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add body with refresh token
        let body: [String: String] = ["refresh_token": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        return request
    }
}
