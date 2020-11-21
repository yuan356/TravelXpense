//
//  ErrorMsg+ext.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import Firebase

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return NSLocalizedString("The email address is already in use by another account", comment: "The email address is already in use by another account")
        case .userNotFound:
            return NSLocalizedString("Email not found for the specified user", comment: "Email not found for the specified user")
        case .userDisabled:
            return NSLocalizedString("This account has been disabled", comment: "This account has been disabled")
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return NSLocalizedString("Email address is wrong format", comment: "Email address is wrong format")
        case .networkError:
            return NSLocalizedString("Network error", comment: "Network error")
        case .weakPassword:
            return NSLocalizedString("Password must be 6 characters long or more", comment: "Password must be 6 characters long or more")
        case .wrongPassword:
            return NSLocalizedString("Incorrect password", comment: "Incorrect password")
        default:
            return "Unknown error occurred"
        }
    }
}
