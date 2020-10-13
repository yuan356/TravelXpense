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
    var title: String
    var colorHex: String
    var iconImageName: String
    
    init(title: String, colorHex: String, iconName: String) {
        self.title = title
        self.colorHex = colorHex
        self.iconImageName = iconName
    }
    
    static func getCategoryByFMDBdata(FMDBdatalist dataLists: FMResultSet) -> Category? {
        
        guard let title = dataLists.string(forColumn: CategoryField.title),
              let colorHex = dataLists.string(forColumn: CategoryField.colorHex),
              let iconImageName = dataLists.string(forColumn: CategoryField.iconImageName) else {
            return nil
        }
        
        return Category(title: title, colorHex: colorHex, iconName: iconImageName)
    }
}
