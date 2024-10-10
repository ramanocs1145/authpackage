//
//  NetworkExecutor.swift
//  
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation
import Combine

final class NetworkExecutor {
    // MARK: - Methods
    static func execute(request: URLRequest, with session: URLSession) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        session.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
}
