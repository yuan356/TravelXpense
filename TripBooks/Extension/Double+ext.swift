//
//  Double+ext.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

extension Double {
    mutating func turnToPositive() {
        self *= (self > 0) ? 1 : -1
    }
    
    mutating func turnToNegative() {
        self *= (self > 0) ? -1 : 1
    }
    
    func rounding(toDecimal decimal: Int) -> Double {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
     
}
