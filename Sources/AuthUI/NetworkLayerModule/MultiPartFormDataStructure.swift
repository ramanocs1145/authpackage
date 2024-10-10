//
//  MultiPartFormDataStructure.swift
//
//
//  Created by Ramanathan on 07/08/24.
//

import Foundation

public struct MultipartFormData {
    let boundary: String
    var parameters: [String: String]
    var files: [File]

    init(parameters: [String: String], files: [File]) {
        self.boundary = "Boundary-\(UUID().uuidString)"
        self.parameters = parameters
        self.files = files
    }

    struct File {
        let data: Data
        let name: String
        let fileName: String
        let mimeType: String
    }

    func createBody() -> Data {
        var body = Data()

        // Add parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add files
        for file in files {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(file.mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(file.data)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

