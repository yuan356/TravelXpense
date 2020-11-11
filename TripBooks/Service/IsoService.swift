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
        
    private init() {}
    
    var allCountries: [IsoCountryInfo] {
        return IsoCountries.allCountries
    }
    
    static func getCountryNameByCode(code: String) -> String {
        return IsoCountryCodes.find(key: code)?.name ?? ""
    }
    
    
}
