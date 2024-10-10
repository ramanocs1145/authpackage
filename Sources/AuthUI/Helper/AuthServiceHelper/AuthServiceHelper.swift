//
//  AuthServiceHelper.swift
//
//
//  Created by Ramanathan on 09/08/24.
//

import Foundation

public protocol AuthServiceHelperDelegate: AnyObject {
    func didReceiveAccessToken(_ accessToken: String)
}
