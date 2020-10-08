//
//  RecordDaysCollectionViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/8.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class RecordDaysCollectionViewCell: UICollectionViewCell {
    
    var dayNo = 0 {
        didSet {
            indexLabel.text = "day \(dayNo)"
        }
    }
    
    let indexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(indexLabel)
        indexLabel.anchorToSuperViewCenter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
