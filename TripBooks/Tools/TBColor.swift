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

let displayModeKey = "displayModeKey"

struct TBColor {
    static let gary = UIColor.lightGray
    static let darkGary = UIColor.darkGray
    struct shamrockGreen {
        static let light = UIColor(hex: "#3F9E64")
        static let dark = UIColor(hex: "#3A925C")
    }
    
    static func background() -> UIColor {
        let modeStr = UserDefaults.standard.string(forKey: displayModeKey) ?? DisplayMode.dark.rawValue
        let mode = DisplayMode.init(rawValue: modeStr)!
        
        var color: UIColor
        switch mode {
        case .light:
            color = UIColor.white
        case .dark:
            color = UIColor.darkGray
        }
        return color
    }
}
