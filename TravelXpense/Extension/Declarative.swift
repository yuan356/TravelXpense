//
//  Declarative.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/22.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

protocol Declarative: AnyObject {
    init()
}
extension Declarative {
    init(configureHandler: (Self) -> Void) {
        self.init()
        configureHandler(self)
    }
}
extension NSObject: Declarative { }
