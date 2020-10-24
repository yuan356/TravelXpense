//
//  Book.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/22.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import FMDB

class Book {
    var id: Int
    var name: String
    var country: String
    var currency: String
    var coverImageNo: Int?
    var totalAmount: Double
    var budget: Double
    var startDate: Date
    var endDate: Date
    var createDate: Double
    var days: Int = 0
    
    init(id: Int, name: String, country: String, currency: String, coverImageNo: Int?,
         totalAmount: Double, budget: Double, startDate: Date, endDate: Date, createDate: Double) {
        self.id = id
        self.name = name
        self.country = country
        self.currency = currency
        self.coverImageNo = coverImageNo ?? nil
        self.totalAmount = totalAmount
        self.budget = budget
        self.startDate = startDate
        self.endDate = endDate
        self.createDate = createDate
        if let daysInterval = TBFunc.getDaysInterval(start: startDate, end: endDate) {
            self.days = daysInterval + 1
        }
    }
    
    static func getBookByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Book? {
        
        guard let name = dataLists.string(forColumn: BookField.name),
              let country = dataLists.string(forColumn: BookField.country),
              let currency = dataLists.string(forColumn: BookField.currency) ?? "",
              let startDate = dataLists.date(forColumn: BookField.startDate),
              let endDate = dataLists.date(forColumn: BookField.endDate) else {
            return nil
        }
        
        let id = Int(dataLists.int(forColumn: BookField.id))
        let coverImageNo = Int(dataLists.int(forColumn: BookField.coverImageNo))
        let totalAmount = dataLists.double(forColumn: BookField.totalAmount)
        let budget = dataLists.double(forColumn: BookField.budget)
        let createDate = dataLists.double(forColumn: BookField.createdDate)
        
        return Book(id: id, name: name, country: country, currency: currency, coverImageNo: coverImageNo, totalAmount: totalAmount, budget: budget,  startDate: startDate, endDate: endDate, createDate: createDate)
    }

    func updateData(field: BookFieldForUpdate, value: NSObject) {
        BookService.shared.updateBook(bookId: self.id, field: field, value: value)
    }
}
