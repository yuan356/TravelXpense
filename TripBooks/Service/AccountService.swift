//
//  AccountService.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/14.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

let defaultAccount = (name: "Cash", iconName: "coins")
let UserDefaultsdefaultAccountId = "defaultAccountId"

class AccountService {

    static let shared = AccountService()
    
    var observer: Observer!
    
    private init() {}
    
    var cache: [Int: Account] = [:]
    
    func getAccountsList(bookId: Int) -> [Account] {

        var list = [Account]()
        let orderd = cache.sorted { first, second in
            return first.0 < second.0
        }

        list = orderd.reduce(into: [Account]()) { (result, dict) in
            result.append(dict.value)
        }
        
        return list
    }
    
    /// when *BookContainer* open, get all accounts from DB, and **reset the cahce**.
    func getAllAccountsFromBook(bookId: Int) {
        let accounts = DBManager.shared.getAllAccountsFromBook(bookId: bookId)
        
        let cache = accounts.reduce(into: [:], { (result, acc) in
            result[acc.id] = acc
        })
        
        self.cache = cache
        
        if cache.count == 0 { // 理論上不會發生
            setDefaultAccounts(bookId: bookId)
        }
        
    }
    
    
    func getAccountFromCache(accountId id: Int) -> Account? {
        return self.cache[id]
    }
    
    // MARK: Insert
    func insertNewAccount(bookId: Int, name: String, budget: Double, iconName: String) {
        guard let newAcc = DBManager.shared.addNewAccount(bookId: bookId, name: name, budget: budget, iconName: iconName) else {
            return
        }
        
        // add new account to cache
        cache[newAcc.id] = newAcc
    }
    
    // MARK: Update
    func updateAccount(accountId: Int, value: (String, Double, String)) {
        guard let newAcc = DBManager.shared.updateAccount(accountId: accountId, name: value.0, budget: value.1, iconName: value.2) else {
            return
        }
        // update account in cache
        guard let oldAcc = cache[accountId] else {
            return
        }
        
        oldAcc.name = newAcc.name
        oldAcc.budget = newAcc.budget
        oldAcc.iconImageName = newAcc.iconImageName
    }
    
    func deleteAccount(accountId: Int) {
        DBManager.shared.deleteAccount(accountId: accountId)
        RecordSevice.shared.deleteRecordsOfAccounts(accountId: accountId)
        cache[accountId] = nil
    }
    
    // MARK: Default account
    /// add a default account for book
    func setDefaultAccounts(bookId: Int) {
        guard self.cache.count == 0 else {
            return
        }
        
        if let acc = DBManager.shared.addNewAccount(bookId: bookId, name: defaultAccount.name, iconName: defaultAccount.iconName) {
            self.cache[acc.id] = acc
        }
    }
    
    func getDefaultAccount(bookId: Int) -> Account? {
        let accList = getAccountsList(bookId: bookId)
        if accList.count > 0 {
            return accList[0]
        } else { // no account exist - 理論上不會發生 (限制每個book必須要有一個account)
            return nil
        }
    }
    
    func updateAmount(accountId: Int, value: Double) {
        if let acc = getAccountFromCache(accountId: accountId) {
            acc.amount += value
            TBObserved.notifyObservers(notificationName: .accountAmountUpdate, infoKey: .accountAmount, infoValue: acc)
        }
    }
    
    func calculateAmountInBook(bookId: Int) {
        for acc in cache.values {
            acc.calculateAmount()
        }
    }

}
