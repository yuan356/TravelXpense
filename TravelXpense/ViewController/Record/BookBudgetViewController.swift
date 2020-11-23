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
            budgetStr = TXFunc.convertDoubleToStr(budget, currencyCode: book.currency.code)
        }
    }
    
    var currentAccount: Account?
    
    var balance: Double = 0.0 {
        didSet {
            balanceStr = TXFunc.convertDoubleToStr(balance, currencyCode: book.currency.code)
        }
    }
    
    var budgetStr: String = ""
    var balanceStr: String = ""
    
    lazy var balanceLabel = UILabel()
    
    lazy var budgetLabel = UILabel {
        $0.textColor = .white
        $0.textAlignment = .right
        $0.font = MainFontNumeral.medium.with(fontSize: 28)
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    lazy var progressView = ProgressBarView()

    var observer = TXObserver(notification: .accountAmountUpdate, infoKey: .accountAmount)
    
    override func viewDidLoad() {
        setView()
        
        let amount = AccountService.shared.getTotalAmount()
        budget = AccountService.shared.getTotalBudget()
        balance = budget + amount
        updateBalance()
        
        
        observer.delegate = self
    }
    
   
    private func updateBalance() {
        budgetLabel.fadeTransition(0.45)
        budgetLabel.text = balanceStr + "/" + budgetStr
        
        guard budget > 0 else {
            progressView.progress = CGFloat(0)
            return
        }
        
        if balance <= budget {
            let ratio = balance / budget
            progressView.progress = CGFloat(ratio)
        } else { // balance > budget
            progressView.progress = CGFloat(1)
        }
    }

    private func setView() {
        self.view.addSubview(budgetLabel)
        budgetLabel.anchor(top: self.view.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 20, bottom: 0, right: 20))
        
        self.view.addSubview(progressView)
        progressView.backgroundColor = TXColor.gray.light
        progressView.anchor(top: budgetLabel.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 15, right: 20))
    }
}

extension BookBudgetViewController: ObserverProtocol {
    func handleNotification(infoValue: Any?) {
        let amount = AccountService.shared.getTotalAmount()
        balance = budget + amount
        updateBalance()
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
