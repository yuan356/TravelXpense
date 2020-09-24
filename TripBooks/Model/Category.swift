//
//  Category.swift
//  TripBooks
//
//  Created by yuan on 2020/9/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class Category {
    var title: String
    var color: UIColor
    var icon: UIImage
    
    init(title: String, colorHex: String, iconName: String) {
        self.title = title
        self.color = Category.getUIColorFromHex(Hex: colorHex)
        self.icon = Category.getIconInBundleByName(iconName: iconName)
    }
    
    static private func getUIColorFromHex(Hex: String) -> UIColor {
        // ...
        return UIColor.white
    }
    
    static func getIconInBundleByName(iconName: String) -> UIImage {
        // ...
        return UIImage(systemName: iconName) ?? UIImage()
    }
}
