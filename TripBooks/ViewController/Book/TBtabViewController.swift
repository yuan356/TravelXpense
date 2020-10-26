//
//  VPtabViewController.swift
//  VideoPlayerApp
//
//  Created by 阿遠 on 2020/8/27.
//  Copyright © 2020 阿遠. All rights reserved.
//

import UIKit

protocol TBtabViewControllerDelegate: AnyObject {
    func switchPage(identifier: String, button: UIButton)
}

struct ViewControllerPage {
 
    var pageType: TabBarPage
    var buttonImage: TBButton
    
    init(type: TabBarPage) {
        self.pageType = type
        switch type {
        case .chart:
            buttonImage = .chart
        case .record:
            buttonImage = .plus
        case .bookinfo:
            buttonImage = .settings
        }
    }
}

class TBtabViewController: UIViewController {

    weak var delegate: TBtabViewControllerDelegate?
    
    var pages: [ViewControllerPage] = []
    
    init(pages: [ViewControllerPage]) {
        super.init(nibName: nil, bundle: nil)
        self.pages = pages
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.initTabButtons()
        // Do any additional setup after loading the view.
    }
    
    func initTabButtons() {
        
        // 清空subviews避免誤用第二次
        for subview in self.view.subviews {
            subview.removeConstraints(subview.constraints)
            subview.removeFromSuperview()
        }
    
        for page in self.pages {
            addTabButton(page: page)
        }
    }
    
    func addTabButton(page: ViewControllerPage) {
        let button = page.buttonImage.getButton()
        button.restorationIdentifier = page.pageType.rawValue
        button.tintColor = .white
        button.anchorSize(height: 30)
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.addTarget(self, action: #selector(TBtabViewController.tabClicked(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        
        button.setAutoresizingToFalse()
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10).isActive = true
        
        switch page.pageType {
        case .chart:
            button.anchorSuperViewLeading(padding: 12)
        case .record:
            button.anchorCenterX(to: view)
        case .bookinfo:
            button.anchorSuperViewTrailing(padding: 12)
        }
        

    }

    @IBAction func tabClicked(_ sender: UIButton) {
        if let superView = sender.superview {
            sender.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
            let backImage = UIView()
            backImage.backgroundColor = .brown
            backImage.anchorSize(height: 50)
            backImage.roundedCorners(radius: 25)
            backImage.setAutoresizingToFalse()
            backImage.widthAnchor.constraint(equalTo: backImage.heightAnchor).isActive = true
            self.view.addSubview(backImage)
            backImage.anchorCenterX(to: sender)
            backImage.anchorCenterY(to: sender)
    
            superView.bringSubviewToFront(sender)
        }
        
        
        if let identifier = sender.restorationIdentifier {
            self.delegate?.switchPage(identifier: identifier, button: sender)
        }
    }
}
