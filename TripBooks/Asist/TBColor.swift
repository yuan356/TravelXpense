//
//  Color.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/13.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import SwiftEntryKit

enum DisplayMode: String {
    case light
    case dark
}



struct TBColor {
    struct gray {
        static let dark = UIColor.darkGray
        static let medium = UIColor(hex: "ADADAD")
        static let light = UIColor(hex: "D6D6D6")
        static let cellSelected = UIColor(hex: "8F8F8F")
    }
   
    struct shamrockGreen {
        static let light = UIColor(hex: "3F9E64")
        static let dark = UIColor(hex: "3A925C")
    }
    static let beauBlue = UIColor(hex: "CCE2FF")
    
    struct background {
        static let dark = UIColor(hex: "292929")
    }
    
    static let tabBar = UIColor(hex: "141414")
    
    struct delete {
        static let normal = UIColor(hex: "E45C3A")
        static let highlighted = UIColor(hex: "C53D1B")
    }

    struct orange {
        static let light = UIColor(hex: "E9795D")
        static let dark = UIColor(hex: "E24D28")
    }
    
//    static func background() -> UIColor {
//        let modeStr = UserDefaults.standard.string(forKey: displayModeKey) ?? DisplayMode.dark.rawValue
//        let mode = DisplayMode.init(rawValue: modeStr)!
//
//        var color: UIColor
//        switch mode {
//        case .light:
//            color = UIColor.white
//        case .dark:
//            color = UIColor.darkGray
//        }
//        return color
//    }
    
    
}
