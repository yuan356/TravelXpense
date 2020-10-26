//
//  AccountingViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum AccountingPage: String {
    case Record
    case Setting
    case Chart
}

class AccountingViewController: UIViewController {

    var currentRootViewController: UIViewController?
    
    var currentBook: Book {
        return BookService.shared.currentOpenBook
    }
    
    var selectedDay: Date?
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // defalut page
        switchPage(page: .Record)
    }

    func switchPage(page: AccountingPage) {
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
    
    func addViewControllerToContainerView(containerView: UIView, controller: UIViewController) {
        if let view = controller.view {
            containerView.addSubview(view)
            view.fillSuperview()
        }
    }
    
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
    
    // MARK: Home button clickded
    @IBAction func homeButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Setting clicked
    @IBAction func settingClicked(_ sender: Any) {
        switchPage(page: .Setting)
    }
}

extension AccountingViewController: recordContainerSelectedDayDelegate {
    func selectedDayChanged(dayIndex: Int) {
        if let date = TBFunc.getDateByOffset(startDate: self.currentBook.startDate, daysInterval: dayIndex) {
            self.selectedDay = date
        }
    }
}
