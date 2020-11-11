//
//  UITableView+emptyView.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/3.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

extension UITableView {
    func setEmptyMessage(_ message: String, isForBookTable: Bool = false) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let msgLabel = UILabel {
            $0.text = message
            $0.font = MainFontNumeral.medium.with(fontSize: .medium)
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.textColor = TBColor.gray.light
        }
        
        let downArrowView = UIImageView {
            $0.image = UIImage(named: TBNavigationIcon.downArrow.rawValue)
            $0.anchorSize(h: 55, w: 55)
            $0.tintColor = TBColor.gray.light
        }
        
        emptyView.addSubview(msgLabel)
        emptyView.addSubview(downArrowView)
        msgLabel.setAutoresizingToFalse()
        downArrowView.setAutoresizingToFalse()
        downArrowView.anchorCenterX(to: emptyView)
        
        if isForBookTable {
            msgLabel.anchorToSuperViewCenter()
            downArrowView.topAnchor.constraint(equalTo: msgLabel.bottomAnchor, constant: 50).isActive = true
            
        } else {
            msgLabel.anchorCenterX(to: emptyView)
            msgLabel.anchor(top: nil, bottom: downArrowView.topAnchor, leading: emptyView.leadingAnchor, trailing: emptyView.trailingAnchor)
            downArrowView.anchorSuperViewBottom(padding: 30)
        }
        
        
        emptyView.backgroundColor = .clear
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}
