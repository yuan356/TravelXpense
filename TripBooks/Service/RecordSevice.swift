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
    
    
    var num = 0
    private init() {}
    
    /** key: recordId, value: Record
     
     將所有record存進cache，以便日後使用。
     */
    var recordCache = [Int: Record]()
    
    /** key: bookId, value: [record] order by day
     
    將該Book中records依照日期依序行程array，以book id為key，做成dictionary。
     */
    var bookDaysRecordCache: [Int: [[Record]]] = [:]
    
    var dict: [Int: [[Int]]] = [0: [[1],[2]]]
    
    
    var tmpList: [Record] = []
    /**
    
     1.  從DB載入該Book所有Record，放入recordCache。
     2. 將records依日期組成array，放入bookDaysRecordCache。
     */
    func getAllRecordsFromCertainBook(bookId: Int) {
        let records = DBManager.shared.getAllRecordsFromBook(bookId)
        
        // add record to cache by key(recordId)
        self.recordCache = records.reduce(into: [:], { (result, record) in
            result[record.id] = record
        })
        
        var recordsList = [[Record]]()
        if let book = BookService.shared.getBookFromCache(bookId: bookId) {
            for i in (0..<book.days) {
                var dateRecords = [Record]()
                let date = TBFunc.getDateByOffset(startDate: book.startDate, daysInterval: i)
                for record in records {
                    if TBFunc.compareDateOnly(date1: record.date, date2: date!) {
                        dateRecords.append(record)
                    }
                }
                recordsList.append(dateRecords)
            }
        }
        bookDaysRecordCache[bookId] = recordsList
    }
    
    func addNewRecord(title: String?, amount: Double, note: String?, date: Double, bookId: Int, categoryId: Int, accountId: Int, completion: ((_ newRecord: Record) -> ())? = nil) {
 
        // add new book to DB (if insert succeed, newBook not nil)
        guard let newRecord = DBManager.shared.addNewRecord(title: title ?? "", amount: amount, note: note ?? "", date: date, bookId: bookId, categoryId: categoryId, accountId: accountId) else {
            return
        }
        // add record into cache
        self.recordCache[newRecord.id] = newRecord
        insertIntoDaysRecordCache(bookId: bookId, record: newRecord)
        
        completion?(newRecord)
    }
    
    func updateRecord(id: Int, title: String?, amount: Double, note: String?, date: Double, bookId: Int, categoryId: Int, accountId: Int, completion: ((_ newRecord: Record) -> ())? = nil) {
        
        let originalDate = self.recordCache[id]?.date
        
        // update record (if update succeed, return a record not nil)
        guard let newRecord = DBManager.shared.updateRecord(id: id, title: title ?? "", amount: amount, note: note ?? "", date: date, categoryId: categoryId, accountId: accountId) else {
            return
        }
        
        guard let oridate = originalDate else {
            return
        }
        
        // update record from cache
        if TBFunc.compareDateOnly(date1: oridate, date2: newRecord.date) {
            // in the same bookDayRecord
            if let rd = self.recordCache[newRecord.id] {
                rd.amount = newRecord.amount
                rd.title = newRecord.title
                rd.note = newRecord.note
                rd.date = newRecord.date
                rd.category = newRecord.category
                rd.account = newRecord.account
                rd.createTime = newRecord.createTime
            }
        } else {
            removeFromDaysRecordCache(bookId: bookId, originalDate: oridate, record: newRecord)
            insertIntoDaysRecordCache(bookId: bookId, record: newRecord)
        }
        
        completion?(newRecord)
    }
    
    private func insertIntoDaysRecordCache(bookId: Int, record: Record) {
        if let book = BookService.shared.getBookFromCache(bookId: bookId),
           let index = TBFunc.getDaysInterval(start: book.startDate, end: record.date),
           index >= 0 && index < book.days {
            bookDaysRecordCache[book.id]?[index].insert(record, at: 0)
        }
    }
    
    private func removeFromDaysRecordCache(bookId: Int, originalDate: Date, record: Record) {
        if let book = BookService.shared.getBookFromCache(bookId: bookId),
           let index = TBFunc.getDaysInterval(start: book.startDate, end: originalDate),
           index >= 0 && index < book.days,
           bookDaysRecordCache[book.id] != nil {
            for (i, rd) in bookDaysRecordCache[book.id]![index].enumerated() {
                if rd.id == record.id {
                    bookDaysRecordCache[book.id]![index].remove(at: i)
                    return
                }
            }
        }
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
