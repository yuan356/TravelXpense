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
    
//    var category: Category? = nil
    
//    var iconImageName: String?
    
    let itemHeight = heightForView
    
//    var iconColorCode: String?
    
    init(imageName: String?, colorHex: String? = nil) {
        super.init(frame: CGRect.zero)
//        self.iconImageName = imageName
//        iconColorCode = colorHex
        
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
            self.backgroundColor  = TBColor.lightGary
        }
        
        if let imageName = imageName, imageName != "" {
            iconImageView.image = UIImage(named: imageName)
        }
    }
    
    func changeImage(imageName: String) {
        print("changeImage")
        iconImageView.image = UIImage(named: imageName)
    }
    
//    let backView: UIView = {
//        let itemHeight = heightForView
//        let view = UIView()
//        view.layer.cornerRadius = itemHeight / 2
//        view.anchorSize(h: itemHeight, w: 0)
//        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
//        return view
//    }()
    
    let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        let height = heightForView - (iconPaddingInView * 2)
        iconImageView.anchorSize(h: height, w: 0)
        iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor).isActive = true
        
        return iconImageView
    }()
    
    
    /// return Icon ImageView(size: 45)
    /// - Returns: UIView
//    func geticonImageView() -> UIView {
//        backView.addSubview(iconImageView)
//        iconImageView.anchorToSuperViewCenter()
//        iconImageView.tintColor = .black
//
//        if let iconImageName = self.iconImageName, iconImageName != "" {
//            if let colorCode = iconColorCode {
//                backView.backgroundColor = UIColor(hex: colorCode)
//            }
//            else {
//                backView.backgroundColor  = TBColor.lightGary
//            }
//            iconImageView.image = UIImage(named: iconImageName)
//        }
//        return backView
//    }
    
    
}
