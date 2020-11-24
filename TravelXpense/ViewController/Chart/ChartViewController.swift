//
//  ChartViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/28.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {

    var book: Book!
    
    var pieChart = TBPieChartView()
    
    var currentAccount: Account? {
        didSet {
            accountButton.setTitle(" \(currentAccount!.name) ", for: .normal)
        }
    }

    var amountData: [CategoryAmount] = []
    
    var totalAmount: Double = 0.0 {
        didSet {
            totalAmountLabel.text = TXFunc.convertDoubleToStr(totalAmount, currencyCode: book.currency.code, ISOcode: true)
            let localAmount = RateService.shared.exchangeToMyCurrency(from: book.currency.code, amount: totalAmount)
            
            localAmountLabel.text = TXFunc.convertDoubleToStr(localAmount, currencyCode: RateService.shared.myCurrency?.code, ISOcode: true)
        }
    }
    
    lazy var localAmountLabel = UILabel {
        $0.font = MainFontNumeral.medium.with(fontSize: 20)
        $0.textColor = TXColor.gray.medium
        $0.textAlignment = .right
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.6
    }
    
    lazy var totalAmountLabel = UILabel {
        $0.font = MainFontNumeral.medium.with(fontSize: 20)
        $0.textColor = .white
        $0.textAlignment = .right
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.6
    }
    
    lazy var controlBarView = UIView()
    
    lazy var accountButton = UIButton {
        $0.roundedCorners()
        $0.backgroundColor = TXColor.system.blue.medium
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        $0.setTitleColor(TXColor.gray.medium, for: .highlighted)
        $0.addTarget(self, action: #selector(accountBtnClicked), for: .touchUpInside)
    }
    
    lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.register(AmountDataCell.self, forCellReuseIdentifier: String(describing: AmountDataCell.self))
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        
        setControlBarView() 
        setViews()
        
        currentAccount = AccountService.shared.getDefaultAccount(bookId: book.id)
        
        if let acc = currentAccount {
            getChartData(accountId: acc.id)
        }
    }
    
    private func setControlBarView() {
        self.view.addSubview(controlBarView)
        controlBarView.anchorViewOnTop()
        controlBarView.addSubview(accountButton)
        accountButton.anchorSuperViewTop(padding: 8)
        accountButton.anchorCenterX(to: controlBarView)        
    }
    
    private func setViews() {
        self.view.addSubview(pieChart)
        pieChart.anchor(top: controlBarView.bottomAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        pieChart.anchorSize(h: UIScreen.main.bounds.height / 3)
        
        var amountLabelTopAnchor: NSLayoutYAxisAnchor!
        if let myCurrency = RateService.shared.myCurrency,
           myCurrency.code != book.currency.code {
            self.view.addSubview(localAmountLabel)
            localAmountLabel.anchor(top: pieChart.bottomAnchor, bottom: nil, leading: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25))
            amountLabelTopAnchor = localAmountLabel.bottomAnchor
        } else {
            amountLabelTopAnchor = pieChart.bottomAnchor
        }
        
        self.view.addSubview(totalAmountLabel)
        totalAmountLabel.anchor(top: amountLabelTopAnchor, bottom: nil, leading: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 25))
        
        let rankingLabel = UILabel {
            $0.text = NSLocalizedString("Ranking", comment: "Ranking")
            $0.font = MainFont.bold.with(fontSize: .medium)
            $0.textColor = .white
            $0.anchorSize(w: 70)
        }
        
        self.view.addSubview(rankingLabel)
        rankingLabel.anchor(top: nil, bottom: nil, leading: view.leadingAnchor, trailing: nil, padding: UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 10))
        
        rankingLabel.trailingAnchor.constraint(lessThanOrEqualTo: totalAmountLabel.leadingAnchor, constant: -15).isActive = true
        rankingLabel.anchorCenterY(to: totalAmountLabel)
        
        let lineView = UIView {
            $0.backgroundColor = TXColor.system.veronese
            $0.anchorSize(h: 3)
        }
        self.view.addSubview(lineView)
        lineView.anchor(top: totalAmountLabel.bottomAnchor, bottom: nil, leading: totalAmountLabel.leadingAnchor, trailing: totalAmountLabel.trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
        
        self.view.addSubview(tableView)
        tableView.anchor(top: lineView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 10, bottom: 10, right: 10))
    }
    
    private func getChartData(accountId: Int) {
        let result = RecordSevice.shared.orderByAmount(accountId: accountId)
        self.amountData = result.0
        self.totalAmount = result.1
        
        pieChart.setData(datalist: amountData)
        pieChart.changeCenterText(text: NSLocalizedString("Expense", comment: "Expense"))
    }
    
    @IBAction func accountBtnClicked() {
        TXAlert.showPicker(type: .account, currentObject: currentAccount, allAccount: true) { (result, acc) in
            if result == .success, let acc = acc as? Account {
                self.currentAccount = acc
                self.getChartData(accountId: acc.id)
                self.tableView.reloadData()
            }
        }
    }
}

extension ChartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.amountData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AmountDataCell.self), for: indexPath) as? AmountDataCell {
            cell.item = amountData[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

class AmountDataCell: GenericInfoCell<CategoryAmount> {
    override var item: CategoryAmount! {
        didSet {
            titleLabel.text = item.category.title
            titleLabel.textColor = .white
            amountLabel.textColor = .white
            if let book = BookService.shared.currentOpenBook {
                amountLabel.text = TXFunc.convertDoubleToStr(item.amount, moneyFormat: true, currencyCode: book.currency.code)
            }
            addSeparatorLine()
        }
    }
    
    func addSeparatorLine() {
        // separator line
        let lineView = UIView()
        lineView.backgroundColor = TXColor.gray.medium
        self.view.addSubview(lineView)
        lineView.anchor(top: nil, bottom: view.bottomAnchor, leading: titleLabel.leadingAnchor, trailing: amountLabel.trailingAnchor, size: CGSize(width: 0, height: 1))
    }
    
    override func setIconImage() {
        iconImageName = item.category.iconImageName
        iconColorHex = item.category.colorHex
        super.setIconImage()
    }
}
