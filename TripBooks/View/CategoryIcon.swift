//
//  CategoryIcon.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/7.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let heightForView: CGFloat = 60
fileprivate let cellHpadding: CGFloat = 15
fileprivate let cellVpadding: CGFloat = 8

fileprivate let iconPaddingInView: CGFloat = 8

class CategoryIcon {
    var category: Category
    
    let iconBackgroundView: UIView = {
        let itemHeight = heightForView - (cellVpadding * 2)
        let view = UIView()
        view.backgroundColor = .yellow
        view.layer.cornerRadius = itemHeight / 2
        view.anchorSize(height: itemHeight, width: 0)
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return view
    }()
    
    let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        
        let iconViewHeight = heightForView - (cellVpadding * 2)
        let iconImageViewHeight = iconViewHeight - (iconPaddingInView * 2)
        iconImageView.anchorSize(height: iconImageViewHeight, width: 0)
        iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor).isActive = true
        
        return iconImageView
    }()
    
    init(category: Category) {
        self.category = category
    }
    
    func geticonImage() -> UIView {
        iconBackgroundView.addSubview(iconImageView)
        iconImageView.anchorToSuperViewCenter()
        
        iconBackgroundView.backgroundColor = category.color
        iconImageView.image = UIImage(named: category.iconName)
        
        return iconBackgroundView
    }
}
