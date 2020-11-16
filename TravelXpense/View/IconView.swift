//
//  CategoryIcon.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/7.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let heightForView: CGFloat = 45
fileprivate let iconPaddingInView: CGFloat = 8

class IconView: UIView {
    
    let itemHeight = heightForView
    
    let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        let height = heightForView - (iconPaddingInView * 2)
        iconImageView.anchorSize(h: height, w: 0)
        iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor).isActive = true
        return iconImageView
    }()
    
    init(imageName: String?, colorHex: String? = nil) {
        super.init(frame: CGRect.zero)
        setup(imageName: imageName, colorHex: colorHex)
    }
    
    convenience init() {
        self.init(imageName: nil, colorHex: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(imageName: String?, colorHex: String? = nil) {
        self.anchorSize()
        self.anchorSize(h: heightForView, w: 0)
        self.layer.cornerRadius = heightForView / 2
        self.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        self.addSubview(iconImageView)
        iconImageView.anchorToSuperViewCenter()
        iconImageView.tintColor = .black
        
        if let colorCode = colorHex {
            self.backgroundColor = UIColor(hex: colorCode)
        } else {
            self.backgroundColor  = TXColor.gray.light
        }
        
        if let imageName = imageName, imageName != "" {
            iconImageView.image = UIImage(named: imageName)
        }
    }
    
    func changeImage(imageName: String, colorHex: String? = nil) {
        if let colorCode = colorHex {
            self.backgroundColor = UIColor(hex: colorCode)
        } else {
            self.backgroundColor  = TXColor.gray.light
        }
        
        iconImageView.image = UIImage(named: imageName)
    }
}
