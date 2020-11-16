//
//  AccountService.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/14.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

let defaultAccount = (name: "Cash", iconName: "acc-3")

class AccountService {

    static let shared = AccountService()
    
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
        
        var firstAcc: Account?
        if accounts.count > 0 {
            firstAcc = accounts[0]
        }
        
        if var defalutAccDic = UserDefaults.standard.dictionary(forKey: UserDefaultsKey.defaultAccountDict.rawValue) {
            if let defaultAccId = defalutAccDic["\(bookId)"] as? Int {
                cache[defaultAccId]?.isDefault = true
            }
            else { // default account haven't set yet
                // 理論上不會進來，因為預設帳戶新增時就會設定 userDefault
                if let acc = firstAcc {
                    defalutAccDic["\(bookId)"] = acc.id
                    cache[acc.id]?.isDefault = true
                    UserDefaults.standard.set(defalutAccDic, forKey: UserDefaultsKey.defaultAccountDict.rawValue)
                }
            }
        } else { // userDefault haven't set yet
            // 理論上不會進來，因為預設帳戶新增時就會設定 userDefault
            var dict = [String: Int]()
            if let acc = firstAcc {
                dict["\(bookId)"] = acc.id
            }
            UserDefaults.standard.set(dict, forKey: UserDefaultsKey.defaultAccountDict.rawValue)
        }

        self.cache = cache
        
        if cache.count == 0 { // 理論上不會發生
            insertDefaultAccounts(bookId: bookId)
        }
    }
    
    func getAccountFromCache(accountId id: Int) -> Account? {
        return self.cache[id]
    }
    
    // MARK: Insert
    func insertNewAccount(bookId: Int, name: String, budget: Double, iconName: String,  completion: ((_ newAcc: Account) -> ())? = nil) {
        guard let newAcc = DBManager.shared.addNewAccount(bookId: bookId, name: name, budget: budget, iconName: iconName) else {
            return
        }
        
        // add new account to cache
        cache[newAcc.id] = newAcc
        
        completion?(newAcc)
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
        
        guard let oldAcc = cache[accountId] else {
            return
        }
        cache[oldAcc.id] = nil
        
        if oldAcc.isDefault {
            let accList = getAccountsList(bookId: oldAcc.bookId)
            if accList.count > 0 {
                let firstAcc = accList[0]
                firstAcc.isDefault = true
                setDefaultAccount(bookId: firstAcc.bookId, accountId: firstAcc.id)
            }
        }
    }
    
    // MARK: Default account
    /// add a default account for book
    func insertDefaultAccounts(bookId: Int) {
        guard self.cache.count == 0 else {
            return
        }
        
        if let acc = DBManager.shared.addNewAccount(bookId: bookId, name: defaultAccount.name, iconName: defaultAccount.iconName) {
            self.cache[acc.id] = acc
            setDefaultAccount(bookId: bookId, accountId: acc.id)
        }
    }
    
    func setDefaultAccount(bookId: Int, accountId: Int) {
        if var dict = UserDefaults.standard.dictionary(forKey: UserDefaultsKey.defaultAccountDict.rawValue) {
            dict["\(bookId)"] = accountId
            UserDefaults.standard.set(dict, forKey: UserDefaultsKey.defaultAccountDict.rawValue)
        } else {
            let dict: [String: Int] = ["\(bookId)": accountId]
            UserDefaults.standard.set(dict, forKey: UserDefaultsKey.defaultAccountDict.rawValue)
        }
        
        let oldDefault = getDefaultAccount(bookId: bookId)
        oldDefault?.isDefault = false
        cache[accountId]?.isDefault = true
    }
    
    /// remove the account default, and set the smallest id to default
    func resetDefaultAccount(bookId: Int, accountId: Int) {
        let accList = getAccountsList(bookId: bookId)
        for acc in accList {
            print(acc.id)
            if acc.id != accountId {
                setDefaultAccount(bookId: bookId, accountId: acc.id)
                return
            }
        }
    }
    
    func getDefaultAccount(bookId: Int) -> Account? {
        for acc in cache.values {
            if acc.isDefault {
                return acc
            }
        }
        return nil
    }
    
    func updateAmount(accountId: Int, value: Double) {
        if let acc = getAccountFromCache(accountId: accountId) {
            acc.amount += value
            TXObserved.notifyObservers(notificationName: .accountAmountUpdate, infoKey: .accountAmount, infoValue: acc)
        }
    }
    
    func calculateAmountInBook(bookId: Int) {
        for acc in cache.values {
            acc.calculateAmount()
        }
    }

}
