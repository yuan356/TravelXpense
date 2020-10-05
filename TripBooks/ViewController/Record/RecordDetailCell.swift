//
//  RecordDetailTableViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/5.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum RecordDetailCellRow: Int {
    case title = 0
    case amount
    case category
    case description
    case LAST
    
    static func value(_ value: RecordDetailCellRow) -> Int {
        return value.rawValue
    }
}

let detailCellHeight: CGFloat = 60

class RecordDetailCell {
    
    static func createCell(type: RecordDetailCellRow) -> UITableViewCell {
        let tableCell = UITableViewCell()
        //tableCell.rowType = type
        
        
//        switch type {
//        case .title:
//            tableCell = RecordTitleCell()
//            break
//        case .amount:
//            break
//        case .category:
//            break
//        case .description:
//            break
//        case .LAST:
//            break
//        }

        return tableCell
    }
}

class RecordTitleCell: UITableViewCell {

    let view: UIView = {
        let view = UIView()
//        view.heightAnchor.constraint(equalToConstant: detailCellHeight).usingPriority(.almostRequired).isActive = true
        return view
    }()
    
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        self.contentView.addSubview(view)
        
//        view.addSubview(label)
//        view.fillSuperview()
        label.anchorToSuperViewCenter()
        view.backgroundColor = .green
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


