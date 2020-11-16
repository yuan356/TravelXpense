//
//  MainFont.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/14.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

typealias MainFont = Font.NotoSansTC
typealias MainFontNumeral = Font.Rubik

enum Font {
    enum NotoSansTC: String {
        case light = "Light"
        case medium = "Medium"
        case regular = "Regular"
        case bold = "Bold"
        case thin = "Thin"
        
        func with(fontSize: FontSize) -> UIFont {
            return UIFont(name: "Roboto-\(rawValue)", size: fontSize.rawValue)
                ?? UIFont.systemFont(ofSize: fontSize.rawValue)
        }

        func with(fontSize: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-\(rawValue)", size: fontSize)
                ?? UIFont.systemFont(ofSize: fontSize)
        }
        
    }
    enum Rubik: String {
        case light = "Light"
        case regular = "Regular"
        case medium = "Medium"

        func with(fontSize: FontSize) -> UIFont {
            return UIFont(name: "Rubik-\(rawValue)", size: fontSize.rawValue)
                ?? UIFont.systemFont(ofSize: fontSize.rawValue)
        }
        
        func with(fontSize: CGFloat) -> UIFont {
            return UIFont(name: "Rubik-\(rawValue)", size: fontSize)
                ?? UIFont.systemFont(ofSize: fontSize)
        }
    }
}

enum FontSize: CGFloat {
    case small = 13
    case medium = 18
    case large = 28
}
