//
//  RecordTableViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/30.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let cellHeight: CGFloat = 60
fileprivate let cellHpadding: CGFloat = 15
fileprivate let cellVpadding: CGFloat = 8

fileprivate let iconPaddingInView: CGFloat = 8

class RecordTableViewCell: UITableViewCell {

    var dayNo = 0
    
    let view: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        view.heightAnchor.constraint(equalToConstant: cellHeight).usingPriority(.almostRequired).isActive = true
        return view
    }()
    
    let iconView: UIView = {
        let itemHeight = cellHeight - (cellVpadding * 2)
        let view = UIView()
        view.backgroundColor = .yellow
        view.layer.cornerRadius = itemHeight / 2
        view.anchorSize(height: itemHeight, width: 0)
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return view
    }()
    
    let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "airplane-ticket")
        
        let iconViewHeight = cellHeight - (cellVpadding * 2)
        let iconImageViewHeight = iconViewHeight - (iconPaddingInView * 2)
        iconImageView.anchorSize(height: iconImageViewHeight, width: 0)
        iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor).isActive = true
        
        return iconImageView
    }()
    
    let infoStackView: UIStackView = {
        let itemHeight = cellHeight - (cellVpadding * 2)
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.anchorSize(height: itemHeight, width: 0)
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐午餐"
        label.font = label.font.withSize(18)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "吉野家"
        label.font = label.font.withSize(14)
        return label
    }()
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(22)
        label.text = "120.0"
        return label
    }()
    
    var record: Record? {
        didSet {
            self.setRecordInfo()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setConstraints()
        
    }
    
    func setRecordInfo() {
        guard let record = self.record else {
            return
        }
        
        // icon
        iconImageView.image = UIImage(named: record.category.iconImageName)
        
        // title
        titleLabel.text = record.title

        // detail
        descriptionLabel.text = record.description
        
        // amount
        amountLabel.text = Func.convertDoubleToStr(record.amount)
    }
    
    func setConstraints() {
        let views = ["iconView": iconView, "infoStackView": infoStackView, "amountLabel": amountLabel]
        let metrics = ["v": cellVpadding, "h": cellHpadding] // padding
        var constraints = [NSLayoutConstraint]()
        
        // background view
        contentView.addSubview(view)
        view.fillSuperview()
        
        // icon
        contentView.addSubview(iconView)
        iconView.setAutoresizingToFalse()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(h)-[iconView]", options: [], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(v)-[iconView]", options: [], metrics: metrics, views: views)
        
        iconView.addSubview(iconImageView)
        iconImageView.anchorToSuperViewCenter()
        
        // info
        contentView.addSubview(infoStackView)
        infoStackView.setAutoresizingToFalse()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[iconView]-(h)-[infoStackView]", options: [], metrics: metrics, views: views)
        infoStackView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(descriptionLabel)
        
        // amount
        contentView.addSubview(amountLabel)
        amountLabel.setAutoresizingToFalse()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[amountLabel]-(h)-|", options: [], metrics: metrics, views: views)
        amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: infoStackView.trailingAnchor, constant: cellHpadding).isActive = true
        amountLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
