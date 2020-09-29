//
//  AccountionPageViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

protocol AccountionPageViewControllerDelegate: AnyObject {
    func didUpdatePageIndex(currentIndex: Int)
}

class RecordPageViewController: UIPageViewController {

    var days: [Int] = [1, 2, 3, 4, 5]
    
    var currentIndex = 0
    
    weak var pageDelegate: AccountionPageViewControllerDelegate?
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        // first viewController
        if let startingVC = contentViewController(at: 0) {
            self.setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
        }
    }

}

extension RecordPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let vc = pageViewController.viewControllers?.first as? RecordViewController {
                currentIndex = vc.index
                print(currentIndex)
                self.pageDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }
    
//    func forwardPage() {
//        self.currentIndex += 1
//        if let vc = self.contentViewController(at: currentIndex) {
//            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
//        }
//    }
}
