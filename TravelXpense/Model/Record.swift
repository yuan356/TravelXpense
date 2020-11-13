//
//  Detail.swift
//  TripBooks
//
//  Created by yuan on 2020/9/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import FMDB

class Record {
    var id: Int
    var bookId: Int
    var amount: Double
    var title: String
    var note: String
    var date: Date
    var category: Category
    var account: Account
    var createTime: Double
    
    init(id: Int, bookId: Int, amount: Double, title: String, note: String, date: Date, category: Category, account: Account, createTime: Double) {
        self.id = id
        self.bookId = bookId
        self.amount = amount
        self.title = title
        self.note = note
        self.date = date
        self.category = category
        self.account = account
        self.createTime = createTime
    }
    
    static func getRecordByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Record? {
        
        let id = Int(dataLists.int(forColumn: RecordField.id))
        let bookId = Int(dataLists.int(forColumn: RecordField.bookId))
        let amount = dataLists.double(forColumn: RecordField.amount)
        let categoryId = Int(dataLists.int(forColumn: RecordField.categoryId))
        let accountId = Int(dataLists.int(forColumn: RecordField.accountId))
        let createTime = dataLists.double(forColumn: RecordField.createdDate)
        
        guard let title = dataLists.string(forColumn: RecordField.title),
              let note = dataLists.string(forColumn: RecordField.note),
              let date = dataLists.date(forColumn: RecordField.date),
              let category = CategoryService.shared.getCategoryFromCache(by: categoryId),
              let account = AccountService.shared.getAccountFromCache(accountId: accountId) else {
            return nil
        }
        
        return Record(id: id, bookId: bookId, amount: amount, title: title, note: note, date: date, category: category, account: account, createTime: createTime)
    }
}
