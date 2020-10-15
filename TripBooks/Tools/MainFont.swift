//
//  MainFont.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/14.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

typealias MainFont = Font.NotoSansTC

enum Font {
    enum NotoSansTC: String {
        case light = "Light"
        case normal = "Medium"
        case regular = "Regular"
        func with(fontSize: FontSize) -> UIFont {
            return UIFont(name: "NotoSansTC-\(rawValue)", size: fontSize.rawValue)!
//                ?? UIFont.systemFont(ofSize: fontSize.rawValue)
        }
    }
}

enum FontSize: CGFloat {
    case small = 12
    case medium = 18
    case large = 30
}
