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
    var country: Country
    var currency: Currency
    var imageUrl: String?
    var totalAmount: Double
    var startDate: Date
    var endDate: Date
    var createDate: Double
    var days: Int = 0
    
    init(id: Int, name: String, country: Country, currency: Currency, imageUrl: String?,
         totalAmount: Double, startDate: Date, endDate: Date, createDate: Double) {
        self.id = id
        self.name = name
        self.country = country
        self.currency = currency
        self.imageUrl = imageUrl
        self.totalAmount = totalAmount
        self.startDate = startDate
        self.endDate = endDate
        self.createDate = createDate
        if let daysInterval = TBFunc.getDaysInterval(start: startDate, end: endDate) {
            self.days = daysInterval + 1
        }
    }
    
    static func getBookByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Book? {
        
        guard let name = dataLists.string(forColumn: BookField.name) ?? "",
              let countryCode = dataLists.string(forColumn: BookField.country) ?? "",
              let currencyCode = dataLists.string(forColumn: BookField.currency) ?? "",
              let startDate = dataLists.date(forColumn: BookField.startDate),
              let endDate = dataLists.date(forColumn: BookField.endDate) else {
            return nil
        }
        
        let id = Int(dataLists.int(forColumn: BookField.id))
        let totalAmount = dataLists.double(forColumn: BookField.totalAmount)
        let createDate = dataLists.double(forColumn: BookField.createdDate)
        let country = Country(code: countryCode)
        let currency = Currency(code: currencyCode)
        let imageUrl = dataLists.string(forColumn: BookField.imageUrl)
        
        return Book(id: id, name: name, country: country, currency: currency, imageUrl: imageUrl, totalAmount: totalAmount,  startDate: startDate, endDate: endDate, createDate: createDate)
    }

    func updateData(field: BookFieldForUpdate, value: NSObject) {
        BookService.shared.updateBook(bookId: self.id, field: field, value: value)
    }
}
