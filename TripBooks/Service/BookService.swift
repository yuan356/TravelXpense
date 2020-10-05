//
//  BookService.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/23.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class BookService {

    static let shared = BookService()
    
    private init() {}
    
    var cache = [Int: Book]()
    
    // order by start date
    var orderdBookList = [Book]()
    
    /// 載入所有帳本，並重設book cache & booklist
    func getAllBooksToCache() {
        self.orderdBookList = DBManager.shared.getAllBooks()
        
        self.cache = self.orderdBookList.reduce(into: [:], { (result, book) in
            result[book.id] = book
        })
    }
    
    func addNewBook(bookName: String, country: String, coverImageNo: Int? = nil, startDateDouble: Double, daysInterval: Int, createTime: Double = Date().timeIntervalSince1970,
                    completion: @escaping (_ newBook: Book) -> ()) {
        // add new book to DB (if insert succeed, newBook not nil)
        guard let newBook = DBManager.shared.insertNewBook(bookName: bookName, country: country, startDateDouble: startDateDouble, daysInterval: daysInterval) else {
            return
        }
        
        // add book into cache
        self.cache[newBook.id] = newBook
        
        // add book into booklist
        self.orderdBookList.append(newBook)
        
        // sort the booklist
        self.orderdBookList.sort(by: {$0.startDate > $1.startDate})
        
        completion(newBook)
    }
    
    func updateBook(bookName: String, country: String, coverImageNo: Int? = nil, startDate: Date, daysInterval: Int, bookId: Int, completion: @escaping (_ targetBook: Book) -> ()) {
        
        // update book in DB (if update succeed, return a not nil book)
        guard let targetBook = DBManager.shared.updateBook(bookName: bookName, country: country, startDate: startDate, daysInterval: daysInterval, bookId: bookId) else {
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
}
