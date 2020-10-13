//
//  AccountionPageViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

/// called when dayCollectionView value changed
protocol pageViewControllerUpdatePageDelegate: AnyObject {
    func didUpdatePageIndex(currentIndex: Int)
}

/// called when selected day changed
protocol pageViewControllerSelectedDayDelegate: AnyObject {
    func selectedDayChanged(dayIndex: Int)
}

class RecordPageViewController: UIPageViewController {

    var totalDays: Int = 0

    var currentDayIndex : Int = 0 {
        didSet {
            self.selectedDayDelegate?.selectedDayChanged(dayIndex: currentDayIndex)
        }
    }
    
    weak var updatePageDelegate: pageViewControllerUpdatePageDelegate?
    
    weak var selectedDayDelegate: pageViewControllerSelectedDayDelegate?
    
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
        if let startingVC = contentViewController(at: currentDayIndex) {
            self.setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
            self.updatePageDelegate?.didUpdatePageIndex(currentIndex: currentDayIndex)
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
        guard dayIndex >= 0 && dayIndex < self.totalDays else {
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
                self.currentDayIndex = vc.dayIndex
                self.updatePageDelegate?.didUpdatePageIndex(currentIndex: currentDayIndex)
            }
        }
    }
    
    func updatePage(to index: Int) {
        guard self.currentDayIndex != index else {
            return
        }
        let directtion: NavigationDirection = (self.currentDayIndex < index) ? .forward : .reverse
        self.currentDayIndex = index
        if let vc = self.contentViewController(at: currentDayIndex) {
            self.setViewControllers([vc], direction: directtion, animated: true, completion: nil)
        }
    }
}




