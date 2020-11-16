//
//  MainFunc.swift
//  TripBooks
//
//  Created by yuan on 2020/9/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

let amountMaxValue: Double = 9999999999999
let amountMinValue: Double = -9999999999999

class TXFunc {
    
    /// convert Double to String
    /// - Parameter value: Double value
    /// - Returns: String value
    /// # 若為整數，將去除小數點
    static func convertDoubleToStr(_ value: Double, moneyFormat: Bool = true, currencyCode: String? = nil) -> String {
        var value = value
        if floor(value) == value {
            value = min(value, amountMaxValue)
            value = max(value, amountMinValue)
 
            let intValue = Int(value)
            if moneyFormat,
               let moneyString = turnToMoneyFormat(intValue: intValue, currencyCode: currencyCode) {
                return moneyString
            } else {
                return String(intValue)
            }
        } else {
            if moneyFormat,
               let moneyString = turnToMoneyFormat(doubleValue: value, currencyCode: currencyCode) {
                return moneyString
            } else {
                return String(value)
            }
        }
    }
    
    static func turnToMoneyFormat(intValue: Int? = nil, doubleValue: Double? = nil, currencyCode: String? = nil) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let code = (currencyCode == "" || currencyCode == nil) ? "USD" : currencyCode
        var locComps = Locale.components(fromIdentifier: Locale.current.identifier)
        locComps[NSLocale.Key.currencyCode.rawValue] = code
        let locId = Locale.identifier(fromComponents: locComps)
        let loc = Locale(identifier: locId)
        formatter.locale = loc
        
        var result: String?
        if let intValue = intValue {
            formatter.maximumFractionDigits = 0
            result = formatter.string(from: NSNumber(value: intValue))
        } else if let doubleValue = doubleValue {
            formatter.maximumFractionDigits = 3
            result = formatter.string(from: NSNumber(value: doubleValue))
        }
        return result
    }
    
    static func convertDoubleTimeToDateStr(timeStamp: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.timeZone = .current // 取得系統目前timezone
        let date = Date(timeIntervalSince1970: timeStamp)
        let today = dateFormatter.string(from: date)
        return today
    }
    
    static func convertDateToDateStr(date: Date, full: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        if full {
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        } else {
            dateFormatter.dateFormat = "yyyy/MM/dd"
        }
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
    
    static func compareDateOnly(date1: Date, date2: Date) -> Bool {
        let result = Calendar.current.compare(date1, to: date2, toGranularity: .day)
        return result == .orderedSame
    }
    
    /**
      * a < b then return NSOrderedAscending.
     * a > b   then return NSOrderedDescending.
     * a == b  then return NSOrderedSame.
     */
    static func compareDate(date date1: Date, target date2: Date) -> ComparisonResult {
        let result = Calendar.current.compare(date1, to: date2, toGranularity: .day)
        return result
    }
}
