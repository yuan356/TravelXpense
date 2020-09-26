//
//  AccountionPageViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class AccountionPageViewController: UIPageViewController {

    var days: [Int] = [1, 2, 3, 4, 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        // first viewController
        if let startingVC = contentViewController(at: 0) {
            self.setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
        }
    }

}

extension AccountionPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! RecordViewController).index
        index -= 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! RecordViewController).index
        index += 1
        return contentViewController(at: index)
    }
    
    func contentViewController(at index: Int) -> RecordViewController? {
        guard index >= 0 && index < self.days.count else {
            return nil
        }
        
        // init new RecordViewController
        let recordVC = RecordViewController()
        recordVC.index = index
        return recordVC
    }
}
