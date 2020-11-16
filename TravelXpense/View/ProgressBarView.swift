//
//  ProgressBarView.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/28.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class ProgressBarView: UIView {
        
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let progressLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let backgroundMask = CAShapeLayer()
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.25).cgPath
        layer.mask = backgroundMask
        
        let progressRect = CGRect(origin: CGPoint(x: rect.width, y: 0), size: CGSize(width: rect.width * -progress, height: rect.height))
        progressLayer.frame = progressRect
        progressLayer.backgroundColor = TXColor.system.veronese.cgColor
    }
}
