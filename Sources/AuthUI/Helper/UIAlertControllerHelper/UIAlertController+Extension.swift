//
//  UIAlertController+Extension.swift
//  
//
//  Created by Ramanathan on 07/08/24.
//

import UIKit

class UIAlertController_Extension: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension UIAlertController_Extension {
    
    /// Creates and presents an alert with a title, message, and a single 'OK' button.
    ///
    /// - Parameters:
    ///   - viewController: The view controller from which to present the alert.
    ///   - title: The title of the alert.
    ///   - message: The message of the alert.
    static func showSimpleAlert(from viewController: UIViewController, title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// Creates and presents an alert with a title, message, and customizable buttons.
    ///
    /// - Parameters:
    ///   - viewController: The view controller from which to present the alert.
    ///   - title: The title of the alert.
    ///   - message: The message of the alert.
    ///   - actions: An array of UIAlertAction to be added to the alert.
    static func showAlert(from viewController: UIViewController, title: String?, message: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// Creates and presents an action sheet with a title, message, and customizable actions.
    ///
    /// - Parameters:
    ///   - viewController: The view controller from which to present the action sheet.
    ///   - title: The title of the action sheet.
    ///   - message: The message of the action sheet.
    ///   - actions: An array of UIAlertAction to be added to the action sheet.
    static func showActionSheet(from viewController: UIViewController, title: String?, message: String?, actions: [UIAlertAction]) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for action in actions {
            actionSheet.addAction(action)
        }
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    /// Convenience method to create a default UIAlertAction.
    ///
    /// - Parameters:
    ///   - title: The title of the action.
    ///   - style: The style of the action.
    ///   - handler: The closure to execute when the user selects the action.
    /// - Returns: A configured UIAlertAction.
    static func createAction(title: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: style, handler: handler)
    }
}
