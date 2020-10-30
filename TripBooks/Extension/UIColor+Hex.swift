//
//  UIColor+ext.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/6.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

extension UIColor {
    /*
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    */
}

extension UIColor {
    public convenience init(hex: String, alpha: CGFloat = 1.0) {

        if hex.count == 6 {
            var rgbValue: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&rgbValue)

            let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(rgbValue & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: alpha)
            return
        }
        
        self.init(red: 255, green: 255, blue: 255, alpha: alpha)
        return
    }
}


