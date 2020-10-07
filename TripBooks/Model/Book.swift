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
    var createTime: Double
    var days: Int = 0
    
    init(id: Int, name: String, country: String, coverImageNo: Int?,
         totalAmount: Double, startDate: Date, endDate: Date, createTime: Double) {
        self.id = id
        self.name = name
        self.country = country
        self.coverImageNo = coverImageNo ?? nil
        self.totalAmount = totalAmount
        self.startDate = startDate
        self.endDate = endDate
        self.createTime = createTime
        if let daysInterval = Func.getDaysInterval(start: startDate, end: endDate) {
            print(startDate)
            print(endDate)
            print(daysInterval)
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
        
        return Book(id: Int(dataLists.int(forColumn: BookField.id)), name: name, country: country, coverImageNo: Int(dataLists.int(forColumn: BookField.coverImageNo)), totalAmount: dataLists.double(forColumn: BookField.totalAmount), startDate: startDate, endDate: endDate, createTime: dataLists.double(forColumn: BookField.createdDate))
    }
}
