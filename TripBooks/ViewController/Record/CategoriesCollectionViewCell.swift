//
//  CategoriesCollectionViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/8.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {
    
    var categories = [Category]()
    
    let title =  UILabel()
    
    var num = 0 {
        didSet {
            title.text = "\(num)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(title)
        title.anchorToSuperViewCenter()
        self.backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
