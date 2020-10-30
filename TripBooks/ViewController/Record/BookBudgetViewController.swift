//
//  BookInfoView.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/28.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class BookBudgetViewController: UIViewController {
    
    var book: Book!
    
    var budget: Double = 0.0 {
        didSet {
            budgetStr = TBFunc.convertDoubleToStr(budget)
        }
    }
    
    var currentAccount: Account?
    
    var balance: Double = 0.0 {
        didSet {
            amountStr = TBFunc.convertDoubleToStr(balance)
        }
    }
    
    var budgetStr: String = ""
    var amountStr: String = ""
    
    
    lazy var budgetLabel = UILabel {
        $0.textAlignment = .right
        $0.font = MainFontNumeral.medium.with(fontSize: 35)
    }
    
    lazy var progressView = ProgressBarView()

    override func viewDidLoad() {
        self.view.backgroundColor = .lightGray
        setView()

        currentAccount = AccountService.shared.getDefaultAccount(bookId: book.id)
        if let acc = currentAccount {
            budget = acc.budget
            let totalAmount = RecordSevice.shared.getTotalAmount(accountId: acc.id)
            balance = budget + totalAmount
            updateNumbers()
        }
        
        
    }
    
    private func updateNumbers() {
        budgetLabel.text = amountStr + "/" + budgetStr
    }
    
    private func setView() {
        self.view.addSubview(budgetLabel)
        budgetLabel.anchor(top: self.view.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 20, bottom: 0, right: 20))
        
        self.view.addSubview(progressView)
        progressView.progressColor = UIColor(hex: "CCE2FF")
        progressView.backgroundColor = .darkGray
        progressView.anchor(top: budgetLabel.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 15, right: 20))
    }

}
