//
//  CategoryService.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/8.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

let defaultCategories = [
    (title: "Accommodation", colorCode: "2BA193", iconName: "hotel"),
    (title: "Air tickets", colorCode: "3A6B7E", iconName: "air-ticket"),
    (title: "Food & Drink", colorCode: "ECC06F", iconName: "pizza"),
    (title: "Shopping", colorCode: "E97C61", iconName: "shopping-bag"),
    (title: "Entertainment", colorCode: "937EB4", iconName: "snorkel"),
    (title: "Transport", colorCode: "79AECD", iconName: "train")
    ]

class CategoryService {
    
    static let shared = CategoryService()
    
    private init() {}
        
    var cache = [Int: Category]()
    
    var categories: [Category] {
        return getCategoryList()
    }
    
    func getAllCategoriesToCache() {
        let categories = DBManager.shared.getAllCategories()
        
        self.cache = categories.reduce(into: [:], { (result, category) in
            result[category.id] = category
        })
    }
    
    func addNewCategory(title: String, colorCode: String, iconName: String, completion: ((_ newCategory: Category) -> ())? = nil) {
        guard let newCategory = DBManager.shared.addNewCategory(title: title, colorCode: colorCode, iconName: iconName) else {
            return
        }
        
        // add category into cache
        self.cache[newCategory.id] = newCategory

        completion?(newCategory)
    }
    
    func getCategoryFromCache(by id: Int) -> Category? {
        return self.cache[id]
    }
    
    /// First time to launch the app.
    func setDefaultCategories() {
        self.getAllCategoriesToCache()
        
        guard self.categories.count == 0 else {
            return
        }
        
        for cate in defaultCategories {
            if let newCate = DBManager.shared.addNewCategory(title: cate.title, colorCode: cate.colorCode, iconName: cate.iconName) {
                self.cache[newCate.id] = newCate
            }
        }
        // get data to chahe
        self.getAllCategoriesToCache()
    }
    
    private func getCategoryList() -> [Category] {
        let orderd = cache.sorted { first, second in
            return first.0 < second.0
        }
        
        let list = orderd.reduce(into: [Category]()) { (result, dict) in
            result.append(dict.value)
        }
        return list
    }
}
