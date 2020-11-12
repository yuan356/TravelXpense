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
            totalAmountLabel.text = TBFunc.convertDoubleToStr(totalAmount, moneyFormat: true, currencyCode: book.currency.code)
        }
    }
    
    lazy var totalAmountLabel = UILabel {
        $0.font = MainFontNumeral.medium.with(fontSize: .medium)
        $0.textColor = .white
        $0.textAlignment = .right
        $0.adjustsFontSizeToFitWidth = true
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    
    lazy var controlBarView = UIView()
    
    lazy var accountButton = UIButton {
        $0.roundedCorners()
        $0.backgroundColor = TBColor.system.blue.medium
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        $0.setTitleColor(TBColor.gray.medium, for: .highlighted)
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
        
        let rankingLabel = UILabel {
            $0.text = NSLocalizedString("Ranking", comment: "Ranking")
            $0.font = MainFont.bold.with(fontSize: .medium)
            $0.textColor = .white
            $0.anchorSize(w: 80)
        }
        
        self.view.addSubview(rankingLabel)
        rankingLabel.anchor(top: pieChart.bottomAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: nil, padding: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0))
        
        self.view.addSubview(totalAmountLabel)
        totalAmountLabel.setAutoresizingToFalse()
        totalAmountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: rankingLabel.trailingAnchor, constant: 15).isActive = true
        totalAmountLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        totalAmountLabel.anchorCenterY(to: rankingLabel)
        
        let lineView = UIView {
            $0.backgroundColor = TBColor.system.veronese
            $0.anchorSize(h: 3)
        }
        self.view.addSubview(lineView)
        lineView.anchor(top: totalAmountLabel.bottomAnchor, bottom: nil, leading: totalAmountLabel.leadingAnchor, trailing: totalAmountLabel.trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
        
        self.view.addSubview(tableView)
        tableView.anchor(top: rankingLabel.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 20, bottom: 10, right: 20))
    }
    
    private func getChartData(accountId: Int) {
        let result = RecordSevice.shared.orderByAmount(accountId: accountId)
        self.amountData = result.0
        self.totalAmount = result.1
        
        pieChart.setData(datalist: amountData)
        pieChart.changeCenterText(text: NSLocalizedString("Expense", comment: "Expense"))
    }
    
    @IBAction func accountBtnClicked() {
        TBNotify.showPicker(type: .account, currentObject: currentAccount, allAccount: true) { (result, acc) in
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
                amountLabel.text = TBFunc.convertDoubleToStr(item.amount, moneyFormat: true, currencyCode: book.currency.code)
            }
            addSeparatorLine()
        }
    }
    
    func addSeparatorLine() {
        // separator line
        let lineView = UIView()
        lineView.backgroundColor = TBColor.gray.medium
        self.view.addSubview(lineView)
        lineView.anchor(top: nil, bottom: view.bottomAnchor, leading: titleLabel.leadingAnchor, trailing: amountLabel.trailingAnchor, size: CGSize(width: 0, height: 1))
    }
    
    override func setIconImage() {
        iconImageName = item.category.iconImageName
        iconColorHex = item.category.colorHex
        super.setIconImage()
    }
}
