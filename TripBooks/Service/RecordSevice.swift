//
//  RecordSevice.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/15.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class RecordSevice {
    
    static let shared = RecordSevice()
    
    private init() {}
    
//    var cache = [Int: Book]()
    
    // order by start date
//    var orderdBookList = [Book]()
    
    var cache = [Int: Record]()
    
    var records = [Record]()

    func getAllRecordsToCache() {
        self.records = DBManager.shared.getAllRecords()
    }
    
    func addNewBook(title: String?, amount: Double, note: String?, date: Double, bookId: Int, categoryId: Int, accountId: Int, completion: @escaping (_ newRecord: Record) -> ()) {
 
        // add new book to DB (if insert succeed, newBook not nil)
        guard let newRecord = DBManager.shared.addNewRecord(title: title ?? "", amount: amount, note: note ?? "", date: date, bookId: bookId, categoryId: categoryId, accountId: accountId) else {
            return
        }
        
        // add record into cache
        self.cache[newRecord.id] = newRecord
        
        // add record into record list
        self.records.append(newRecord)
                
        completion(newRecord)
    }
    /*
    
    
    func updateBook(bookName: String, country: String, coverImageNo: Int? = nil, startDate: Double, endDate: Double, bookId: Int, completion: @escaping (_ targetBook: Book) -> ()) {
        
        // update book in DB (if update succeed, return a not nil book)
        guard let targetBook = DBManager.shared.updateBook(bookName: bookName, country: country, startDate: startDate, endDate: endDate, bookId: bookId) else {
            return
        }
        
        // update book in cache
        self.cache[targetBook.id] = targetBook
        
        // update book in booklist
        var needToSort = false
        for (index, book) in self.orderdBookList.enumerated() {
            if book.id == targetBook.id {
                needToSort = book.startDate != targetBook.startDate
                self.orderdBookList[index] = targetBook
                break
            }
        }
        
        if needToSort {
            self.orderdBookList.sort(by: {$0.startDate > $1.startDate})
        }
        
        completion(targetBook)
    }
    
    func deleteBook(bookId: Int, completion: @escaping () -> ()) {
        DBManager.shared.deleteBook(bookId: bookId)
        
        // delete book in cache
        self.cache.removeValue(forKey: bookId)
        
        // delete book in booklist
        for (index, book) in self.orderdBookList.enumerated() {
            if book.id == bookId {
                self.orderdBookList.remove(at: index)
                break
            }
        }
        
        completion()
    }
    */
}
