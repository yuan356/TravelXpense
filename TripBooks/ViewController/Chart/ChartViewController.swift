//
//  ChartViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/28.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit


fileprivate let backgroundColor = TBColor.darkGary

class ChartViewController: UIViewController {

    var book: Book!
    
    let pieChart = TBPieChartView()
    
    var currentAccount: Account?
    
    var isExpense: Bool = true
    
    var amountData: [CategoryAmount] = []
    
    lazy var controlBarView = UIView {
        $0.backgroundColor = .white
    }
    
    lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        tableView.backgroundColor = .clear
        tableView.register(AmountDataCell.self, forCellReuseIdentifier: String(describing: AmountDataCell.self))
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        setViews()
        
        currentAccount = AccountService.shared.getDefaultAccount(bookId: book.id)
        
        if let acc = currentAccount {
            amountData = RecordSevice.shared.orderByAmount(accountId: acc.id, isExpense: isExpense)
            pieChart.setData(datalist: amountData)
        }
    }
    
    private func setViews() {
        self.view.addSubview(controlBarView)
        controlBarView.anchorViewOnTop()
        
        self.view.addSubview(pieChart)
        pieChart.anchor(top: controlBarView.bottomAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        pieChart.anchorSize(h: UIScreen.main.bounds.height / 3)
        
        let rankingLabel = UILabel {
            $0.text = "Ranking"
            $0.font = MainFont.bold.with(fontSize: .medium)
            $0.textColor = .white
        }
        
        self.view.addSubview(rankingLabel)
        rankingLabel.anchor(top: pieChart.bottomAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0))
        
        self.view.addSubview(tableView)
        tableView.anchor(top: rankingLabel.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
    }
    
    private func changeAccount(accountId: Int) {
        if let acc = AccountService.shared.getAccountFromCache(accountId: accountId) {
            self.currentAccount = acc
        }
        // update chart...
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
        lineView.backgroundColor = .lightGray
        self.view.addSubview(lineView)
        lineView.anchor(top: nil, bottom: view.bottomAnchor, leading: titleLabel.leadingAnchor, trailing: amountLabel.trailingAnchor, size: CGSize(width: 0, height: 1))
    }
    
    override func setIconImage() {
        iconImageName = item.category.iconImageName
        iconColorHex = item.category.colorHex
        super.setIconImage()
    }
}
