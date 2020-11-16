//
//  RecordDaysCollectionViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/8.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class RecordDaysCollectionViewCell: UICollectionViewCell {
    
    var startDate: Date!
    
    var dayIndex: Int! {
        didSet {
            dayLabel.text = "day \(dayIndex + 1)"
            if let date = TXFunc.getDateByOffset(startDate: startDate, daysInterval: dayIndex) {
                dateLabel.text = TXFunc.convertDateToDateStr(date: date)

            }
        }
    }

    lazy var dayLabel = UILabel {
        $0.textAlignment = .center
        $0.font = MainFontNumeral.medium.with(fontSize: 18)
        $0.textColor = .white
    }
    
    lazy var dateLabel = UILabel {
        $0.textAlignment = .center
        $0.font = MainFontNumeral.regular.with(fontSize: .small)
        $0.textColor = TXColor.gray.light
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing = 5
        vStack.addArrangedSubview(dayLabel)
        vStack.addArrangedSubview(dateLabel)
        
        self.addSubview(vStack)
        vStack.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
