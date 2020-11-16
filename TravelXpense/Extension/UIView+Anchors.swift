//
//  UIView+anchors.swift
//  EasyAnchorsLBTA
//
//  Created by Brian Voong on 1/30/18.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit

let heightForHeader: CGFloat = 50

fileprivate let heightForHeaderButton: CGFloat = 25

enum HeaderButtonPosition {
    case right
    case left
}

enum RoundedType {
    case all
    case top
    case bottom
}

extension UIView {
    
    func fillSuperview(padding: UIEdgeInsets) {
        anchor(top: superview?.topAnchor, bottom: superview?.bottomAnchor, leading: superview?.leadingAnchor,  trailing: superview?.trailingAnchor, padding: padding)
    }
    
    func fillSuperview() {
        fillSuperview(padding: .zero)
    }
    
    func anchorSize(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    /// for headerView, default height = 50
    func anchorViewOnTop(height: CGFloat = heightForHeader) {
        anchor(top: superview?.topAnchor, bottom: nil, leading: superview?.leadingAnchor, trailing: superview?.trailingAnchor)
        
        if height != 0 {
            anchorSize(h: height)
        }
    }
    
    /// for bottomView , default height = 50
    func anchorViewOnBottom(height: CGFloat = 50) {
        anchor(top: nil, bottom: superview?.bottomAnchor, leading: superview?.leadingAnchor, trailing: superview?.trailingAnchor)
        
        if height != 0 {
            anchorSize(h: height)
        }
    }
    
    func anchorSize(h: CGFloat = 0, w: CGFloat = 0) {
        if h != 0 {
            heightAnchor.constraint(equalToConstant: h).isActive = true
        }
        
        if w != 0 {
            widthAnchor.constraint(equalToConstant: w).isActive = true
        }
    }
    
    func anchorToSuperViewCenter() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        }
    }
    
    func anchorCenterY(to view: UIView) {
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func anchorCenterX(to view: UIView) {
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func anchorTopTo(to view: UIView, padding: CGFloat = 0) {
        anchor(top: view.bottomAnchor, bottom: nil, leading: nil, trailing: nil, padding: UIEdgeInsets(top: padding, left: 0, bottom: 0, right: 0))
    }
    
    /// default padding = 15,  height = 25, multiplier = 1
    func anchorButtonToHeader(position: HeaderButtonPosition, padding: CGFloat = 15, height: CGFloat = heightForHeaderButton, multiplier: CGFloat = 1) {
        var leading: NSLayoutXAxisAnchor? = nil
        var trailing: NSLayoutXAxisAnchor? = nil
        switch position {
        case .left:
            leading = self.superview?.leadingAnchor
        case .right:
            trailing = self.superview?.trailingAnchor
        }
        
        anchor(top: self.superview?.topAnchor, bottom: nil, leading: leading, trailing: trailing, padding: UIEdgeInsets(top: padding, left: padding, bottom: 0, right: padding))
        anchorSize(h: height)
        self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: multiplier).isActive = true
    }
    
    func anchorSuperViewTop(padding: CGFloat = 0) {
        anchor(top: superview?.topAnchor, bottom: nil, leading: nil,  trailing: nil, padding: UIEdgeInsets(top: padding, left: 0, bottom: 0, right: 0))
    }
    
    func anchorSuperViewBottom(padding: CGFloat = 0) {
        anchor(top: nil, bottom: self.superview?.bottomAnchor, leading: nil,  trailing: nil, padding: UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0))
    }
    
    func anchorSuperViewLeading(padding: CGFloat = 0) {
        anchor(top: nil, bottom: nil, leading: self.superview?.leadingAnchor,  trailing: nil, padding: UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0))
    }
    
    func anchorSuperViewTrailing(padding: CGFloat = 0) {
        anchor(top: nil, bottom: nil, leading: nil,  trailing: self.superview?.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: padding))
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?,  trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func setAutoresizingToFalse() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// default radius = 10
    func roundedCorners(radius: CGFloat = 10, shadow: Bool = false, roundedType: RoundedType? = nil) {
        self.layer.cornerRadius = radius
        
        if shadow {
            self.getShadow()
        }
        
        if let roundedType = roundedType {
            switch roundedType {
            case .top:
                self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .bottom:
                self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .all:
                self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
    }
    
    private func getShadow() {
        self.layer.shadowOffset = CGSize(width: 2, height: 2) // 表示layer的陰影顯示在box.layer右側及下方的距離
        self.layer.shadowOpacity = 0.7 // layer shadow的透明度
        self.layer.shadowRadius = 7 // 數值越高則陰影越模糊且分散，數值越低則會較清晰且集中
        self.layer.shadowColor = UIColor.black.cgColor
    }
}

extension NSLayoutConstraint {
    
    /// Returns the constraint sender with the passed priority.
    ///
    /// - Parameter priority: The priority to be set.
    /// - Returns: The sended constraint adjusted with the new priority.
    func usingPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
}

extension UILayoutPriority {
    
    /// Creates a priority which is almost required, but not 100%.
    static var almostRequired: UILayoutPriority {
        return UILayoutPriority(rawValue: 999)
    }
    
}
