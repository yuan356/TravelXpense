//
//  Detail.swift
//  TripBooks
//
//  Created by yuan on 2020/9/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
/*
enum Category: String {
    case foods
    case drinks
    
    static func value(_ value: Category) -> String {
        return value.rawValue
    }
}

enum DetailKey {
    static let id = "id"
    static let amount = "amount"
    static let category = "category"
    static let timestamp = "timestamp"
}

class Detail {
    var detail_id: String
    var category: Category
    var amount: Double
    var timestamp: Double
    
    init(detail_id: String, category: Category, amount: Double, timestamp: Double) {
        self.detail_id = detail_id
        self.category = category
        self.amount = amount
        self.timestamp = timestamp
    }
    
    static func getDetailFromDict(detail_id: String, detailInfo: [String: Any]) -> Detail? {
        guard let categoryStr = detailInfo[DetailKey.category] as? String, let category = Category(rawValue: categoryStr),
            let amount = detailInfo[DetailKey.amount] as? Double,
            let timestamp = detailInfo[DetailKey.timestamp] as? Double else {
            return nil
        }
        
        return Detail(detail_id: detail_id, category: category, amount: amount, timestamp: timestamp)
    }
}
 */
