//
//  DisplayMode.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/6.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum Mode {
    case light
    case dark
}

class DisplayMode {
    
    static let mode = Mode.dark
    
    static func statusBarStyle() -> UIStatusBarStyle {
        switch mode {
        case .light:
            return .darkContent
        case .dark:
            return .lightContent
        }
    }
}
