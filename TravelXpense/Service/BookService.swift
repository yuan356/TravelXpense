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
    
    var currentOpenBook: Book!
    
    var cache = [Int: Book]()
    
    var bookList = [Book]()
    
    /// 載入所有帳本，並重設book cache & booklist
    // store cover image to cache
    func getAllBooksToCache() {
        self.bookList = DBManager.shared.getAllBooks(order: .createdDate)
        
        self.cache = self.bookList.reduce(into: [:], { (result, book) in
            result[book.id] = book
            ImageService.initRetrieveImageForBook(bookId: book.id)
        })
    }
    
    func addNewBook(bookName: String, country: String, currency: String, imageUrl: String?, image: UIImage?, startDate: Double, endDate: Double,
                    completion: @escaping (_ newBook: Book) -> ()) {
        
        // add new book to DB (if insert succeed, newBook not nil)
        guard let newBook = DBManager.shared.insertNewBook(bookName: bookName, country: country, currency: currency, imageUrl: imageUrl, startDate: startDate, endDate: endDate) else {
            return
        }
        
        if let image = image {
            ImageService.storeToLocal(image: image, bookId: newBook.id)
        }
        
        // add book into cache
        self.cache[newBook.id] = newBook
        
        // add book into booklist
        self.bookList.insert(newBook, at: 0)
//        self.bookList.append(newBook)
        
        // sort the booklist
//        self.bookList.sort(by: {$0.startDate > $1.startDate})
        
        // add a default account for book
        AccountService.shared.insertDefaultAccounts(bookId: newBook.id)
        
        completion(newBook)
    }
    
    func updateBook(bookId: Int, field: BookFieldForUpdate, value: NSObject) {
        guard let newBook = DBManager.shared.updateBook(bookId: bookId, field: field, value: value) else {
            return
        }
        
        // update book in cache
        guard let oldBook = cache[bookId] else {
            return
        }
        
        let startDateCompare = TXFunc.compareDate(date: newBook.startDate, target: oldBook.startDate)
        let endDateCompare = TXFunc.compareDate(date: newBook.endDate, target: oldBook.endDate)
        if startDateCompare == .orderedDescending {
            // delete records that date is less than newBook.startDate
            RecordSevice.shared.deleteRecordsOfDate(date: newBook.startDate, less: true)
        }
        if endDateCompare == .orderedAscending {
            // delete records that date is greater than newBook.endDate
            RecordSevice.shared.deleteRecordsOfDate(date: newBook.endDate, less: false)
        }
        
//        let needReorder = oldBook.startDate != newBook.startDate
        
        switch field {
        case .name:
            oldBook.name = newBook.name
        case .country:
            oldBook.country = newBook.country
        case .currency:
            oldBook.currency = newBook.currency
        case .startDate:
            oldBook.startDate = newBook.startDate
            if let daysInterval = TXFunc.getDaysInterval(start: oldBook.startDate, end: oldBook.endDate) {
                oldBook.days = daysInterval + 1
            }
        case .endDate:
            oldBook.endDate = newBook.endDate
            if let daysInterval = TXFunc.getDaysInterval(start: oldBook.startDate, end: oldBook.endDate) {
                oldBook.days = daysInterval + 1
            }
        case .imageUrl:
            oldBook.imageUrl = newBook.imageUrl
        }
        

        // update order (start day) 原本以開始日期排序，改為新增時間排序，先註解，
//        if needReorder {
//            self.bookList.sort(by: {$0.startDate > $1.startDate})
//        }
    }

    
    func deleteBook(bookId: Int, completion: @escaping () -> ()) {
        DBManager.shared.deleteBook(bookId: bookId)
        RecordSevice.shared.deleteRecordsOfBook(bookId: bookId)
        
        // delete book in cache
        self.cache.removeValue(forKey: bookId)
        
        // delete book in booklist
        for (index, book) in self.bookList.enumerated() {
            if book.id == bookId {
                self.bookList.remove(at: index)
                break
            }
        }
        completion()
    }
    
    func getBookFromCache(bookId: Int) -> Book? {
        return self.cache[bookId]
    }
}
