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
    (title: "Air tickets", colorCode: "9FC680", iconName: "air-ticket"),
    (title: "Food & Drink", colorCode: "ECC06F", iconName: "pizza"),
    (title: "Shopping", colorCode: "E97C61", iconName: "shopping-bag"),
    (title: "Entertainment", colorCode: "9E8BBB", iconName: "snorkel"),
    (title: "Transport", colorCode: "88B7D3", iconName: "train")
    ]

class CategoryService {
    
    static let shared = CategoryService()
    
    private init() {}
        
    var expenseCache = [Int: Category]()
        
    var expenseCategories: [Category] {
        return getCategoryList()
    }
    
    func getAllCategoriesToCache() {
        let categories = DBManager.shared.getAllCategories()
        
        self.expenseCache = categories.reduce(into: [:], { (result, category) in
            if category.isExpense {
                result[category.id] = category
            }
        })

        if self.expenseCache.count == 0 { // 理論上不會發生
            setDefaultCategories()
        }
            
            
    }
    
    func updateCategory(id: Int, title: String, colorCode: String, iconName: String) {
        guard let newCate = DBManager.shared.updateCategory(id: id, title: title, colorCode: colorCode, iconName: iconName) else {
            return
        }
        
        // update account in cache
        guard let oldCate = expenseCache[id] else {
            return
        }
        
        oldCate.title = newCate.title
        oldCate.colorHex = newCate.colorHex
        oldCate.iconImageName = newCate.iconImageName
    }
    
    func addNewCategory(title: String, colorCode: String, iconName: String, completion: ((_ newCategory: Category) -> ())? = nil) {
        guard let newCategory = DBManager.shared.addNewCategory(title: title, colorCode: colorCode, iconName: iconName) else {
            return
        }
        
        // add category into cache
        self.expenseCache[newCategory.id] = newCategory

        completion?(newCategory)
    }
    
    func deleteCategory(id: Int) {
        DBManager.shared.deleteCategory(id: id)
        RecordSevice.shared.deleteRecordsOfCategory(categoryId: id)
        expenseCache[id] = nil
    }
    
    func getCategoryFromCache(by id: Int) -> Category? {
        return self.expenseCache[id]
    }
    
    /// First time to launch the app.
    func setDefaultCategories() {
        guard self.expenseCategories.count == 0 else {
            return
        }
        
        for cate in defaultCategories {
            if let newCate = DBManager.shared.addNewCategory(title: cate.title, colorCode: cate.colorCode, iconName: cate.iconName) {
                self.expenseCache[newCate.id] = newCate
            }
        }
        // get data to chahe
        self.getAllCategoriesToCache()
    }
    
    private func getCategoryList() -> [Category] {
        let orderd = expenseCache.sorted { first, second in
            return first.0 < second.0
        }
        
        let list = orderd.reduce(into: [Category]()) { (result, dict) in
            result.append(dict.value)
        }
        return list
    }
}
