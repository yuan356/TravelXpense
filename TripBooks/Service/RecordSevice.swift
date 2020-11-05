//
//  RecordSevice.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/15.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

struct CategoryAmount {
    var category: Category
    var amount: Double
}

class RecordSevice {
    
    static let shared = RecordSevice()
    
    
    var num = 0
    private init() {}
    
    /** key: recordId, value: Record
     
     將所有record存進cache，以便日後使用。
     */
    var recordCache = [Int: Record]()
    
    /**  key: bookId, value: [record] order by day
     
    將該Book中records依照日期依序行程array，以book id為key，做成dictionary。
     */
    var bookDaysRecordCache: [Int: [[Record]]] = [:]
    
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
            guard book.days > 0 else { // 理論上不會發生, start >= end
                return
            }
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
    
    // MARK: addNewRecord
    func addNewRecord(title: String?, amount: Double, note: String?, date: Double, bookId: Int, categoryId: Int, accountId: Int, completion: ((_ newRecord: Record) -> ())? = nil) {
 
        // add new book to DB (if insert succeed, newBook not nil)
        guard let newRecord = DBManager.shared.addNewRecord(title: title ?? "", amount: amount, note: note ?? "", date: date, bookId: bookId, categoryId: categoryId, accountId: accountId) else {
            return
        }
        
        // add record into cache
        self.recordCache[newRecord.id] = newRecord
        insertIntoDaysRecordCache(bookId: bookId, record: newRecord)
        
        // update account amount
        AccountService.shared.updateAmount(accountId: accountId, value: amount)
        completion?(newRecord)
    }
    
    // MARK: updateRecord
    func updateRecord(id: Int, title: String?, amount: Double, note: String?, date: Double, bookId: Int, categoryId: Int, accountId: Int, completion: ((_ newRecord: Record) -> ())? = nil) {
        
        guard let oldRecord = self.recordCache[id] else {
            return
        }
        
        // update record (if update succeed, return a record not nil)
        guard let newRecord = DBManager.shared.updateRecord(id: id, title: title ?? "", amount: amount, note: note ?? "", date: date, categoryId: categoryId, accountId: accountId) else {
            return
        }
        
        // update record from cache
        if !TBFunc.compareDateOnly(date1: oldRecord.date, date2: newRecord.date) {
            // not in the same bookDayRecord
            removeFromDaysRecordCache(bookId: bookId, originalDate: oldRecord.date, record: newRecord)
            insertIntoDaysRecordCache(bookId: bookId, record: newRecord)
        }
        
        // changed account
        if oldRecord.account.id != newRecord.account.id {
            AccountService.shared.updateAmount(accountId: oldRecord.account.id, value: -oldRecord.amount)
            AccountService.shared.updateAmount(accountId: newRecord.account.id, value: newRecord.amount)
        } else {
            // update account amount
            let offset = newRecord.amount - oldRecord.amount
            AccountService.shared.updateAmount(accountId: accountId, value: offset)
        }
        
        // update record in cache
        oldRecord.amount = newRecord.amount
        oldRecord.title = newRecord.title
        oldRecord.note = newRecord.note
        oldRecord.date = newRecord.date
        oldRecord.category = newRecord.category
        oldRecord.account = newRecord.account
        oldRecord.createTime = newRecord.createTime

        completion?(newRecord)
    }
    
    func deleteRecordsOfAccounts(accountId: Int) {
        DBManager.shared.deleteRecordsOfAccount(accountId: accountId)
    }
    
    
    /// 刪除小於或大於該指定日期的record
    /// - Parameters:
    ///   - date: target date
    ///   - less: true 刪除小於該日期record，false 刪除大於該日期record。
    func deleteRecordsOfDate(date: Date, less: Bool) {
        var idList = [Int]()
        let compare: ComparisonResult = less ? .orderedAscending : .orderedDescending
        for record in self.recordCache.values {
            if TBFunc.compareDate(date: record.date, target: date) == compare {
                idList.append(record.id)
            }
        }
        
        for i in idList {
            print(i)
        }
    }
    
    func deleteRecordById(recordId: Int) {
        guard let oldRecord = recordCache[recordId] else {
            return
        }
        DBManager.shared.deleteRecord(recordId: recordId)
        
        
        AccountService.shared.updateAmount(accountId: oldRecord.account.id, value: -oldRecord.amount)
        removeFromDaysRecordCache(bookId: oldRecord.bookId, originalDate: oldRecord.date, record: oldRecord)
        recordCache[recordId] = nil
    }
    
    // MARK: RecordCache
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
    
    // MARK: orderByAmount
    // accountId == -1, all accounts
    func orderByAmount(accountId: Int, isExpense: Bool) -> ([CategoryAmount], Double) {
        var categoryDict: [Int: Double] = [:]
        var total: Double = 0
        
        for cate in CategoryService.shared.categories {
            categoryDict[cate.id] = 0
        }
        
        for record in recordCache.values {
            if accountId == -1, // for all accounts
               record.category.isExpense == isExpense {
                categoryDict[record.category.id]? += record.amount
                total += record.amount
            }
            else if record.account.id == accountId,
               record.category.isExpense == isExpense {
                categoryDict[record.category.id]? += record.amount
                total += record.amount
            }
        }
     
        let sortedByValueDictionary = categoryDict.sorted { first, second in
            return first.1 < second.1 // 由小到大排序
        }
        let result = sortedByValueDictionary.reduce(into: [CategoryAmount]()) { (result, dict) in
            if let cate = CategoryService.shared.getCategoryFromCache(by: dict.key) {
                result.append(CategoryAmount(category: cate, amount: dict.value))
            }
        }
        return (result, total)
    }
    
    /*
    
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
