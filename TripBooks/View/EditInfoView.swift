//
//  EditInfoView.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/29.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let paddingInVStack: CGFloat = 10
fileprivate let titleTextFont: UIFont = MainFont.regular.with(fontSize: 18)


class EditInfoView: UIView {
    
    init(viewheight: CGFloat, title: String, object: UIView, withButton button: UIButton? = nil, anchorBottom: Bool = false) {
        super.init(frame: CGRect.zero)
        setView(viewheight: viewheight, title: title, object: object, button: button, anchorBottom: anchorBottom)
    }
    
    func setView(viewheight: CGFloat, title: String, object: UIView, button: UIButton?, anchorBottom: Bool) {
        self.anchorSize(h: viewheight)
        
        let titleLabel = UILabel {
            $0.text = title
            $0.font = titleTextFont
            $0.anchorSize(w: 100)
            $0.textColor = .white
        }
        
        self.addSubview(titleLabel)
        titleLabel.anchorSuperViewLeading(padding: paddingInVStack)
        
        self.addSubview(object)
        if !(object is UISwitch) {
            object.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        }
        
        object.anchorSuperViewTrailing(padding: paddingInVStack)
        
        if anchorBottom {
            object.anchorSuperViewBottom()
            titleLabel.anchorSuperViewBottom()
        } else {
            object.anchorCenterY(to: self)
            titleLabel.anchorCenterY(to: self)
        }
        
        if let btn = button {
            self.addSubview(btn)
            btn.anchorSize(to: object)
            btn.anchorCenterX(to: object)
            btn.anchorCenterY(to: object)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
