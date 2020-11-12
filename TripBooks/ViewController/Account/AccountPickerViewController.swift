//
//  AccountPickerViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/13.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import SwiftEntryKit

fileprivate let heightButtonBar: CGFloat = 60

fileprivate let titleColor: UIColor = .white
fileprivate let amountTextColor: UIColor = TBColor.gray.light
fileprivate let backgroundColor = TBColor.system.background.dark
class AccountPickerViewController: UIViewController {
    
    lazy var headerView = UIView()
    lazy var buttonView = UIView()
    
    var isForPicker = false
    
    var allAccount = false

    var accounts: [Account] {
        if let book = BookService.shared.currentOpenBook{
            var list = AccountService.shared.getAccountsList(bookId: book.id)
            if allAccount {
                let allAccount = Account(id: -1, bookId: book.id, name: NSLocalizedString("All accounts", comment: "All accounts"), budget: 0, amount: 0, iconImageName: "")
                list.insert(allAccount, at: 0)
            }
            return list
        }
        return []
    }
    
    var currentAccount: Account? {
        didSet {
            accountLabel.text = currentAccount?.name
        }
    }
    
    var accountTableView: UITableView!
    
    lazy var accountLabel = UILabel {
        $0.font = MainFont.medium.with(fontSize: .medium)
        $0.textColor = .white
    }
    
    lazy var addButton: UIButton = {
        let btn = TBNavigationIcon.plus.getButton()
        btn.anchorSize(h: 23, w: 23)
        btn.addTarget(self, action: #selector(addAccountClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var selectedView = UIView {
        $0.backgroundColor = TBColor.system.blue.light
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountTableView = UITableView()
        accountTableView.register(AccountCell.self, forCellReuseIdentifier: String(describing: AccountCell.self))
        accountTableView.delegate = self
        accountTableView.dataSource = self
        accountTableView.backgroundColor = .clear
        setAutoLayout()
        
        // navigationItem
        self.navigationItem.backButtonTitle = ""
        let addBarItem = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem = addBarItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        accountTableView.reloadData()
    }
    
    private func setAutoLayout() {
        self.view.addSubview(headerView)
        self.view.addSubview(accountTableView)
        
        headerView.anchorViewOnTop()
        headerSetting()
        
        if isForPicker {
            setButtonView()
        } else { // picker background set at TBNotify
            self.view.backgroundColor = backgroundColor
        }
        
        let accountTableViewBottom: NSLayoutYAxisAnchor = isForPicker ? buttonView.topAnchor : self.view.bottomAnchor
        
        accountTableView.anchor(top: headerView.bottomAnchor, bottom: accountTableViewBottom, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
    }
    
    private func headerSetting() {
        headerView.addSubview(accountLabel)
        accountLabel.anchorToSuperViewCenter()
    }
    
    private func setButtonView() {
        self.view.addSubview(buttonView)
        buttonView.anchorViewOnBottom()
    }
    
    @IBAction func addAccountClicked(_ sender: UIButton) {
        let vc = AccountDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: extension - UITableViewDelegate
extension AccountPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.accountTableView.dequeueReusableCell(withIdentifier: String(describing: AccountCell.self), for: indexPath) as? AccountCell {
            cell.selectedBackgroundView = selectedView
            cell.item = self.accounts[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentAccount = self.accounts[indexPath.row]
        if !isForPicker {
            let vc = AccountDetailViewController()
            vc.account = currentAccount
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: AccountCell
class AccountCell: GenericInfoCell<Account> {
    override var item: Account! {
        didSet {
            if item.id == -1 {
                titleLabel.textColor = titleColor
                titleLabel.text = item.name
                titleLabel.anchorCenterX(to: self.contentView)
            } else {
                titleLabel.textColor = titleColor
                titleLabel.text = item.name
                
                amountLabel.textColor = amountTextColor
                amountLabel.text = TBFunc.convertDoubleToStr(item.budget + item.amount)
            }
        }
    }
    
    override func setIconImage() {
        if item.id == -1 { // all accounts
            iconImageView.backgroundColor = .clear
        } else {
            iconImageName = item.iconImageName
            super.setIconImage()
        }
    }
}
