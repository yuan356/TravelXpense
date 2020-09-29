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

    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        switchPage(page: .Record)
    }
    
    func switchPage(page: AccountingPage) {
        var vc: UIViewController?
        switch page {
        case .Record:
            vc = RecordContainerViewController()
        default:
            break
        }
        
        if let vc = vc {
            self.contentView.addSubview(vc.view)
            self.addChild(vc)
            vc.view.fillSuperview()
        }
    }

}
