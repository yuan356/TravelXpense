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
    
    lazy var contentView = UIView {
        $0.backgroundColor = .clear
    }
    
    lazy var homeButton: UIButton = {
        let btn = TXNavigationIcon.home.getButton()
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(homeBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    lazy var bookNameLabel = UILabel {
        $0.font = MainFont.medium.with(fontSize: 22)
        $0.text = currentBook.name
        $0.textColor = .white
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    
    lazy var headerView = UIView {
        $0.anchorSize(h: heightForBookNameHeader)
        $0.roundedCorners(radius: 20, roundedType: .bottom)
        $0.addSubview(homeButton)
        homeButton.anchorButtonToHeader(position: .left, height: 30)
        
        $0.addSubview(bookNameLabel)
        bookNameLabel.setAutoresizingToFalse()
        bookNameLabel.anchorCenterY(to: $0)
        bookNameLabel.anchorCenterX(to: $0)
        bookNameLabel.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: 15).isActive = true
    }
    
    var observer: TXObserver!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = TXColor.background()
        setViews()
        
        addViewControllerToContainerView(containerView: tabBarContainerView, controller: tabViewController)
        tabViewController.delegate = self
        
        observer = TXObserver.init(notification: .bookNameUpdate, infoKey: .bookName)
        observer.delegate = self
        
        // get all accounts to cache
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
        
        // tabBarContainerView
        self.view.addSubview(tabBarContainerView)
        tabBarContainerView.anchor(top: nil, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        let bottomSafeAreaView = UIView()
        bottomSafeAreaView.backgroundColor = tabBarColor
        
        self.view.addSubview(bottomSafeAreaView)
        bottomSafeAreaView.anchor(top: tabBarContainerView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        // headerView
        self.view.addSubview(headerView)
        headerView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        let topSafeAreaView = UIView()
        self.view.addSubview(topSafeAreaView)
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return DisplayMode.statusBarStyle()
    }
}

extension BookContainerViewController: ObserverProtocol {
    func handleNotification(infoValue: Any?) {
        if let bookName = infoValue as? String {
            self.bookNameLabel.text = bookName
        }
    }
}

extension BookContainerViewController: recordContainerSelectedDayDelegate {
    func selectedDayChanged(dayIndex: Int) {
        if let date = TXFunc.getDateByOffset(startDate: self.currentBook.startDate, daysInterval: dayIndex) {
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
                let vc = BookDetailViewController()
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
        }
        else if let controller = controller, // Add new record
                  controller.restorationIdentifier == TabBarPage.record.rawValue {
            let vc = RecordDetailViewController()
            vc.recordDate = self.selectedDay
            vc.originalDate = self.selectedDay
            vc.recordAccount = AccountService.shared.getDefaultAccount(bookId: currentBook.id)
            vc.book = currentBook
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}

