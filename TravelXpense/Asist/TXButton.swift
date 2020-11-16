//
//  TXButton.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/14.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class TXButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.font = MainFont.regular.with(fontSize: .medium)
        self.setTitleColor(TXColor.gray.medium, for: .highlighted)
        self.setTitleColor(.white, for: .normal)
    }
    
    func setFontSize(size: CGFloat) {
        self.titleLabel?.font = MainFont.regular.with(fontSize: size)
    }
    
    func setFont(font: UIFont) {
        self.titleLabel?.font = font
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
