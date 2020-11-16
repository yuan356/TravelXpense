//
//  BlockingViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/11.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class BlockingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TXColor.blurBackground
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.anchorToSuperViewCenter()
        hideView()
    }
    
    func showView() {
        self.view.alpha = 1
    }
    
    func hideView() {
        self.view.alpha = 0
    }

}
