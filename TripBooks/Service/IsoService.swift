//
//  IsoService.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/23.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class IsoService {

    static let shared = IsoService()
    
    var myCurrency: Currency?
    
    private init() {
        getMyCurrency()
    }
    
    var allCountries: [IsoCountryInfo] {
        return IsoCountries.allCountries
    }
    
    static func getCountryNameByCode(code: String) -> String {
        return IsoCountryCodes.find(key: code)?.name ?? ""
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
}
