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
    var name: String
    var amount: Double
    var iconImageName: String
    
    init(id: Int, name: String, amount: Double, iconImageName: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.iconImageName = iconImageName
    }
    
    static func getAccountByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Account? {
        
        guard let name = dataLists.string(forColumn: AccountField.name),
              let iconImageName = dataLists.string(forColumn: AccountField.iconImageName) else {
            return nil
        }
        
        let id = Int(dataLists.int(forColumn: BookField.id))
        let amount = dataLists.double(forColumn: AccountField.amount)
        
        return Account(id: id, name: name, amount: amount, iconImageName: iconImageName)
    }
}
