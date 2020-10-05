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

    var days: Int = 0
    
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
        
        // first show viewController
        if let startingVC = contentViewController(at: 0) {
            self.setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
        }
    }

}

extension RecordPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var dayIndex = (viewController as! RecordTableViewController).dayIndex
        dayIndex -= 1
        return contentViewController(at: dayIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var dayIndex = (viewController as! RecordTableViewController).dayIndex
        dayIndex += 1
        return contentViewController(at: dayIndex)
    }
    
    func contentViewController(at dayIndex: Int) -> RecordTableViewController? {
        guard dayIndex >= 0 && dayIndex < self.days else {
            return nil
        }
        
        // init new RecordViewController
        let recordTableViewVC = RecordTableViewController()
        recordTableViewVC.dayIndex = dayIndex
        return recordTableViewVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let vc = pageViewController.viewControllers?.first as? RecordTableViewController {
                currentIndex = vc.dayIndex
                self.pageDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }
    
    func updatePage(to index: Int) {
        guard self.currentIndex != index else {
            return
        }
        let directtion: NavigationDirection = (self.currentIndex < index) ? .forward : .reverse
        self.currentIndex = index
        if let vc = self.contentViewController(at: currentIndex) {
            self.setViewControllers([vc], direction: directtion, animated: true, completion: nil)
        }
    }
}
