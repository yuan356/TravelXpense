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
    var coverImageNo: Int?
    var totalAmount: Double
    var startDate: Date
    var endDate: Date
    var createDate: Double
    var days: Int = 0
    
    init(id: Int, name: String, country: String, coverImageNo: Int?,
         totalAmount: Double, startDate: Date, endDate: Date, createDate: Double) {
        self.id = id
        self.name = name
        self.country = country
        self.coverImageNo = coverImageNo ?? nil
        self.totalAmount = totalAmount
        self.startDate = startDate
        self.endDate = endDate
        self.createDate = createDate
        if let daysInterval = TBfunc.getDaysInterval(start: startDate, end: endDate) {
            self.days = daysInterval + 1
        }
    }
    
    static func getBookByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Book? {
        
        guard let name = dataLists.string(forColumn: BookField.name),
              let country = dataLists.string(forColumn: BookField.country),
              let startDate = dataLists.date(forColumn: BookField.startDate),
              let endDate = dataLists.date(forColumn: BookField.endDate) else {
            return nil
        }
        
        let id = Int(dataLists.int(forColumn: BookField.id))
        let coverImageNo = Int(dataLists.int(forColumn: BookField.coverImageNo))
        let totalAmount = dataLists.double(forColumn: BookField.totalAmount)
        let createDate = dataLists.double(forColumn: BookField.createdDate)
        
        return Book(id: id, name: name, country: country, coverImageNo: coverImageNo, totalAmount: totalAmount, startDate: startDate, endDate: endDate, createDate: createDate)
    }
}
