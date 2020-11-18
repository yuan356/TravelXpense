//
//  SignUpViewController.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/14.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

private enum SignUpType: String {
    case google
    case facebook
    case email
}

class LogViewController: TXViewController {
    
    var isLogIn: Bool! {
        didSet {
            if isLogIn {
                self.navigationItem.title = "Log in"
            } else {
                
            }
        }
    }

    lazy var cancelBtn: UIButton = {
        let btn = TXNavigationIcon.cancel.getButton()
        btn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
        btn.anchorSize(h: 25, w: 25)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TXColor.background()
        
        setViews()
    }
    
    private func setViews() {
        let emptyImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .default)
        self.navigationController?.navigationBar.shadowImage = emptyImage
        self.navigationItem.title = isLogIn ? "Log in" : "Sign up"
        
        let saveBarItem = UIBarButtonItem(customView: cancelBtn)
        navigationItem.leftBarButtonItem = saveBarItem
        
        let googleBtn = getButton(type: .google)
        self.view.addSubview(googleBtn)
        googleBtn.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 50, left: 50, bottom: 0, right: 50))
        googleBtn.anchorCenterX(to: view)
        
        let fbBtn = getButton(type: .facebook)
        self.view.addSubview(fbBtn)
        fbBtn.anchor(top: googleBtn.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 50, bottom: 0, right: 50))
        
        fbBtn.anchorCenterX(to: view)
        
        let emailBtn = getButton(type: .email)
        self.view.addSubview(emailBtn)
        emailBtn.anchor(top: fbBtn.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 50, bottom: 0, right: 50))
        emailBtn.anchorCenterX(to: view)
        
    }
    
    private func getButton(type: SignUpType) -> UIButton {
        let str = isLogIn ? "Log in" : "Sign up"
        let btn = TXButton {
            $0.roundedCorners()
            
            switch type {
            case .google:
                $0.addTarget(self, action: #selector(googleBtnClicked), for: .touchUpInside)
                $0.backgroundColor = UIColor(hex: "DE5F45")
                $0.setTitle(str + " with Google", for: .normal)
            case .facebook:
                $0.addTarget(self, action: #selector(facebookBtnClicked), for: .touchUpInside)
                $0.backgroundColor = UIColor(hex: "4B6EA8")
                $0.setTitle(str + " with Facebook", for: .normal)
            case .email:
                $0.addTarget(self, action: #selector(emailBtnClicked), for: .touchUpInside)
                $0.layer.borderColor = UIColor.white.cgColor
                $0.layer.borderWidth = 1
                $0.setTitle(str + " with email", for: .normal)
            }
            let image = UIImage(named: type.rawValue)
            $0.setImage(image, for: .normal)
            $0.imageView?.tintColor = .white
            $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
            $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
            $0.titleLabel?.textAlignment = .center
            $0.anchorSize(h: 45)
        }
        
        return btn
    }
    
    @IBAction func cancelBtnClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func googleBtnClicked() {
    }
    
    @IBAction func facebookBtnClicked() {
        showBlockingView()
        AuthService.fbLogin(vc: self) { (result) in
            self.hideBlockingView()
            if result == .success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func emailBtnClicked() {
        let vc = LogWithEmailViewController()
        vc.isLogIn = isLogIn
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
