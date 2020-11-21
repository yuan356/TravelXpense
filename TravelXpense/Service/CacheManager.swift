//
//  CacheManager.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum CacheConfiguration {
    static let maxObjects = 100
    static let maxSize = 1024 * 1024 * 50
}

class CacheManager {
    static let shared: CacheManager = CacheManager()
    private static var cache: NSCache<NSString, AnyObject> = {
        let cache = NSCache<NSString, AnyObject>()
        cache.countLimit = CacheConfiguration.maxObjects
        cache.totalCostLimit = CacheConfiguration.maxSize
            return cache
        }()
    
    private init() { }
    
    func cache(object: AnyObject, key: String) { CacheManager.cache.setObject(object, forKey: key as NSString)
    }
    
    func getFromCache(key: String) -> AnyObject? {
        return CacheManager.cache.object(forKey: key as NSString)
    }
    
    func clearCache() {
        CacheManager.cache.removeAllObjects()
    }
}
