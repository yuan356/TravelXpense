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
    var daysInterval: Int
    var createTime: Double
    
    init(id: Int, name: String, country: String, coverImageNo: Int?,
         totalAmount: Double, startDate: Date, daysInterval: Int, createTime: Double) {
        self.id = id
        self.name = name
        self.country = country
        self.coverImageNo = coverImageNo ?? nil
        self.totalAmount = totalAmount
        self.startDate = startDate
        self.daysInterval = daysInterval
        self.createTime = createTime
    }
    
    static func getBookByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Book? {
        
        guard let name = dataLists.string(forColumn: BookField.name),
              let country = dataLists.string(forColumn: BookField.country),
              let startDate = dataLists.date(forColumn: BookField.startDate) else {
            return nil
        }
        
       return Book(id: Int(dataLists.int(forColumn: BookField.id)), name: name, country: country, coverImageNo: Int(dataLists.int(forColumn: BookField.coverImageNo)), totalAmount: dataLists.double(forColumn: BookField.totalAmount), startDate: startDate, daysInterval: Int(dataLists.int(forColumn: BookField.daysInterval)), createTime: dataLists.double(forColumn: BookField.createTime))
    }
}
