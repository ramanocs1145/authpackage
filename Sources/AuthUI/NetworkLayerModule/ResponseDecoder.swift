//
//  ResponseDecoder.swift
//  
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation

public enum CustomError: Error, Equatable {
    case genericError(Error)
    case notConnectedToInternet
    case networkRequestBuildFailure
    case networkClientFailure(code: Int, url: String, message: String)
    case networkServerFailure(code: Int, url: String, message: String)
    case networkUnknownStatusCode(code: Int, url: String, message: String)
    case networkInvalidResponse
    case networkResponseDecodingFailure(Error)
    case networkError(String)
    case unauthorized
    case networkEmptyResponse
    
    public static func == (lhs: CustomError, rhs: CustomError) -> Bool {
        switch (lhs, rhs) {
        case (.genericError(let lhsError), .genericError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.notConnectedToInternet, .notConnectedToInternet):
            return true
        case (.networkRequestBuildFailure, .networkRequestBuildFailure):
            return true
        case (.networkClientFailure(let lhsCode, let lhsURL, let lhsMessage), .networkClientFailure(let rhsCode, let rhsURL, let rhsMessage)):
            return lhsCode == rhsCode && lhsURL == rhsURL && lhsMessage == rhsMessage
        case (.networkServerFailure(let lhsCode, let lhsURL, let lhsMessage), .networkServerFailure(let rhsCode, let rhsURL, let rhsMessage)):
            return lhsCode == rhsCode && lhsURL == rhsURL && lhsMessage == rhsMessage
        case (.networkUnknownStatusCode(let lhsCode, let lhsURL, let lhsMessage), .networkUnknownStatusCode(let rhsCode, let rhsURL, let rhsMessage)):
            return lhsCode == rhsCode && lhsURL == rhsURL && lhsMessage == rhsMessage
        case (.networkInvalidResponse, .networkInvalidResponse):
            return true
        case (.networkResponseDecodingFailure(let lhsError), .networkResponseDecodingFailure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError == rhsError
        case (.unauthorized, .unauthorized):
            return true
        case (.networkEmptyResponse, .networkEmptyResponse):
            return true
        default:
            return false
        }
    }
    
    public var errorMessage: String {
        switch self {
        case .networkClientFailure(_, _, let message):
            return message
        case .networkServerFailure(_, _, _):
            return "Server error occurred"
        case .networkInvalidResponse:
            return "Invalid response"
        case .networkResponseDecodingFailure(let error):
            return error.localizedDescription
        case .networkRequestBuildFailure:
            return "Failed to build request"
        case .networkUnknownStatusCode(_, _, _):
            return "Unknown error occurred"
        case .genericError(let error):
            return error.localizedDescription
        case .notConnectedToInternet:
            return "No Internet Connection"
        case .networkError(let error):
            return error
        case .unauthorized:
            return "Unauthorized"
        case .networkEmptyResponse:
            return "Empty Response"
        }
    }
    
    public var statusCode: Int {
        switch self {
        case .networkClientFailure(let statusCodeInfo, _, _):
            return statusCodeInfo
        case .networkServerFailure(let statusCodeInfo, _, _):
            return statusCodeInfo
        case .networkInvalidResponse:
            return 400
        case .networkResponseDecodingFailure(_):
            return 405
        case .networkRequestBuildFailure:
            return 422
        case .networkUnknownStatusCode(let statusCodeInfo, _, _):
            return statusCodeInfo
        case .genericError(_):
            return 520
        case .notConnectedToInternet:
            return 502
        case .networkError(_):
            return 503
        case .unauthorized:
            return 401
        case .networkEmptyResponse:
            return 204
        }
    }
}

final class ResponseDecoder {
    
    static func decodeResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CustomError.networkInvalidResponse
        }
        let errorMessage = try extractErrorMessage(from: data)

        switch httpResponse.statusCode {
        case 200..<300:
            return try decodeData(data)
        case 400...499:
            throw CustomError.networkClientFailure(code: httpResponse.statusCode, url: httpResponse.url?.absoluteString ?? "", message: errorMessage)
        case 500...599:
            throw CustomError.networkServerFailure(code: httpResponse.statusCode, url: httpResponse.url?.absoluteString ?? "", message: errorMessage)
        default:
            throw CustomError.networkUnknownStatusCode(code: httpResponse.statusCode, url: httpResponse.url?.absoluteString ?? "", message: errorMessage)
        }
    }
    
    static func decodeData<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw CustomError.networkResponseDecodingFailure(error)
        }
    }
    
    static func extractErrorMessage(from data: Data) throws -> String {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = json as? [String: Any], let message = dictionary["message"] as? String {
            return message
        }
        return "Unknown error"
    }
    
    static func extractStatusCode(from data: Data) throws -> Int {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = json as? [String: Any], let statusCode = dictionary["status_code"] as? Int {
            return statusCode
        }
        return 520
    }
}
