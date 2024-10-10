//
//  NetworkLogger.swift
//
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation

final class NetworkLogger {
    // MARK: - Methods
    static func logRequest(request: URLRequest) {
#if DEBUG
        debugPrint("-------------------------- NETWORK REQUEST START --------------------------")
        if let url = request.url, let httpMethod = request.httpMethod {
            debugPrint("\(httpMethod) \(url)")
        }
        if let headers = request.allHTTPHeaderFields {
            debugPrint("Headers: \(headers)")
        }
        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            debugPrint("Body: \(bodyString)")
        }
        debugPrint("--------------------------------------------------------------------------------")
#endif
    }
    
    static func logResponse(response: URLResponse, data: Data?) {
#if DEBUG
        debugPrint("--------------------------- NETWORK RESPONSE START ---------------------------")
        if let httpResponse = response as? HTTPURLResponse {
            debugPrint("Response - Status Code: \(httpResponse.statusCode)")
            debugPrint("Response URL: \(httpResponse.url?.absoluteString ?? "Unknown URL")")
        }
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            debugPrint("Response Body: \(dataString)")
        }
        debugPrint("--------------------------- NETWORK RESPONSE END -----------------------------")
#endif
    }
}
