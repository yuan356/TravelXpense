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

// color
fileprivate let backgroundColor = TBColor.darkGary


class AccountPickerViewController: UIViewController {
    
    lazy var headerView = UIView()
    lazy var buttonView = UIView()
    
    var isForPicker = false

    var accounts: [Account] {
        if let book = BookService.shared.currentOpenBook{
            return AccountService.shared.getAccountsList(bookId: book.id)
        }
        return []
    }
    
    var currentAccount: Account?
    
    var accountTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountTableView = UITableView()
        accountTableView.register(AccountCell.self, forCellReuseIdentifier: String(describing: AccountCell.self))
        accountTableView.delegate = self
        accountTableView.dataSource = self
        accountTableView.backgroundColor = .clear
        setAutoLayout()
    }
    
    private func setAutoLayout() {
        self.view.addSubview(headerView)
        self.view.addSubview(accountTableView)
        
        headerView.anchorViewOnTop()
        setHeaderButton()
        
        if isForPicker {
            setButtonView()
        } else {
            self.view.backgroundColor = backgroundColor
        }
        let accountTableViewBottom: NSLayoutYAxisAnchor = isForPicker ? buttonView.topAnchor : self.view.bottomAnchor
        
        accountTableView.anchor(top: headerView.bottomAnchor, bottom: accountTableViewBottom, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
    }
    
    private func setHeaderButton() {
        let plusButton: UIButton = TBButton.plus.getButton()
        plusButton.addTarget(self, action: #selector(addAccountClicked(_:)), for: .touchUpInside)
        self.view.addSubview(plusButton)
        plusButton.anchorButtonToHeader(position: .right)
        
        let closeButton: UIButton = TBButton.cancel.getButton()
        closeButton.addTarget(self, action: #selector(cancelClicked(_:)), for: .touchUpInside)
        self.view.addSubview(closeButton)
        closeButton.anchorButtonToHeader(position: .left)
    }
    
    private func setButtonView() {
        self.view.addSubview(buttonView)
        buttonView.anchorViewOnBottom()
    }
    
    @IBAction func addAccountClicked(_ sender: UIButton) {
        print("add")
    }

    @IBAction func cancelClicked(_ sender: UIButton) {
        print("close")
        TBNotify.dismiss(name: AccountPickerAttributes)
    }
}

extension AccountPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.accountTableView.dequeueReusableCell(withIdentifier: String(describing: AccountCell.self), for: indexPath) as? AccountCell {
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

class AccountCell: GenericInfoCell<Account> {
    override var item: Account! {
        didSet {
            
            titleLabel.text = item.name
            amountLabel.text = TBFunc.convertDoubleToStr(item.amount)
        }
    }
    
    override func setIconImage() {
        iconImageName = item.iconImageName
        super.setIconImage()
    }
}
