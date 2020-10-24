//
//  AccountPickerTableViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/13.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let cellHeight: CGFloat = 60

class AccountPickerTableViewCell: UITableViewCell {

    lazy var view = UIView {
        $0.heightAnchor.constraint(equalToConstant: cellHeight).usingPriority(.almostRequired).isActive = true
    }
    
    var account: Account? {
        didSet {
            setAccountInfo()
        }
    }
    
    lazy var nameLabel = UILabel()
    
    lazy var amountLabel = UILabel {
        $0.textAlignment = .right
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    private func setViews() {
        self.backgroundColor = .clear
        // background view
        contentView.addSubview(view)
        view.fillSuperview()

        view.addSubview(nameLabel)
        view.addSubview(amountLabel)
        
        nameLabel.setAutoresizingToFalse()
        nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -15).isActive = true
        
        amountLabel.setAutoresizingToFalse()
        amountLabel.anchorSuperViewTrailing(padding: 15)
        amountLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAccountInfo() {
        guard let acc = self.account else {
            return
        }
        
        let icon = IconView(iconImageName: acc.iconImageName)
        let iconImage = icon.geticonImageView()
        
        view.addSubview(iconImage)
        iconImage.setAutoresizingToFalse()
        iconImage.anchorSuperViewLeading(padding: 15)
        iconImage.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -10).isActive = true

        iconImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        nameLabel.text = acc.name
        amountLabel.text = TBFunc.convertDoubleToStr(acc.amount)
    }
}
