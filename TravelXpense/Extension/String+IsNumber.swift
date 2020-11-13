//
//  String+ext.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/15.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

extension String {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
