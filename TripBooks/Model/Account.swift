//
//  Account.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/13.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import FMDB

class Account {
    var id: Int
    var bookId: Int
    var name: String
    var budget: Double
    var amount: Double
    var iconImageName: String
    
    init(id: Int, bookId: Int, name: String, budget: Double, amount: Double, iconImageName: String) {
        self.id = id
        self.bookId = bookId
        self.name = name
        self.budget = budget
        self.amount = amount
        self.iconImageName = iconImageName
    }
    
    static func getAccountByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Account? {
        
        guard let name = dataLists.string(forColumn: AccountField.name),
              let iconImageName = dataLists.string(forColumn: AccountField.iconImageName) else {
            return nil
        }
        
        let id = Int(dataLists.int(forColumn: AccountField.id))
        let bookId = Int(dataLists.int(forColumn: AccountField.bookId))
        let budget = dataLists.double(forColumn: AccountField.budget)
        let amount = dataLists.double(forColumn: AccountField.amount)
        
        return Account(id: id, bookId: bookId, name: name, budget: budget, amount: amount, iconImageName: iconImageName)
    }
}
