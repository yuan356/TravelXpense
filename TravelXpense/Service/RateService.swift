//
//  RateService.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/10.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class RateService {
    
    static let shared = RateService()
    
    var myCurrency: Currency?
    
    var rateData: [String: Double] = [:]
    
    var dataTime: Date!
    
    private init() {
        getMyCurrency()
    }
    
    var index = 0
    
    func initData() {
        if let data = UserDefaults.standard.dictionary(forKey: UserDefaultsKey.exchangeRateData.rawValue) as? [String: Double] {
            self.rateData = data
            let time = UserDefaults.standard.double(forKey: UserDefaultsKey.rateDataTime.rawValue)
            self.dataTime = Date(timeIntervalSince1970: time)
        } else {
            getNewData()
        }
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.autoUpdateRate.rawValue) {
            checkAutoUpdate()
        }
    }
    
    func getNewData(completion: (() -> ())? = nil) {
        RateService.getRateData { (data, time) in
            self.rateData = data
            self.dataTime = Date(timeIntervalSince1970: time)
            completion?()
        }
    }
    
    func checkAutoUpdate() {
        let days = TXFunc.getDaysInterval(start: self.dataTime, end: Date()) ?? 0
        if days >= 7 {
            getNewData()
        }
    }
    
    static func getRateData(completionHandler: @escaping (_ data: [String: Double], _ time: Double) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://tw.rter.info/capi.php")!,timeoutInterval: 5)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsDict = json as? [String: Any] {
                    let dict = jsDict.reduce(into: [String: Double]()) { (result, rateData) in
                        if let data = rateData.value as? [String: Any],
                           let rate = data["Exrate"] as? Double {
                            let key = rateData.key
                            let index = key.index(key.startIndex, offsetBy: 3)
                            let code = String(key[index...])
          
                            result[code] = rate
                        }
                    }
       
                    UserDefaults.standard.set(dict, forKey: UserDefaultsKey.exchangeRateData.rawValue)
                    let time = Date().timeIntervalSince1970
                    UserDefaults.standard.set(time, forKey: UserDefaultsKey.rateDataTime.rawValue)
                    completionHandler(dict, time)
                }
            } catch {}
        }

        task.resume()
    }
    
    func getMyCurrency() {

        if let userCode = UserDefaults.standard.string(forKey: UserDefaultsKey.myCurrency.rawValue) {
            myCurrency = Currency(code: userCode)
        } else { // UserDefaults not set
            var code: String?
            let locale = Locale.current // NSLocale.current
            if let currencyCode  = locale.currencyCode {
                let codes = IsoCountryCodes.searchByCurrency(currencyCode)
                if codes.count > 0 {
                    code = currencyCode
                }
            }
            UserDefaults.standard.set(code, forKey: UserDefaultsKey.myCurrency.rawValue)
            if let code = code {
                myCurrency = Currency(code: code)
            }
        }
    }
    
    func setMyCurrency(code: String) {
        UserDefaults.standard.set(code, forKey: UserDefaultsKey.myCurrency.rawValue)
        myCurrency = Currency(code: code)
    }
    
    func exchange(to code: String, amount: Double) -> Double {
        var amount = amount
        if let rateToUSD = rateData[code] {
            amount = amount / rateToUSD // -> USD
            if let currency = myCurrency,
               let rateToMy = rateData[currency.code] {
                amount = amount * rateToMy // USD -> myCurrency
            }
        }
        return amount
    }
}
