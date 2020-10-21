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

    let view: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: cellHeight).usingPriority(.almostRequired).isActive = true
        return view
    }()
    
    var account: Account? {
        didSet {
            setAccountInfo()
        }
    }
    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        return nameLabel
    }()
    
    let amountLabel: UILabel = {
        let amountLabel = UILabel()
        
        amountLabel.textAlignment = .right
        return amountLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setAutoLayout()
    }
    
    private func setAutoLayout() {
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
        nameLabel.text = "aAAAASDASDDFSFDSDF"
        amountLabel.text = TBFunc.convertDoubleToStr(acc.amount)
        amountLabel.text = "9999999999999"
    }

}
