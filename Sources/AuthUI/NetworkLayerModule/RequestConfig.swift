//
//  RequestConfig.swift
//
//
//  Created by Ramanathan on 02/08/24.
//

import UIKit

public protocol RequestConfig {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var bearerToken: String? { get }
    var queryParams: [String: String]? { get }
    var multipartData: MultipartFormData? { get }
}

extension RequestConfig {
    var headers: [String: String]? {
        return nil
    }
    
    var parameters: [String: Any]? {
        return nil
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "PATCH"
    case patch = "DELETE"
}

public enum APIError: Error {
    case invalidResponse
    case invalidData
}
