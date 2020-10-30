//
//  CategoriesCollectionViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/8.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class IconsCollectionViewCell<U>: UICollectionViewCell {
    
    var item: U!
    
    lazy var iconTitleLabel = UILabel()
    
    lazy var iconImage = UIView()
    
    var itemIsSelected = false {
        didSet {
            iconSelectedBackground.isHidden = !itemIsSelected
        }
    }
    
    lazy var iconSelectedBackground = UIView {
        $0.backgroundColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupIconViews(imageName: String, title: String? = nil, colorHex: String? = nil) {

        let icon = IconView(imageName: imageName, colorHex: colorHex)
//        iconImage = icon.geticonImageView()
        iconImage = icon
        self.contentView.addSubview(iconImage)
        iconImage.setAutoresizingToFalse()
        iconImage.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        iconImage.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        
        self.contentView.addSubview(iconSelectedBackground)
        iconSelectedBackground.setAutoresizingToFalse()
        iconSelectedBackground.centerXAnchor.constraint(equalTo: iconImage.centerXAnchor).isActive = true
        iconSelectedBackground.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor).isActive = true
        iconSelectedBackground.widthAnchor.constraint(equalTo: iconImage.widthAnchor, constant: 8).isActive = true
        iconSelectedBackground.heightAnchor.constraint(equalTo: iconImage.heightAnchor, constant: 8).isActive = true
        iconSelectedBackground.roundedCorners(radius: (icon.itemHeight + 8) / 2)
        self.contentView.sendSubviewToBack(iconSelectedBackground)
        iconSelectedBackground.isHidden = true
        
        if title != nil && title != "" {
            iconTitleLabel.font = MainFont.regular.with(fontSize: .small)
            iconTitleLabel.textColor = .white
            iconTitleLabel.textAlignment = .center
            self.contentView.addSubview(iconTitleLabel)
            iconTitleLabel.text = title
            iconTitleLabel.anchor(top: iconImage.bottomAnchor, bottom: self.contentView.bottomAnchor, leading: self.contentView.leadingAnchor, trailing: self.contentView.trailingAnchor)
        }
        
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
