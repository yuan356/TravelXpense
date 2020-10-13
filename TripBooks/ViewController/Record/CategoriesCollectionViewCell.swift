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
    
    var categoryIsSelected = false {
        didSet {
            iconSelectedBackground.isHidden = !categoryIsSelected
        }
    }
    
    let iconSelectedBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
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
        
        self.contentView.addSubview(iconSelectedBackground)
        iconSelectedBackground.setAutoresizingToFalse()
        iconSelectedBackground.centerXAnchor.constraint(equalTo: iconImage.centerXAnchor).isActive = true
        iconSelectedBackground.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor).isActive = true
        iconSelectedBackground.widthAnchor.constraint(equalTo: iconImage.widthAnchor, constant: 5).isActive = true
        iconSelectedBackground.heightAnchor.constraint(equalTo: iconImage.heightAnchor, constant: 5).isActive = true
        iconSelectedBackground.roundedCorners(radius: (icon.itemHeight + 5) / 2)
        self.contentView.sendSubviewToBack(iconSelectedBackground)
        iconSelectedBackground.isHidden = true
        
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
