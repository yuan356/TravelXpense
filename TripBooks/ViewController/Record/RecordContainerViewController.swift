//
//  RecordContainerView.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/28.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let daysCell = "daysCell"

fileprivate let collectionViewHeight = CGFloat(80)

fileprivate let infoViewHeight = CGFloat(80)
fileprivate let collectionViewCellWidth = CGFloat(80)
fileprivate let collectionViewCellHeight = CGFloat(40)

protocol recordContainerSelectedDayDelegate: AnyObject {
    func selectedDayChanged(dayIndex: Int)
}

class RecordContainerViewController: UIViewController {

    weak var selectedDayDelegate: recordContainerSelectedDayDelegate?
    
    var book: Book!
    
    let pageViewController = RecordPageViewController()
    
    let slider = UIView()
    
    var daysCollectionView: UICollectionView!
    
    var initDayIndex: Int = 0
    
    let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init book info view (budget)
        self.view.addSubview(infoView)
        infoView.anchor(top: self.view.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, size: CGSize(width: 0, height: infoViewHeight))
        
        // init days CollectionView
        self.addDaysCollectionView()
        
        // init pageViewController for recordViewController
        self.addPageViewController()
    }
    
    
    private func addDaysCollectionView() {
        self.daysCollectionView = initDaysCollectionView()
        self.view.addSubview(daysCollectionView)
        daysCollectionView.anchor(top: infoView.bottomAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, size: CGSize(width: 0, height: collectionViewHeight))
        daysCollectionView.layoutIfNeeded()
        self.setSlider(daysCollectionView)
    }
    
    private func addPageViewController() {
        pageViewController.updatePageDelegate = self
        pageViewController.selectedDayDelegate = self
        pageViewController.book = book
        // TODO: init day (if today in the range of book, set the day)
        pageViewController.currentDayIndex = initDayIndex
        
        self.view.addSubview(pageViewController.view)
        
        self.addChild(pageViewController)
        pageViewController.view.anchor(top: daysCollectionView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)

        pageViewController.view.setAutoresizingToFalse()
    }
}

// MARK: CollectionView functions
extension RecordContainerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.book.days
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: daysCell, for: indexPath) as? RecordDaysCollectionViewCell {
            cell.dayNo = indexPath.row + 1
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pageViewController.updatePage(to: indexPath.row)
        self.moveSlider(collectionView, didSelectItemAt: indexPath)
    }
    
    private func initDaysCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionViewCellWidth, height: collectionViewCellHeight)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .darkGray
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(RecordDaysCollectionViewCell.self, forCellWithReuseIdentifier: daysCell)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }
    
    // MARK: Slider
    private func setSlider(_ collectionView: UICollectionView) {
        self.slider.frame.size = CGSize(width: collectionViewCellWidth, height: 3)
        self.slider.backgroundColor = .white
        self.slider.center.y = collectionView.bounds.maxY - 10
        collectionView.addSubview(self.slider)
        self.moveSlider(collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
    }
    
    private func moveSlider(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        UIView.animate(withDuration: 0.2) {
            self.slider.center.x = cell.center.x
        }
    }
}

extension RecordContainerViewController: pageViewControllerUpdatePageDelegate {
    func didUpdatePageIndex(currentIndex: Int) {
        self.moveSlider(daysCollectionView, didSelectItemAt: IndexPath(row: currentIndex, section: 0))
    }
}


extension RecordContainerViewController: pageViewControllerSelectedDayDelegate {
    func selectedDayChanged(dayIndex: Int) {
        self.selectedDayDelegate?.selectedDayChanged(dayIndex: dayIndex)
    }
}

