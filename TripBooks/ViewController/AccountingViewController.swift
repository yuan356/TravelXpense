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
    case Chart
}

class AccountingViewController: UIViewController {

    var currentRootViewController: UIViewController?
    
    var book: Book!
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        switchPage(page: .Record)
    }
    
    func switchPage(page: AccountingPage) {
        var controller: UIViewController?
        let identifier: String = page.rawValue
        switch page {
        case .Record:
            controller = RecordContainerViewController()
            if let vc = controller as? RecordContainerViewController {
                vc.book = self.book
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
    
    @IBAction func newRecordClicked(_ sender: Any) {
        let controller = RecordDetailViewController()
        present(controller, animated: true, completion: nil)
    }
    
}
