//
//  BookDetailViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

// height
fileprivate let heightForBookNameHeader: CGFloat = 60

// color
fileprivate let headerViewColor: UIColor = TBColor.shamrockGreen.light

enum TabBarPage: String {
    case chart
    case record
    case bookinfo
}

class BookContainerViewController: UIViewController {

    var currentRootViewController: UIViewController?
    
    var currentBook: Book {
        return BookService.shared.currentOpenBook
    }
    
    var currentTabButton: UIButton?
    
    // for edit record
    var selectedDay: Date?
    
    lazy var tabBarView = UIView {
        $0.backgroundColor = tabBarColor
    }
    
    
    lazy var tabBarContainerView = UIView {
        let heightForTabBarContainer =
            ((HeightForTabBarView - heightForTabBarButton) / 2 + (heightForTabBarButton / 2)
                + moveUpOffset) * 2
        $0.anchorSize(h: heightForTabBarContainer)
    }
    
    var tabViewController = TBTabViewController(pages: [
        ViewControllerPage(type: .chart),
        ViewControllerPage(type: .record),
        ViewControllerPage(type: .bookinfo)
    ])
    
    lazy var contentView = UIView()
    
    lazy var homeButton: UIButton = {
        let btn = TBButton.home.getButton()
        btn.anchorSize(h: 30, w: 30)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(homeBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    lazy var headerView = UIView {
        $0.anchorSize(h: heightForBookNameHeader)
        $0.backgroundColor = headerViewColor
        $0.addSubview(homeButton)
        homeButton.anchor(top: $0.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: $0.leadingAnchor, trailing: nil, padding: UIEdgeInsets(top: 15, left: 20, bottom: 0, right: 0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        
        addViewControllerToContainerView(containerView: tabBarContainerView, controller: tabViewController)
        tabViewController.delegate = self
        
        // get all accounts to chche
        AccountService.shared.getAllAccountsFromBook(bookId: currentBook.id)
        
        // init page
        switchPage(identifier: TabBarPage.record.rawValue)
    }
    
    /*
      -------------
     | headerView  |
      -------------
     | contentView |
      -------------
     | tabBarContainerView |
      ---------------------
     */
    
    // MARK: setViews
    private func setViews() {
        tabBarViewSetting()
        
        self.view.addSubview(tabBarContainerView)
        tabBarContainerView.anchor(top: nil, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        let bottomSafeAreaView = UIView()
        bottomSafeAreaView.backgroundColor = tabBarColor
        
        self.view.addSubview(bottomSafeAreaView)
        bottomSafeAreaView.anchor(top: tabBarContainerView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        self.view.addSubview(headerView)
        headerView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        let topSafeAreaView = UIView()
        self.view.addSubview(topSafeAreaView)
        topSafeAreaView.backgroundColor = headerViewColor
        topSafeAreaView.anchor(top: self.view.topAnchor, bottom: headerView.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        self.view.addSubview(contentView)
        contentView.anchor(top: headerView.bottomAnchor, bottom: tabBarView.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        self.view.bringSubviewToFront(tabBarContainerView)
    }
    
    private func tabBarViewSetting() {
       
        tabBarContainerView.addSubview(tabBarView)
        tabBarView.anchorViewOnBottom(height: HeightForTabBarView)

        // clear view, 位於 content view 之後。
        let clearView = UIView()
        clearView.backgroundColor = .clear
        tabBarContainerView.addSubview(clearView)
        clearView.anchor(top: tabBarContainerView.topAnchor, bottom: tabBarView.topAnchor, leading: tabBarContainerView.leadingAnchor, trailing: tabBarContainerView.trailingAnchor)
    }
    
    private func addViewControllerToContainerView(containerView: UIView, controller: UIViewController) {
        if let view = controller.view {
            containerView.addSubview(view)
            view.fillSuperview()
        }
    }
    
    @IBAction func homeBtnClicked() {
        BookService.shared.currentOpenBook = nil
        dismiss(animated: true, completion: nil)
    }
}

extension BookContainerViewController: recordContainerSelectedDayDelegate {
    func selectedDayChanged(dayIndex: Int) {
        if let date = TBFunc.getDateByOffset(startDate: self.currentBook.startDate, daysInterval: dayIndex) {
            self.selectedDay = date
        }
    }
}

extension BookContainerViewController: TBTabViewControllerDelegate {
    // MARK: switchPage
    func switchPage(identifier: String) {
        var controller: UIViewController?
        
        if let page = TabBarPage.init(rawValue: identifier) {
            switch page {
            case .chart:
                let vc = ChartViewController()
                vc.book = self.currentBook
                controller = vc
            case .record:
                let vc = RecordContainerViewController()
                vc.book = self.currentBook
                vc.selectedDayDelegate = self
                controller = vc
            case .bookinfo:
                let vc = BookSettingViewController()
                vc.book = self.currentBook
                controller = UINavigationController(rootViewController: vc)
            }
        }
        
        controller?.restorationIdentifier = identifier

        if let controller = controller, controller.restorationIdentifier != currentRootViewController?.restorationIdentifier {
            
            // remove
            self.currentRootViewController?.removeFromParent()
            self.currentRootViewController?.view.removeFromSuperview()
            
            // add
            self.addChild(controller)
            addViewControllerToContainerView(containerView: self.contentView, controller: controller)
            self.currentRootViewController = controller
        } else if let controller = controller,
                  controller.restorationIdentifier == TabBarPage.record.rawValue {
            let vc = RecordDetailViewController()
            vc.recordDate = self.selectedDay
            vc.originalDate = self.selectedDay
            vc.book = currentBook
            present(vc, animated: true, completion: nil)
        }
    }
}

