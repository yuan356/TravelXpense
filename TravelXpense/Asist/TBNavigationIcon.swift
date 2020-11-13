//
//  TBButton.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/14.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum TBNavigationIcon: String {
    case check = "check"
    case cancel = "cancel"
    case plus = "plus"
    case home = "home"
    case menu = "menu"
    case settings = "settings"
    case chart = "chart"
    case more = "more"
    case arrowLeft = "arrow-left"
    case arrowRight = "arrow-right"
    case trash = "trash"
    case downArrow = "down-sketched-arrow"
    case exchange = "exchange"
    
    func getButton() -> UIButton {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(named: rawValue), for: .normal)
        return button
    }
}
