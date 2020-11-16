//
//  SignUpWithEmailViewController.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/15.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let heightForStackItem: CGFloat = 45

fileprivate let textFont: UIFont = MainFont.regular.with(fontSize: .medium)
fileprivate let inputTextColor: UIColor = TXColor.gray.light

class LogWithEmailViewController: TXViewController {

    var isLogIn: Bool!
    
    lazy var vStackView = UIStackView {
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 5
        $0.axis = .vertical
    }
    
    lazy var nameTextField = TXTextField {
        $0.returnKeyType = .next
        $0.tag = 0
        $0.delegate = self
    }
    
    lazy var emailTextField = TXTextField {
        $0.keyboardType = .emailAddress
        $0.returnKeyType = .next
        $0.tag = 1
        $0.delegate = self
    }
    
    lazy var passwordTextField = TXTextField {
        $0.isSecureTextEntry = true
        $0.tag = 2
        $0.delegate = self
    }

    lazy var loginButton = TXButton {
        $0.backgroundColor = TXColor.system.veronese
        let title = isLogIn ? NSLocalizedString("Log in", comment: "Log in") : NSLocalizedString("Sign up", comment: "Sign up")
        $0.setTitle("  " + title + "  ", for: .normal)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        $0.addTarget(self, action: #selector(logClicked), for: .touchUpInside)
        $0.setBackgroundColor(color: TXColor.system.veroneseDrak, forState: .highlighted)
        $0.anchorSize(h: 45)
        $0.roundedCorners()
    }
    
    lazy var resetPasswordButton = TXButton {
        $0.backgroundColor = TXColor.orange.light
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        let title = NSLocalizedString("Reset password", comment: "")
        $0.setTitle("  " + title + "  ", for: .normal)
        $0.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        $0.setBackgroundColor(color: TXColor.orange.dark, forState: .highlighted)
        $0.anchorSize(h: 45)
        $0.roundedCorners()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TXColor.background()
        setViews()
    }
    
    private func setViews() {
        if !isLogIn {
            vStackView.addArrangedSubview(EditInfoView(viewheight: heightForStackItem, title: NSLocalizedString("User name", comment: "User name"), object: nameTextField, underLine: true, anchorBottom: true))
        }
        
        vStackView.addArrangedSubview(EditInfoView(viewheight: heightForStackItem, title: NSLocalizedString("Email", comment: "Email"), object: emailTextField, underLine: true, anchorBottom: true))
        vStackView.addArrangedSubview(EditInfoView(viewheight: heightForStackItem, title: NSLocalizedString("Password", comment: "Password"), object: passwordTextField, underLine: true, anchorBottom: true))
        
        
        self.view.addSubview(vStackView)
        vStackView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        self.view.addSubview(loginButton)
        loginButton.setAutoresizingToFalse()
        loginButton.anchorCenterX(to: view)
        loginButton.anchorTopTo(to: vStackView, padding: 50)
        
        if isLogIn {
            self.view.addSubview(resetPasswordButton)
            resetPasswordButton.setAutoresizingToFalse()
            resetPasswordButton.anchorCenterX(to: view)
            resetPasswordButton.anchorTopTo(to: loginButton, padding: 20)
        }
    }
    
    @IBAction func logClicked() {
        // 移除鍵盤
        self.view.endEditing(true)
        
        // 輸入驗證
        guard let emailAddress = emailTextField.text, emailAddress != "" else {
            TXAlert.showCenterAlert(message: "Please enter your email address.")
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            TXAlert.showCenterAlert(message: "Please enter your password.")
            return
        }
        
        showBlockingView()
        if isLogIn {
            AuthService.logIn(email: emailAddress, password: password) { (result) in
                self.hideBlockingView()
                if result == .success {
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        } else {
            guard let name = nameTextField.text, name != "" else {
                TXAlert.showCenterAlert(message: "Please enter your user name.")
                return
            }
            
            AuthService.signUp(name: name, email: emailAddress, password: password) { (result) in
                self.hideBlockingView()
                if result == .success {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func resetPassword() {
        self.view.endEditing(true)
        
        guard let emailAddress = emailTextField.text, emailAddress != "" else {
            TXAlert.showCenterAlert(message: "Please enter your email address.")
            return
        }
        
        showBlockingView()
        AuthService.resetPassword(email: emailAddress) { (result) in
            self.hideBlockingView()
        }
    }
}

fileprivate let titleMaxLength = 100
extension LogWithEmailViewController: UITextFieldDelegate {
    // 輸入字數限制
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= titleMaxLength
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      let nextTag = textField.tag + 1
        if let nextResponder = self.view.viewWithTag(nextTag) {
         nextResponder.becomeFirstResponder()
      } else {
        textField.resignFirstResponder()
      }
      return true
    }
}

class TXTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = .systemBlue
        self.textAlignment = .right
        self.font = textFont
        self.textColor = inputTextColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
