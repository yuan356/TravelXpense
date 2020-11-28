//
//  RecordTableReloadNotificaion.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/19.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let recordTableUpdate = Notification.Name("recordTableUpdate")
    static let accountAmountUpdate = Notification.Name("accountAmountUpdate")
    static let bookNameUpdate = Notification.Name("bookNameUpdate")
    static let authLog = Notification.Name("authLog")
    static let bookCellUpdate = Notification.Name("bookCellUpdate")
    static let bookCellDelete = Notification.Name("bookCellDelete")
    static let bookTableReload = Notification.Name("bookTableReload")
}

enum InfoKey: String {
    case defalut
    case bookName
    case accountAmount
    case bookUpdate
    case bookDelete
}

protocol ObserverProtocol: AnyObject {
    func handleNotification(name: Notification.Name, infoKey: InfoKey?, infoValue: Any?)
}

class TXObserver {
    
    let infoKey: InfoKey?
    
    var notificationName: Notification.Name
    
    weak var delegate: ObserverProtocol?
    
    init(notification: Notification.Name, infoKey: InfoKey?) {
        self.notificationName = notification
        self.infoKey = infoKey
        subscribe()
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification(_:)), name: notificationName, object: nil)
    }
    
    private func unsubscribe() {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
    
    @IBAction func receiveNotification(_ notification: Notification) {
        var value: Any?
        if let key = infoKey {
            value = notification.userInfo?[key.rawValue]
        }
        self.delegate?.handleNotification(name: notification.name, infoKey: infoKey, infoValue: value)
    } // end func receiveNotification
    
    deinit {
        unsubscribe()
    }
}

class TXObserved {
    static func notifyObservers(notificationName: Notification.Name, infoKey: InfoKey?, infoValue: Any?) {
        var userInfo: [AnyHashable : Any]?
        
        if let infoKey = infoKey, let infoValue = infoValue {
            userInfo = [infoKey.rawValue: infoValue]
        }

        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
    }
}
