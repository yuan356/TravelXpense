//
//  LocalePickerTableViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/23.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let cellHeight: CGFloat = 40

class LocalePickerTableViewCell: UITableViewCell {

    var country: Country! {
        didSet {
            contentLabel.text = country.name
        }
    }
    
    private lazy var view = UIView {
        $0.heightAnchor.constraint(equalToConstant: cellHeight).usingPriority(.almostRequired).isActive = true
    }
    
    private lazy var contentLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    private func setViews() {
        self.backgroundColor = .clear
        self.contentView.addSubview(view)
        view.fillSuperview()
        
        view.addSubview(contentLabel)
        contentLabel.fillSuperview(padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
