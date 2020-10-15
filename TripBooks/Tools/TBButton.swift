//
//  TBButton.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/14.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum TBButton: String {
    case check = "check"
    case cancel = "cancel"
    case plus = "plus"
    case home = "home"
    case menu = "menu"
    
    func getButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: rawValue), for: .normal)
        return button
    }
}
