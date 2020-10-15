//
//  AccountPickerViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/13.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import SwiftEntryKit

let heightButtonBar: CGFloat = 60

class AccountPickerViewController: UIViewController {
    
    let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    var isForPicker = false
    
    let buttonView = UIView()
    
    var accounts: [Account] {
        return AccountService.shared.accounts
    }
    
    var currentAccount: Account?
    
    var accountTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TBColor.background()
        self.view.roundedCorners()
        accountTableView = UITableView()
        accountTableView.register(AccountPickerTableViewCell.self, forCellReuseIdentifier: String(describing: AccountPickerTableViewCell.self))
        accountTableView.delegate = self
        accountTableView.dataSource = self
        accountTableView.backgroundColor = UIColor.lightGray
        setAutoLayout()
    }
    
    private func setAutoLayout() {
        self.view.addSubview(headerView)
        self.view.addSubview(accountTableView)
        
        headerView.anchorViewOnTop()
//        setHeaderButton()
        
        if isForPicker {
            setButtonView()
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
        if SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "AccountPickerAttributes") {
            SwiftEntryKit.dismiss(.specific(entryName: "AccountPickerAttributes"))
        }
    }
}

extension AccountPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.accountTableView.dequeueReusableCell(withIdentifier: String(describing: AccountPickerTableViewCell.self), for: indexPath) as? AccountPickerTableViewCell {
            cell.account = self.accounts[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentAccount = self.accounts[indexPath.row]
    }
}
