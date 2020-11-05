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
fileprivate let trashCanHeight: CGFloat = 26
fileprivate let iconPaddingInView: CGFloat = 8

fileprivate let cellColor = TBColor.system.blue.medium
fileprivate let cellHighlightedColor = TBColor.system.blue.light

class RecordTableViewCell: UITableViewCell {

    var record: Record? {
        didSet {
            setRecordInfo()
        }
    }
    
    lazy var backView = UIView {
        $0.backgroundColor = cellColor
        $0.heightAnchor.constraint(equalToConstant: cellHeight).usingPriority(.almostRequired).isActive = true
    }
    
    lazy var iconImageView = IconView(imageName: "")
    
    lazy var infoStackView = UIStackView {
        // 不需要設定高度，以stackView內Label為依據，自己長。
        $0.alignment = .leading
        $0.distribution = .fillEqually
        $0.axis = .vertical
    }
    
    lazy var titleLabel = UILabel {
        $0.textColor = .white
        $0.font = MainFont.regular.with(fontSize: 17)
    }
    
    lazy var noteLabel = UILabel {
        $0.textColor = TBColor.gray.light
        $0.font = MainFont.regular.with(fontSize:13)
    }
    
    lazy var amountLabel = UILabel {
        $0.textColor = .white
        $0.textAlignment = .right
        $0.font = MainFontNumeral.medium.with(fontSize: .medium)
    }
    
    lazy var deleteView = UIView()
    
    lazy var deleteBtn: UIButton = {
        let btn = TBNavigationIcon.trash.getButton()
        btn.anchorSize(h: trashCanHeight)
        btn.tintColor = TBColor.orange.light
        btn.addTarget(self, action: #selector(deleteButtonClicked), for: .touchUpInside)
        return btn
    }()
    
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
    
    var deleteViewWidthConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        setViews()
    }
    
    private func setViews() {
        // background view
        contentView.addSubview(backView)
        backView.fillSuperview()
        
        backView.addSubview(iconImageView)
        iconImageView.setAutoresizingToFalse()
        iconImageView.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true

        // info
        backView.addSubview(infoStackView)
        infoStackView.setAutoresizingToFalse()

        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true
        
        // amount
        backView.addSubview(amountLabel)
        amountLabel.setAutoresizingToFalse()
        
        // for Compression (amountLabel can fully show)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        noteLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        amountLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true
        
        // delete view
        deleteView.addSubview(deleteBtn)
        deleteBtn.fillSuperview()
        
        backView.addSubview(deleteView)
        deleteView.setAutoresizingToFalse()
        deleteView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true
        deleteViewWidthConstraint = deleteView.widthAnchor.constraint(equalToConstant: 0)
        deleteViewWidthConstraint.isActive = true
        
        var constraints = [NSLayoutConstraint]()
        
        let views = ["icon": iconImageView, "infoSV": infoStackView,"titile": titleLabel, "amount": amountLabel, "del": deleteView]
        let metrics = ["h": cellHpadding] // padding
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(h)-[icon]-(h)-[infoSV]-(>=h)-[amount]-(h)-[del]-|", options: [], metrics: metrics, views: views)
        
        NSLayoutConstraint.activate(constraints)
        
        // separator line
        lineView.backgroundColor = TBColor.gray.medium
        backView.addSubview(lineView)
        lineView.setAutoresizingToFalse()
        lineView.anchor(top: nil, bottom: backView.bottomAnchor, leading: infoStackView.leadingAnchor, trailing: amountLabel.trailingAnchor, size: CGSize(width: 0, height: 1))
    }
    
    func updateDeleteWidthContraint(reset: Bool = false) {
        deleteViewWidthConstraint.constant = reset ? 0 : trashCanHeight
        
        UIView.animate(withDuration: 0.25) {
            self.contentView.layoutIfNeeded()
        }
        
    }
    
    // MARK: setRecordInfo
    private func setRecordInfo() {
        guard let record = self.record else {
            return
        }
        
        // category
        category = record.category
        
        guard let category = self.category else {
            return
        }
        
        iconImageView.changeImage(imageName: category.iconImageName, colorHex: category.colorHex)
        
        backView.addSubview(iconImageView)
        iconImageView.setAutoresizingToFalse()
        iconImageView.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        
        // title
        titleLabel.text = (record.title == "") ? record.category.title : record.title
        
        // detail
        if record.note != "" {
            infoStackView.addArrangedSubview(noteLabel)
        } else {
            infoStackView.removeArrangedSubview(noteLabel)
        }
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
    
    @IBAction func deleteButtonClicked() {
        TBNotify.showCenterAlert(message: "Are you sure you want to delete this record?", confirm: true) {
            if let rd = self.record {
                RecordSevice.shared.deleteRecordById(recordId: rd.id)
                TBObserved.notifyObservers(notificationName: .recordTableUpdate, infoKey: nil, infoValue: nil)
                TBNotify.dismiss()
            }
        }
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
