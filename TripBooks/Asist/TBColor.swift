//
//  Color.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/13.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

struct TBColor {
    
    static func background() -> UIColor {
        if DisplayMode.statusBarStyle() == .darkContent {
            return UIColor(hex: "171F26")
        } else {
            return UIColor(hex: "171F26") // light
        }
    }
    
    struct system {
        struct background {
            static let dark = UIColor(hex: "171F26")
        }
        // gunmetal: 2B3840 ; charcoal: 2D3F4B
        struct blue {
            static let medium = UIColor(hex: "2D3F4B")
            static let light = UIColor(hex: "3D5466")
        }
        static let picker = UIColor(hex: "1F2933")
        static let veronese = UIColor(hex: "1C9B84")
    }
    
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
    
    static let blurBackground = #colorLiteral(red: 0.07533254474, green: 0.07489258796, blue: 0.07567579299, alpha: 0.6472870291)
    
    static let beauBlue = UIColor(hex: "CCE2FF")
    
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
