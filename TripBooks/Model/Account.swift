//
//  Account.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/13.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class Account {
    var id: Int
    var title: String
    var name: String
    var iconImageName: String
    
    init(id: Int, title: String, name: String, iconImageName: String) {
        self.id = id
        self.title = title
        self.name = name
        self.iconImageName = iconImageName
    }
}
