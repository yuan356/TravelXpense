//
//  AuthService.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class AuthService {
    
    static var isUserLogin: Bool {
        return currentUser != nil
    }
    
    static var currentUser: User? {
        return Auth.auth().currentUser
    }

    static func signUp(name: String, email: String, password: String, completion: @escaping (_ result: CompletionResult)->()) {
        // 在 Firebase 註冊使用者帳號
        Auth.auth().createUser(withEmail: email, password: password, completion : { (user, error) in
            if let error = error {
                let er = AuthErrorCode(rawValue: error._code)
                TXAlert.showCenterAlert(message: NSLocalizedString(er?.errorMessage ?? error.localizedDescription, comment: ""))
                completion(.failed)
                return
            }
            // 儲存使用者的名稱
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = name
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print("Failed to change the display name: \(error.localizedDescription)")
                        completion(.failed)
                        return
                    }
                    TXObserved.notifyObservers(notificationName: .authLog, infoKey: nil, infoValue: nil)
                    
                    completion(.success)
                })
            }
        })
    }
    
    static func googleLogin(user: GIDGoogleUser, completion: @escaping (_ result: CompletionResult)->()) {
        
        guard let authentication = user.authentication else {
            completion(.failed)
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication .idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                TXAlert.showCenterAlert(message: NSLocalizedString(error.localizedDescription, comment: "email address exist"))
                completion(.failed)
                return
            }
            
            TXObserved.notifyObservers(notificationName: .authLog, infoKey: nil, infoValue: nil)
            BackupService.shared.initSetting()
            completion(.success)
        }
    }
    
    static func facebookLogin(vc: UIViewController, completion: @escaping (_ result: CompletionResult)->()) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: vc) {
            (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                completion(.failed)
                return
            }
            
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                completion(.failed)
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            if let cancel = result?.isCancelled, cancel == true {
                completion(.failed)
                return
            }
            
            // 呼叫 Firebase APIs 來執行登入
            Auth.auth().signIn(with: credential, completion: { (result, error) in
                if let error = error {
                    TXAlert.showCenterAlert(message: NSLocalizedString(error.localizedDescription, comment: "email address exist"))
                    completion(.failed)
                    return
                } else {
                    TXObserved.notifyObservers(notificationName: .authLog, infoKey: nil, infoValue: nil)
                    BackupService.shared.initSetting()
                    completion(.success)
                }
            })
        }
    }
    
    static func logIn(email: String, password: String, completion: @escaping (_ result: CompletionResult)->()) {
        // 呼叫 Firebase APIs 執行登入
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                let er = AuthErrorCode(rawValue: error._code)
                
                TXAlert.showCenterAlert(message: NSLocalizedString(er?.errorMessage ?? error.localizedDescription, comment: ""))
                completion(.failed)
                return
            }
            TXObserved.notifyObservers(notificationName: .authLog, infoKey: nil, infoValue: nil)
            BackupService.shared.initSetting()
            completion(.success)
        })
    }
    
    static func logOut() {
        do {
            try Auth.auth().signOut()
            TXObserved.notifyObservers(notificationName: .authLog, infoKey: nil, infoValue: nil)
            BackupService.shared.resetBackupTime()
        } catch {
            TXAlert.showCenterAlert(message: NSLocalizedString(error.localizedDescription, comment: ""))
        }
    }
    
    static func resetPassword(email: String, completion: @escaping (_ result: CompletionResult)->()) { 
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            if let error = error {
                TXAlert.showCenterAlert(message: NSLocalizedString(error.localizedDescription, comment: ""))
                completion(.failed)
            } else {
                let msg1 = NSLocalizedString("We have just sent you a password reset email.", comment: "resetPassword")
                let msg2 = NSLocalizedString("Please check your inbox and reset your password.", comment: "resetPassword")
                TXAlert.showCenterAlert(message: msg1 + "\n\n" + msg2)
                completion(.success)
            }
        })
    }
}
