//
//  BookDetailViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

// height
fileprivate let heightForBookNameHeader: CGFloat = 50
fileprivate let heightForTabBar: CGFloat = 80

// color
fileprivate let headerViewColor: UIColor = .blue
fileprivate let tabBarColor: UIColor = TBColor.darkGary

enum TabBarPage: String {
    case chart
    case record
    case bookinfo
}

class BookDetailViewController: UIViewController {

    var currentRootViewController: UIViewController?
    
    var currentBook: Book {
        return BookService.shared.currentOpenBook
    }
    
    var currentTabButton: UIButton?
    
    // for edit record
    var selectedDay: Date?
    
    lazy var tabBarView = UIView {
        let tab = UIView()
        tab.backgroundColor = .blue
        $0.addSubview(tab)
        tab.anchorViewOnBottom(height: 50)
        
        let clearView = UIView()
        clearView.backgroundColor = .clear
        $0.addSubview(clearView)
        clearView.anchor(top: $0.topAnchor, bottom: tab.topAnchor, leading: $0.leadingAnchor, trailing: $0.trailingAnchor)
        
        $0.anchorSize(height: heightForTabBar)
    }
    
    lazy var contentView = UIView {
        $0.backgroundColor = .brown
    }
    
    lazy var headerView = UIView {
        $0.anchorSize(height: heightForBookNameHeader)
        $0.backgroundColor = headerViewColor
    }
    
    var tabViewController = TBtabViewController(pages: [
        ViewControllerPage(type: .chart),
        ViewControllerPage(type: .record),
        ViewControllerPage(type: .bookinfo)
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        setViews()
        
        addViewControllerToContainerView(containerView: tabBarView, controller: tabViewController)
        tabViewController.delegate = self
        
        // init page
        switchPage(page: .Record)
    }
    
    // MARK: setViews
    private func setViews() {
        self.view.addSubview(tabBarView)
        tabBarView.anchor(top: nil, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        let bottomSafeAreaView = UIView()
        bottomSafeAreaView.backgroundColor = tabBarColor
        
        self.view.addSubview(bottomSafeAreaView)
        bottomSafeAreaView.anchor(top: tabBarView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        self.view.addSubview(headerView)
        headerView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        let topSafeAreaView = UIView()
        self.view.addSubview(topSafeAreaView)
        topSafeAreaView.backgroundColor = headerViewColor
        topSafeAreaView.anchor(top: self.view.topAnchor, bottom: headerView.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        self.view.addSubview(contentView)
        contentView.anchor(top: headerView.bottomAnchor, bottom: tabBarView.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
    }
    
    private func addTabBarButtons() {
        
    }
    
    private func addViewControllerToContainerView(containerView: UIView, controller: UIViewController) {
        if let view = controller.view {
            containerView.addSubview(view)
            view.fillSuperview()
        }
    }
    
    // MARK: switchPage
    private func switchPage(page: AccountingPage) {
        var controller: UIViewController?
        let identifier: String = page.rawValue
        switch page {
        case .Record:
            controller = RecordContainerViewController()
            if let vc = controller as? RecordContainerViewController {
                vc.book = self.currentBook
                vc.selectedDayDelegate = self
            }
        case .Setting:
            controller = BookSettingViewController()
            if let vc = controller as? BookSettingViewController {
                vc.book = self.currentBook
            }
        default:
            break
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
    }
    // MARK: - Button clicked
    // MARK: Add new record clickded
    @IBAction func newRecordClicked(_ sender: Any) {
        if currentRootViewController?.restorationIdentifier !=
            AccountingPage.Record.rawValue {
            switchPage(page: .Record)
            return
        }
        
        let controller = RecordDetailViewController()
        controller.recordDate = self.selectedDay
        controller.originalDate = self.selectedDay
        controller.book = currentBook
        present(controller, animated: true, completion: nil)
    }
}

extension BookDetailViewController: recordContainerSelectedDayDelegate {
    func selectedDayChanged(dayIndex: Int) {
        if let date = TBFunc.getDateByOffset(startDate: self.currentBook.startDate, daysInterval: dayIndex) {
            self.selectedDay = date
        }
    }
}

extension BookDetailViewController: TBtabViewControllerDelegate {
    func switchPage(identifier: String, button: UIButton) {
        var controller: UIViewController?
        
        if let page = TabBarPage.init(rawValue: identifier) {
            switch page {
            case .chart:
                break
            case .record:
                controller = RecordContainerViewController()
                if let vc = controller as? RecordContainerViewController {
                    vc.book = self.currentBook
                    vc.selectedDayDelegate = self
                }
            case .bookinfo:
                controller = BookSettingViewController()
                if let vc = controller as? BookSettingViewController {
                    vc.book = self.currentBook
                }
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

