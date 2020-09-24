//
//  SubCategory.swift
//  TripBooks
//
//  Created by yuan on 2020/9/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class SubCategory {

    var title: String
    var icon: UIImage
    
    init(title: String, iconName: String) {
        self.title = title
        self.icon = Category.getIconInBundleByName(iconName: iconName)
    }
}
