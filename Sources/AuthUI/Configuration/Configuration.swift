//
//  Configuration.swift
//  
//
//  Created by Ramanathan on 02/08/24.
//

import Foundation

public class Configuration {
    public static let shared = Configuration()

    public var _baseURL: String?
    public var _apiVersion: String?
    private let queue = DispatchQueue(label: "ConfigurationQueue", attributes: .concurrent)

    public var baseURL: String? {
        get {
            return queue.sync { _baseURL }
        }
        set {
            queue.async(flags: .barrier) { self._baseURL = newValue }
        }
    }
    
    public var apiVersion: String? {
        get {
            return queue.sync { _apiVersion }
        }
        set {
            queue.async(flags: .barrier) { self._apiVersion = newValue }
        }
    }

    private init() {
        // Set default values or load from a config file
        self.baseURL = " " //"https://api.example.com"
        self.apiVersion = " "
    }

    // You can also provide custom initialization if needed
    public func updateConfigurationData(_ url: String?, apiVersion: String?) {
        self.baseURL = url
        self.apiVersion = apiVersion
    }
}
