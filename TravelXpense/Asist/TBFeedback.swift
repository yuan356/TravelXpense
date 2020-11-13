//
//  TBFeedback.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/20.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let buttonFeedback = UIImpactFeedbackGenerator(style: .light)
fileprivate let notificationFeedback = UINotificationFeedbackGenerator()

class TBFeedback {

    static func buttonOccur() {
        buttonFeedback.impactOccurred()
    }
    
    static func notificationOccur(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationFeedback.notificationOccurred(type)
    }
}
