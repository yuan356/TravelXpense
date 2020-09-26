//
//  AccountingViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class AccountingViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pageViewController = AccountionPageViewController()
        
        contentView.addSubview(pageViewController.view)
        pageViewController.view.fillSuperview()
    }

}
