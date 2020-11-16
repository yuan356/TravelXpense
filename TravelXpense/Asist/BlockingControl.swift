//
//  BlockingControl.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class TXViewController: UIViewController {
    
    var blockingViewController: BlockingViewController?
    
    func showBlockingView() {
        self.blockingViewController = BlockingViewController()
        if let controller = self.blockingViewController {
            self.view.addSubview(controller.view)
            controller.view.fillSuperview()
            self.addChild(controller)
            UIView.animate(withDuration: 0.3) {
                controller.showView()
            }
        }
    }
    
    func hideBlockingView() {
        if let controller = self.blockingViewController {
            UIView.animate(withDuration: 0.3, animations: {
                controller.hideView()
            }) { (_) in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.blockingViewController = nil
            }
        }
    }
}
