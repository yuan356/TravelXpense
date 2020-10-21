//
//  BookSettingViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate enum SettingCellRow {
    case name
    case locale
    case date
    case amount
}

// Padding
fileprivate let paddingInContentView: CGFloat = 10
fileprivate let spacingInVStack: CGFloat = 8
fileprivate let heightForStackItem: CGFloat = 60

class BookSettingViewController: UIViewController {

    var book: Book! {
        didSet {
            label.text = "\(book.id)"
        }
    }
    
    // views
    var imageView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55).isActive = true
        return view
    }()
    
    let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = spacingInVStack
        stackView.axis = .vertical
//        stackView.anchorSize(height: (heightForDetailView * 2) + spacingInVStack)
        return stackView
    }()
    
    var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setConstraints()
    }
    
    
    private func setConstraints() {
        
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor)

        setVStackView()
        
    }
    
    // MARK: vStackView
    /// add vStackView to contentView & setting
    private func setVStackView() {
        view.addSubview(vStackView)
        vStackView.anchor(top: imageView.bottomAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: paddingInContentView, right: paddingInContentView))

        let nameView = UIView()
        nameView.backgroundColor = .blue
        nameView.anchorSize(height: heightForStackItem)
        setDetailView(name: "Book name", to: nameView, type: .name)

        let localeView = UIView()
        localeView.backgroundColor = .blue
        localeView.anchorSize(height: heightForStackItem)
        setDetailView(name: "Locale", to: localeView, type: .locale)
        
        let dateView = UIView()
//        setDetailView(name: "Date", to: dateView, type: .date)
        dateView.backgroundColor = .blue
        dateView.anchorSize(height: heightForStackItem)
//        let hStackView = UIStackView()
//        hStackView.axis = .horizontal
//        hStackView.distribution = .fillEqually
//        hStackView.alignment = .fill
//        hStackView.spacing = paddingInContentView
//        hStackView.addArrangedSubview(dateView)
//        hStackView.addArrangedSubview(accountView)
//        hStackView.anchorSize(height: heightForDetailView)
//
        vStackView.addArrangedSubview(nameView)
        vStackView.addArrangedSubview(localeView)
        vStackView.addArrangedSubview(dateView)
    }
    
    private func setDetailView(name: String, to view: UIView, type: SettingCellRow) {
        
        switch type {
        case .name: break
        case .locale: break
        case .date: break
        case .amount: break
        }
        
    }
    /*
    // MARK: setDetailView
    /// 各 detail 的細節設定(加入lineView)
    private func setDetailView(name: String, to view: UIView, type: RecordDetailCellRow) {
        
        let lineView = UIView()
        lineView.backgroundColor = .white
        lineView.anchorSize(height: 1)
        
        view.addSubview(lineView)
        let linePd: CGFloat = 10
        lineView.anchor(top: nil, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: linePd, bottom: 0, right: linePd))
        
        let pdInDetail: CGFloat = 15
        switch type {
        case .amount:
            break
        case .title:
            view.addSubview(titleTextField)
            titleTextField.delegate = self
            titleTextField.anchor(top: view.topAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: pdInDetail, bottom: 0, right: pdInDetail))
        case .account:
            view.addSubview(accountLabel)
            accountLabel.fillSuperview()
            view.addSubview(accountPickButton)
            accountPickButton.anchorToSuperViewCenter()
            accountPickButton.anchorSize(to: accountLabel)
            break
        case .note:
            noteTextView.delegate = self
            if record?.note != "" {
                noteTextView.textColor = .white
            } else {
                noteTextView.textColor = textViewPlaceholderColor
            }
                
            currentTextView = noteTextView
            break
        case .date:
            view.addSubview(dateLabel)
            dateLabel.fillSuperview()
            view.addSubview(datePickButton)
            datePickButton.anchorToSuperViewCenter()
            datePickButton.anchorSize(to: dateLabel)
            break
        }
    }
    */
}
