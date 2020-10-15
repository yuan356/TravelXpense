//
//  String+ext.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/15.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

extension String {
//    func isStringContainsOnlyNumbers(string: String) -> Bool {
//        return string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
//    }
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
