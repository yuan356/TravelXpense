//
//  VPtabViewController.swift
//  VideoPlayerApp
//
//  Created by 阿遠 on 2020/8/27.
//  Copyright © 2020 阿遠. All rights reserved.
//

import UIKit

protocol TBtabViewControllerDelegate: AnyObject {
    func switchPage(identifier: String)
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
//        for subview in self.view.subviews {
//            subview.removeConstraints(subview.constraints)
//            subview.removeFromSuperview()
//        }
        
//        for (index, page) in self.pages.enumerated() {
//            addTabButton(page: page, isLast: (index == pages.count-1))
//        }
        for page in self.pages {
            addTabButton(page: page)
        }
    }
    
    func addTabButton(page: ViewControllerPage) {
        let button = page.buttonImage.getButton()
        button.restorationIdentifier = page.pageType.rawValue
        button.anchorSize(height: 35)
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.addTarget(self, action: #selector(TBtabViewController.tabClicked(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        
        button.setAutoresizingToFalse()
        button.anchorCenterY(to: view)
        
        switch page.pageType {
        case .chart:
            button.anchorSuperViewLeading(padding: 8)
        case .record:
            button.anchorCenterX(to: view)
        case .bookinfo:
            button.anchorSuperViewTrailing(padding: 8)
        }
    }

    @IBAction func tabClicked(_ sender: UIButton) {
        if let identifier = sender.restorationIdentifier {
            self.delegate?.switchPage(identifier: identifier)
        }
    }
}
