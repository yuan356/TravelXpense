//
//  IsoService.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/23.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

struct Country {
    var name: String
    var code: String
}

struct Currency {
    var code: String
}

class IsoService {

    static let shared = IsoService()
    
    private init() {
        getAllCountriesList()
    }
    
    var countriesList: [Country] = []
    
    private func getAllCountriesList() {
        countriesList = IsoCountries.allCountries.reduce(into: [Country]()) { (result, info) in
            result.append(Country(name: info.name, code: info.alpha2))
        }
    }
}
