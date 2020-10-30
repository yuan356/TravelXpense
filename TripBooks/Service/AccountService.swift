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
        
    private init() {}
    var cache: [Int: Account] = [:]
    /// key: bookId, value: [accountId : account]
//    var accountsCache: [Int:[Int:Account]] = [:]
    
    func getAccountsList(bookId: Int) -> [Account] {
//        var list = [Account]()
//        if let accCache = accountsCache[bookId] {
//            let orderd = accCache.sorted { first, second in
//                return first.0 < second.0
//            }
//
//            list = orderd.reduce(into: [Account]()) { (result, dict) in
//                result.append(dict.value)
//            }
//        }
//        return list
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
    }
    
    
    func getAccountFromCache(accountId id: Int) -> Account? {
        return self.cache[id]
    }
    
    /// add a default account for book
    func setDefaultAccounts(bookId: Int) {
        self.getAllAccountsFromBook(bookId: bookId)
        
        guard self.cache.count == 0 else {
            return
        }
        
        let _ = DBManager.shared.addNewAccount(bookId: bookId, name: defaultAccount.name, iconName: defaultAccount.iconName)
    }
    
    func getDefaultAccount(bookId: Int) -> Account? {
        let accList = getAccountsList(bookId: bookId)
        if accList.count > 0 {
            return accList[0]
        } else { // no account exist - 理論上不會發生 (限制每個book必須要有一個account)
            return nil
        }
    }
    
    func deleteAccount() {
        
    }
}
