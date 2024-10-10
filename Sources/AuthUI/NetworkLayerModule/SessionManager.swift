//
//  SessionManager.swift
//  
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation

final class SessionManager {
    // MARK: - Methods
    static func createSession(cache: URLCache) -> URLSession {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .reloadRevalidatingCacheData
        sessionConfiguration.urlCache = cache
        return URLSession(configuration: sessionConfiguration)
    }
}
