//
//  MainFunc.swift
//  TripBooks
//
//  Created by yuan on 2020/9/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class TBfunc {
    
    /// convert Double to String
    /// - Parameter value: Double value
    /// - Returns: String value
    /// # 若為整數，將去除小數點
    static func convertDoubleToStr(_ value: Double) -> String {
        if floor(value) == value { return String(Int(value)) }
        return String(value)
    }

    static func convertDoubleTimeToDateStr(timeStamp: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.timeZone = .current // 取得系統目前timezone
        let date = Date(timeIntervalSince1970: timeStamp)
        let today = dateFormatter.string(from: date)
        return today
    }
    
    static func convertDateToDateStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.timeZone = .current // 取得系統目前timezone
        let today = dateFormatter.string(from: date)
        return today
    }
    
    static func getDaysInterval(start startDate: Date, end endDate: Date) -> Int? {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day
    }
    
    static func getDateByOffset(startDate: Date, daysInterval: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.day = daysInterval
        let date = calendar.date(byAdding: dateComponent, to: startDate)
        return date
    }
}
