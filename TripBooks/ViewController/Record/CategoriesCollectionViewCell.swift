//
//  CategoriesCollectionViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/8.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {
    
    var category: Category? {
        didSet {
            setIconViews()
        }
    }
    
    let iconTitleLabel = UILabel()
    
    var iconImage = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setIconViews() {
        guard let category = self.category else {
            return
        }

        let icon = CategoryIcon(category: category)
        iconImage = icon.geticonImageView()
        self.contentView.addSubview(iconImage)
        iconImage.setAutoresizingToFalse()
        iconImage.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        iconImage.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        
        iconTitleLabel.font = iconTitleLabel.font.withSize(13)
        iconTitleLabel.textColor = .white
        iconTitleLabel.textAlignment = .center
        self.contentView.addSubview(iconTitleLabel)
        iconTitleLabel.text = category.title
        iconTitleLabel.anchor(top: iconImage.bottomAnchor, bottom: self.contentView.bottomAnchor, leading: self.contentView.leadingAnchor, trailing: self.contentView.trailingAnchor)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        for subView in self.contentView.subviews {
            subView.removeFromSuperview()
        }
    }
}
