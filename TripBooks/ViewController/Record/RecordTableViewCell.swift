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

fileprivate let iconPaddingInView: CGFloat = 8

fileprivate let cellColor = TBColor.darkGary
fileprivate let cellHighlightedColor = TBColor.lightGary

class RecordTableViewCell: UITableViewCell {

    var record: Record? {
        didSet {
            setRecordInfo()
            setViews()
        }
    }
    
    lazy var backView = UIView {
        $0.backgroundColor = cellColor
        $0.heightAnchor.constraint(equalToConstant: cellHeight).usingPriority(.almostRequired).isActive = true
    }
    
    lazy var infoStackView = UIStackView {
        // 不需要設定高度，以stackView內Label為依據，自己長。
        $0.alignment = .leading
        $0.distribution = .fillEqually
        $0.axis = .vertical
    }
    
    lazy var titleLabel = UILabel {
        $0.font = MainFont.regular.with(fontSize: 17)
    }
    
    lazy var noteLabel = UILabel {
        $0.font = MainFont.regular.with(fontSize: 11)
    }
    
    lazy var amountLabel = UILabel {
        $0.textColor = .white
        $0.textAlignment = .right
        $0.font = MainFontNumeral.medium.with(fontSize: .medium)
    }
    
    let lineView = UIView()
    
    var category: Category?
    
    var rounded = false {
        didSet {
            if rounded {
                self.backView.roundedCorners(radius: 18, roundedType: roundedType)
            } else {
                self.backView.roundedCorners(radius: 0)
            }
        }
    }
    
    var roundedType: RoundedType?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        backView.roundedCorners(radius: 0)
    }
    
    private func setViews() {
        // background view
        contentView.addSubview(backView)
        backView.fillSuperview()
        
        guard let category = self.category else {
            return
        }
        
        let icon = IconView(imageName: category.iconImageName, colorHex: category.colorHex)
        let iconImageView = icon
        backView.addSubview(iconImageView)
        iconImageView.setAutoresizingToFalse()
        iconImageView.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true

        // info
        backView.addSubview(infoStackView)
        infoStackView.setAutoresizingToFalse()

        infoStackView.addArrangedSubview(titleLabel)
        if noteLabel.text != "" {
            infoStackView.addArrangedSubview(noteLabel)
        } else {
            infoStackView.removeArrangedSubview(noteLabel)
        }

        infoStackView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true
        
        // amount
        backView.addSubview(amountLabel)
        amountLabel.setAutoresizingToFalse()
        
        // for Compression (amountLabel can fully show)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        noteLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        amountLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true
        
        var constraints = [NSLayoutConstraint]()
        
        let views = ["icon": iconImageView, "infoSV": infoStackView,"titile": titleLabel, "amount": amountLabel]
        let metrics = ["h": cellHpadding] // padding
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(h)-[icon]-(h)-[infoSV]-(>=h)-[amount]-(h)-|", options: [], metrics: metrics, views: views)
        
        NSLayoutConstraint.activate(constraints)
        
        // separator line
        lineView.backgroundColor = .lightGray
        backView.addSubview(lineView)
        lineView.setAutoresizingToFalse()
        lineView.anchor(top: nil, bottom: backView.bottomAnchor, leading: infoStackView.leadingAnchor, trailing: amountLabel.trailingAnchor, size: CGSize(width: 0, height: 1))
    }
    
    private func setRecordInfo() {
        guard let record = self.record else {
            return
        }
        
        // category
        category = record.category
        
        // title
        titleLabel.text = (record.title == "") ? record.category.title : record.title
        
        // detail
        noteLabel.text = record.note
        
        // amount
        var amountText: String = ""
        if let book = BookService.shared.getBookFromCache(bookId: record.bookId) {
            amountText = TBFunc.convertDoubleToStr(record.amount, moneyFormat: true, currencyCode: book.currency.code)
        } else {
            amountText = TBFunc.convertDoubleToStr(record.amount, moneyFormat: true)
        }
        amountLabel.text = amountText
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backView.backgroundColor = cellHighlightedColor
        } else {
            self.backView.backgroundColor = cellColor
        }
    }
}
