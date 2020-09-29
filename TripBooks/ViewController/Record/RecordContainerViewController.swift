//
//  RecordContainerView.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/28.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let daysCell = "daysCell"

fileprivate let collectionViewHeight = 80
fileprivate let collectionViewWidth = 0

class RecordContainerViewController: UIViewController {

    let pageViewController = RecordPageViewController()
    
    var slider = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let daysCollectionView = initDaysCollectionView()
        self.view.addSubview(daysCollectionView)
        daysCollectionView.anchor(top: self.view.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        daysCollectionView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        daysCollectionView.layoutIfNeeded()
        self.setSlider(daysCollectionView)
        
        self.view.addSubview(pageViewController.view)
        self.addChild(pageViewController)
        pageViewController.view.anchor(top: daysCollectionView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)

        pageViewController.view.setAutoresizingToFalse()
    }
}

// MARK: CollectionView functions
extension RecordContainerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: daysCell, for: indexPath) as? RecordDaysCollectionViewCell {
            cell.dayNo = indexPath.row + 1
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.moveSlider(collectionView, didSelectItemAt: indexPath)
    }
    
    private func initDaysCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .darkGray
        collectionView.register(RecordDaysCollectionViewCell.self, forCellWithReuseIdentifier: daysCell)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }
    
    // MARK: slider
    private func setSlider(_ collectionView: UICollectionView) {
        self.slider = UIView()
        self.slider.frame.size = CGSize(width: 80, height: 3)
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
        UIView.animate(withDuration: 0.3) {
            self.slider.center.x = cell.center.x
        }
    }
}

class RecordDaysCollectionViewCell: UICollectionViewCell {
    
    var dayNo = 0 {
        didSet {
            indexLabel.text = "day \(dayNo)"
        }
    }
    
    let indexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(indexLabel)
        indexLabel.anchorToSuperViewCenter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

