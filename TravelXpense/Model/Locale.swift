//
//  Locale.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/25.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

struct Country {
    var code: String
    var name: String
    
    init(code: String) {
        self.code = code
        self.name = IsoService.getCountryNameByCode(code: code)
    }
}

struct Currency {
    var code: String
}
