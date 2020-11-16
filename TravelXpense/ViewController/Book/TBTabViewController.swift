//
//  VPtabViewController.swift
//  VideoPlayerApp
//
//  Created by 阿遠 on 2020/8/27.
//  Copyright © 2020 阿遠. All rights reserved.
//

import UIKit

protocol TBTabViewControllerDelegate: AnyObject {
    func switchPage(identifier: String)
}

// Don't change, it've been calculated.
let heightForTabBarButton: CGFloat = 35
let heightForTabBtnSelected: CGFloat = 44
let heightForTabBtnBackView: CGFloat = 55 // same as HeightForTabBarView
let HeightForTabBarView: CGFloat = 55
let moveUpOffset: CGFloat = 12

let tabBarColor: UIColor = TXColor.system.blue.medium

fileprivate let btnColor: UIColor = TXColor.system.veronese

struct ViewControllerPage {
 
    var pageType: TabBarPage
    var buttonImage: TXNavigationIcon
    
    init(type: TabBarPage) {
        self.pageType = type
        switch type {
        case .chart:
            buttonImage = .chart
        case .record:
            buttonImage = .plus
        case .bookinfo:
            buttonImage = .more
        }
    }
}

class TBTabViewController: UIViewController {

    weak var delegate: TBTabViewControllerDelegate?
    
    let moveDownTransform = CGAffineTransform.init(translationX: 0, y: moveUpOffset)
    
    var currentButton: UIButton?
    
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
    
    private func initTabButtons() {
        
        // 清空subviews避免誤用第二次
        for subview in self.view.subviews {
            subview.removeConstraints(subview.constraints)
            subview.removeFromSuperview()
        }
    
        for page in self.pages {
            addTabButton(page: page)
        }
        
        // default select record button
        if let btn = currentButton {
            selectButtonAnimation(btn)
        }
    }
    
    private func addTabButton(page: ViewControllerPage) {
        let backView = self.getBackView()
        self.view.addSubview(backView)
        backView.setAutoresizingToFalse()
        
        let selectedBackView = self.getSelectedBackView()
        backView.addSubview(selectedBackView)
        selectedBackView.anchorToSuperViewCenter()
        
        let button = page.buttonImage.getButton()
        button.restorationIdentifier = page.pageType.rawValue
        button.tintColor = .white
        button.anchorSize(h: heightForTabBarButton)
        button.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.addTarget(self, action: #selector(TBTabViewController.tabClicked(_:)), for: .touchUpInside)
        
        selectedBackView.addSubview(button)
        button.anchorToSuperViewCenter()

        backView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backView.transform = moveDownTransform
        switch page.pageType {
        case .chart:
            backView.anchorSuperViewLeading(padding: 12)
        case .record:
            backView.anchorCenterX(to: view)
        case .bookinfo:
            backView.anchorSuperViewTrailing(padding: 12)
        }
        
        if page.pageType == .record {
            currentButton = button // record is default select button
        }
    }
    
    // MARK: Button setting, animation
    private func getBackView() -> UIView {
        let backView = UIView {
            $0.backgroundColor = tabBarColor
            let height = heightForTabBtnBackView
            $0.anchorSize(h: height, w: height)
            $0.roundedCorners(radius: height / 2)
        }
        return backView
    }
    
    private func getSelectedBackView() -> UIView {
        let backView = UIView {
            let height = heightForTabBtnSelected
            $0.anchorSize(h: height, w: height)
            $0.roundedCorners(radius: height / 2)
        }
        return backView
    }

    @IBAction func tabClicked(_ sender: UIButton) {
        if let btn = currentButton {
            deseletctButtonAnimation(btn)
        }
        
        currentButton = sender
        selectButtonAnimation(sender)
        
        if let identifier = sender.restorationIdentifier {
            self.delegate?.switchPage(identifier: identifier)
        }
    }
    
    private func selectButtonAnimation(_ button: UIButton) {
        button.superview?.backgroundColor = btnColor
        UIView.animate(withDuration: 0.08) {
            button.superview?.superview?.transform = .identity
        }
    }
    
    private func deseletctButtonAnimation(_ button: UIButton) {
        button.superview?.backgroundColor = .clear
        UIView.animate(withDuration: 0.08) {
            button.superview?.superview?.transform = self.moveDownTransform
        }
    }
}
