//
//  URLErrorExtension.swift
//
//
//  Created by Ramanathan on 06/08/24.
//

import Foundation

extension URLError.Code {
    static var unauthorized: URLError.Code {
        return URLError.Code(rawValue: 401)
    }
}
