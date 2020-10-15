//
//  CategoryService.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/8.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

let defaultCategories = [(title: "Accommodation", colorCode: "2BA193", iconName: "hotel"),
                         (title: "Air tickets", colorCode: "335F70", iconName: "air-ticket"),
                         (title: "Food & Drink", colorCode: "ECC06F", iconName: "pizza"),
                         (title: "Shopping", colorCode: "E97C61", iconName: "shopping-bag"),
                         (title: "Entertainment", colorCode: "937EB4", iconName: "snorkel"),
                         (title: "Transport", colorCode: "79AECD", iconName: "train")]

class CategoryService {
    
    static let shared = CategoryService()
    
    private init() {}
        
    var cache = [Int: Category]()
    
    var categories = [Category]()
    
    func getAllCategoriesToCache() {
        self.categories = DBManager.shared.getAllCategories()
        
        self.cache = self.categories.reduce(into: [:], { (result, category) in
            result[category.id] = category
        })
    }
    
    func addNewCategory(title: String, colorCode: String, iconName: String, completion: ((_ newCategory: Category) -> ())? = nil) {
        guard let newCategory = DBManager.shared.addNewCategory(title: title, colorCode: colorCode, iconName: iconName) else {
            return
        }
        
        // add category into cache
        self.cache[newCategory.id] = newCategory
        
        // add book into category list
        self.categories.append(newCategory)
        
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
                self.categories += [newCate]
            }
            
        }
    }
}
