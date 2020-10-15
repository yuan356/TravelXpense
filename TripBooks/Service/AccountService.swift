//
//  AccountService.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/14.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

let defaultAccount = (name: "Cash", iconName: "coins")

class AccountService {
    
    static let shared = AccountService()
        
    private init() {}
    
    var cache = [Int: Account]()
    
    var accounts = [Account]()
    
    func getAllAccountsToCache() {
        self.accounts = DBManager.shared.getAllAccounts()
        
        self.cache = self.accounts.reduce(into: [:], { (result, account) in
            result[account.id] = account
        })
    }
    
    func getAccountFromCache(by id: Int) -> Account? {
        return self.cache[id]
    }
    
    /// First time to launch the app.
    func setDefaultAccounts() {
        self.getAllAccountsToCache()
        
        guard self.accounts.count == 0 else {
            return
        }
        
        if let newAcc = DBManager.shared.addNewAccount(name: defaultAccount.name, iconName: defaultAccount.iconName) {
            self.accounts.append(newAcc)
        }
    }
}
