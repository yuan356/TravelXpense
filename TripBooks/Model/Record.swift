//
//  Detail.swift
//  TripBooks
//
//  Created by yuan on 2020/9/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class Record {
    var id: Int
    var title: String
    var description: String
    var category: Category
    var amount: Double
    var account: Account
    var date: Date
    var accountId: Int
    
    init(id: Int, title: String, description: String, amount: Double, category: Category, account: Account, date: Date, accountId: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.amount = amount
        self.category = category
        self.account = account
        self.date = date
        self.accountId = accountId
    }
    
//    static func getRecordByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Record? {
        
//    }
}
