//
//  RecordDetailTableViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/5.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum RecordDetailCellRow: Int {
    case amount = 0
    case title
    case category
    case account
    case date
    case note
    case LAST
    
    static func value(_ value: RecordDetailCellRow) -> Int {
        return value.rawValue
    }
}


//
//class RecordDetailCell {
//    
//    let tableCell: UITableViewCell = {
//        let cell = UITableViewCell()
//        return cell
//    }()
//    
//    let view = UIView()
//    
//    let rowNameLabel = UILabel()
//    
//    init() {
//        // view
//        tableCell.contentView.addSubview(view)
//        view.fillSuperview()
//        
//        // rowName
//        view.addSubview(rowNameLabel)
//        rowNameLabel.setAutoresizingToFalse()
//        let constraints = [
//            rowNameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            rowNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
//        ]
//        NSLayoutConstraint.activate(constraints)
//    }
//    
//    func createCell(type: RecordDetailCellRow) -> UITableViewCell {
//
//        switch type {
//        
//        case .amount:
//            rowNameLabel.text = "Amount"
//            let amountTextField = UITextField()
//            
//            break
//        case .title:
//            rowNameLabel.text = "Title"
//            break
//        case .category:
//            rowNameLabel.text = "Category"
//            break
//        case .note:
//            rowNameLabel.text = "Note"
//            break
//        case .LAST:
//            
//            break
//        case .account:
//            break
//        case .date:
//            break
//        }
//        return tableCell
//    }
//}
//
//class RecordTitleCell: UITableViewCell {
//
//    let view: UIView = {
//        let view = UIView()
//        view.heightAnchor.constraint(equalToConstant: detailCellHeight).usingPriority(.almostRequired).isActive = true
//        return view
//    }()
//    
//    let nameLabel = UILabel()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        self.contentView.addSubview(view)
//        
////        view.addSubview(label)
//        view.fillSuperview()
////        label.anchorToSuperViewCenter()
//        view.backgroundColor = .green
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//
