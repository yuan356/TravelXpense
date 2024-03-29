//
//  Category.swift
//  TripBooks
//
//  Created by yuan on 2020/9/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import FMDB

class Category {
    var id: Int
    var title: String
    var isExpense: Bool
    var colorHex: String
    var iconImageName: String
    
    init(id: Int, title: String, isExpense: Bool, colorHex: String, iconName: String) {
        self.id = id
        self.title = title
        self.isExpense = isExpense
        self.colorHex = colorHex
        self.iconImageName = iconName
    }
    
    static func getCategoryByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Category? {
        
        guard let title = dataLists.string(forColumn: CategoryField.title),
              let colorHex = dataLists.string(forColumn: CategoryField.colorHex),
              let iconImageName = dataLists.string(forColumn: CategoryField.iconImageName) else {
            return nil
        }
        
        let isExpense = dataLists.bool(forColumn: CategoryField.id)
        let id = Int(dataLists.int(forColumn: CategoryField.id))
        
        return Category(id: id, title: title, isExpense: isExpense, colorHex: colorHex, iconName: iconImageName)
    }
}
