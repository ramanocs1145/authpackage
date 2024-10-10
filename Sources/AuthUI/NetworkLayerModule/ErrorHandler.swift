//
//  ErrorHandler.swift
//
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation

final class ErrorHandler {
    // MARK: - Methods
    static func handleError(_ error: Error, url: URL? = nil) -> CustomError {
        debugPrint("Network error occurred: \(error) for URL: \(url?.absoluteString ?? "Unknown URL")")
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case URLError.notConnectedToInternet,
                 URLError.networkConnectionLost,
                 URLError.dataNotAllowed,
                 URLError.internationalRoamingOff,
                 URLError.timedOut:
                return .notConnectedToInternet
            default:
                break
            }
        }
        
        // Check if the error is due to unauthorized access
        if let urlError = error as? URLError, urlError.code == .unauthorized {
            return CustomError.unauthorized
        }
        // return CustomError.networkError(error.localizedDescription)
        
        if let customError = error as? CustomError {
            if customError.statusCode == 401 {
                return .unauthorized
            }
            return customError
        }
        
        if let responseError = error as? HTTPURLResponse {
            return .networkUnknownStatusCode(code: responseError.statusCode, url: url?.absoluteString ?? "Unknown URL", message: responseError.debugDescription)
        }
        
        return .genericError(error)
    }
}
