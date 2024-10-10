//
//  CacheManager.swift
//
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation

final class CacheManager {
    // MARK: - Variables
    private static let memoryCapacity = 0
    private static let allowedDiskSize = 10 * 1024 * 1024 // 10 MB
    static let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: allowedDiskSize, diskPath: nil)
    
    // MARK: - Methods
    static func storeCachedResponse(response: URLResponse, data: Data, for request: URLRequest) {
        let cachedData = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedData, for: request)
    }
    
    static func loadCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        cache.cachedResponse(for: request)
    }
}
