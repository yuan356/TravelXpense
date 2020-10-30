//
//  AccountPickerTableViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/13.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let cellHeight: CGFloat = 60
fileprivate let cellHpadding: CGFloat = 15

class GenericInfoCell<U>: GenericCell<U> {
    override var item: U! {
        didSet {
            setViews()
        }
    }
    
    lazy var view = UIView {
        $0.heightAnchor.constraint(equalToConstant: cellHeight).usingPriority(.almostRequired).isActive = true
    }
    
    lazy var titleLabel = UILabel {
        $0.font = MainFont.regular.with(fontSize: 18)
    }
    
    lazy var amountLabel = UILabel {
        $0.textAlignment = .right
        $0.font = MainFontNumeral.medium.with(fontSize: .medium)
    }
    
    var iconImageName: String?
    
    var iconColorHex: String?
    
    lazy var iconImageView = UIView()
    
    func setViews() {
        self.backgroundColor = .clear
        // background view
        contentView.addSubview(view)
        view.fillSuperview()

        self.setIconImage()
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(amountLabel)
        
        iconImageView.setAutoresizingToFalse()
        iconImageView.anchorSuperViewLeading(padding: cellHpadding)
        iconImageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -cellHpadding).isActive = true
        iconImageView.anchorCenterY(to: view)
        
        titleLabel.setAutoresizingToFalse()
        titleLabel.anchorCenterY(to: view)
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -cellHpadding).isActive = true
        
        amountLabel.setAutoresizingToFalse()
        amountLabel.anchorCenterY(to: view)
        amountLabel.anchorSuperViewTrailing(padding: cellHpadding)
    }
    
    /**
        1. Need to set **iconImageName** & **iconColorHex**(optional)
        2. super.setIconImage()
    */
    func setIconImage() {
        if let imageName = self.iconImageName {
            let icon = IconView(imageName: imageName, colorHex: iconColorHex)
            iconImageView = icon
        }
    }
}
