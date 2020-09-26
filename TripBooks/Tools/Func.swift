//
//  MainFunc.swift
//  TripBooks
//
//  Created by yuan on 2020/9/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class Func {
    static func doubleToStr(_ value: Double) -> String {
        // 若為整數，去除小數點。
        if floor(value) == value { return String(Int(value)) }
        return String(value)
    }
    

//    let timeStamp = Date().timeIntervalSince1970
//    let date = Date(timeIntervalSince1970: timeStamp)
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
//    dateFormatter.timeZone = .current // 取得系統目前timezone
//    //dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
//    let today = dateFormatter.string(from: date)
//    print("Time Stamp's Current Time:\(today)")
//
//    let dateFormatter2 = DateFormatter()
//    dateFormatter2.dateFormat = "yyyy/MM/dd HH:mm"
//
//    let sdate = dateFormatter2.date(from: "2020/10/10 23:59")

//    class DateTime {
//        var month: Int
//        var weekday: Int
//
//        init(_ timeStamp: Double) {
//            let date = Date(timeIntervalSince1970: timeStamp)
//            let calendar = Calendar.current
//            self.weekday = calendar.component(.weekday, from: date) // Sunday: 1
//            self.month = calendar.component(.month, from: date)
//        }
//    }
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

}
