//
//  bookTableViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/4.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let cellHeight: CGFloat = 180
fileprivate let textFont = MainFont.medium.with(fontSize: .medium)
fileprivate let textcolor: UIColor = .black

class BookTableViewCell: GenericCell<Book> {

    override var item: Book! {
        didSet {
            setBookInfo()
        }
    }
    
    lazy var backView = UIView {
        $0.roundedCorners()
        $0.backgroundColor = TBColor.gray.medium
        $0.heightAnchor.constraint(equalToConstant: cellHeight).usingPriority(.almostRequired).isActive = true
    }
    
    lazy var nameLabel = UILabel {
        $0.font = textFont
        $0.textColor = textcolor
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    lazy var converImageView = UIImageView {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.roundedCorners()
        $0.addSubview(blurEffectView)
        blurEffectView.fillSuperview()
    }
    
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.roundedCorners()
        blurEffectView.clipsToBounds = true
        blurEffectView.alpha = 0.5
        return blurEffectView
    }()
    
    lazy var dateLabel = UILabel {
        $0.font = MainFontNumeral.regular.with(fontSize: 18)
        $0.textColor = TBColor.gray.dark
        $0.textAlignment = .center
    }
    
    override func setupViews() {
        self.backgroundColor = .clear
        contentView.addSubview(backView)
        let cellPadding: CGFloat = 10
        backView.fillSuperview(padding: UIEdgeInsets(top: cellPadding, left: cellPadding, bottom: cellPadding, right: cellPadding))
        backView.addSubview(converImageView)
        converImageView.fillSuperview()
        
        setVStack()
    }
    
    private func setVStack() {
        let vStack = UIStackView()
        vStack.distribution = .fillEqually
        vStack.axis = .vertical
        
        vStack.addArrangedSubview(nameLabel)
        vStack.addArrangedSubview(dateLabel)
        
        backView.addSubview(vStack)
        vStack.anchor(top: backView.topAnchor, bottom: backView.bottomAnchor, leading: backView.leadingAnchor, trailing: backView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    private func setBookInfo() {
        guard let book = item else {
            return
        }
        
        nameLabel.text = book.name
        
        if book.imageUrl == "" { // get image from file system
            ImageService.retrieveFromLocal(bookId: book.id, imageView: self.converImageView)
        }
        
        let start = TBFunc.convertDateToDateStr(date: book.startDate)
        let end = TBFunc.convertDateToDateStr(date: book.endDate)
        dateLabel.text = start + " ~ " + end
    }
    
    override func prepareForReuse() {
        self.converImageView.image = UIImage()
    }

}
