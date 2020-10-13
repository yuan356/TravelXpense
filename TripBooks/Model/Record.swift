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
    var date: Date
    var accountId: Int
    
    init(id: Int, title: String, description: String, category: Category, amount: Double, date: Date, accountId: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.amount = amount
        self.date = date
        self.accountId = accountId
    }
    
//    static func getRecordByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Record? {
        
//    }
}
