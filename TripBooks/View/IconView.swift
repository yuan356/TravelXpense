//
//  CategoryIcon.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/7.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let heightForBackgroundView: CGFloat = 45
fileprivate let iconPaddingInView: CGFloat = 8

class IconView {
    
    var category: Category? = nil
    
    var iconImageName: String? = nil
    
    let itemHeight = heightForBackgroundView
    
    init(category: Category) {
        self.category = category
    }
    
    init(iconImageName: String) {
        self.iconImageName = iconImageName
    }
    
    let iconBackgroundView: UIView = {
        let itemHeight = heightForBackgroundView
        let view = UIView()
        view.backgroundColor = .yellow
        view.layer.cornerRadius = itemHeight / 2
        view.anchorSize(height: itemHeight, width: 0)
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return view
    }()
    
    let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        let height = heightForBackgroundView - (iconPaddingInView * 2)
        iconImageView.anchorSize(height: height, width: 0)
        iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor).isActive = true
        
        return iconImageView
    }()
    
    
    /// return Icon ImageView(size: 45)
    /// - Returns: UIView
    func geticonImageView() -> UIView {
        iconBackgroundView.addSubview(iconImageView)
        iconImageView.anchorToSuperViewCenter()
//        iconImageView.tintColor = UIColor.init(hex: "#F5F5F5")
        iconImageView.tintColor = .black
        
        if let category = self.category {
            let color = UIColor(hex: "#" + category.colorHex)
            iconBackgroundView.backgroundColor = color
            
            if category.iconImageName != "" {
                iconImageView.image = UIImage(named: category.iconImageName)
            }
        } else if let iconImageName = self.iconImageName, iconImageName != "" {
            iconBackgroundView.backgroundColor  = TBColor.gary
            iconImageView.image = UIImage(named: iconImageName)
        }
        
        
        return iconBackgroundView
    }
}
