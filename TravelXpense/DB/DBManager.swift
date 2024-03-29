//
//  DBManager.swift
//  TripBooks
//
//  Created by yuan on 2020/9/22.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import FMDB

enum BookField {
    static let BOOK = "BOOK"
    static let id = "id"
    static let name = "book_name"
    static let country = "book_countryCode"
    static let currency = "book_currency"
    static let imageUrl = "book_imageUrl"
    static let totalAmount = "book_totalAmount"
    static let startDate = "book_startDate"
    static let endDate = "book_endDate"
    static let typeId = "book_type_id"
    static let createdDate = "book_createdDate"
}

enum BookFieldForUpdate {
    case name
    case country
    case currency
    case startDate
    case endDate
    case imageUrl
}

enum BookOrder {
    case startDate
    case createdDate
}

enum RecordField {
    static let RECORD = "RECORD"
    static let id = "id"
    static let bookId = "record_book_id"
    static let amount = "record_amount"
    static let title = "record_title"
    static let note = "record_note"
    static let date = "record_date"
    static let categoryId = "record_category_id"
    static let accountId = "record_account_id"
    static let createdDate = "record_createdDate"
}

enum CategoryField {
    static let CATEGORY = "CATEGORY"
    static let id = "id"
    static let title = "category_title"
    static let isExpense = "category_isExpense"
    static let colorHex = "category_colorHex"
    static let iconImageName = "category_iconImageName"
}

enum AccountField {
    static let ACCOUNT = "ACCOUNT"
    static let id = "id"
    static let bookId = "account_book_id"
    static let budget = "account_budget"
    static let name = "account_name"
    static let amount = "account_amount"
    static let iconImageName = "account_iconImageName"
}

class DBManager: NSObject {
    
    static let shared = DBManager()
    
    var databaseFileName: String = "ACCOUNT_DATA.sqlite" // sqlite name
    var pathToDocument: String = ""
    var pathToDatabase: String = "" // sqlite path
    var database: FMDatabase! // FMDBConnection
    
    private override init() {
        super.init()
        
        // 取得sqlite在documents下的路徑(開啟連線用)
        self.pathToDocument = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        self.pathToDatabase = pathToDocument + "/" + self.databaseFileName
        
        print("filePath: \(self.pathToDatabase)")
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Create Database
    /// 生成 .sqlite 檔案並創建表格，只有在 .sqlite 不存在時才會建立
    func createTable() {
        let fileManager: FileManager = FileManager.default
        
        // 判斷documents是否已存在該檔案
        if !fileManager.fileExists(atPath: self.pathToDatabase) {
            
            // 開啟連線
            if self.openConnection() {
                let createBookTableSQL = """
                    CREATE TABLE IF NOT EXISTS \(BookField.BOOK) (
                    \(BookField.id) integer NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 0,
                    \(BookField.name) Varchar(100),
                    \(BookField.country) char(2),
                    \(BookField.currency) char(3),
                    \(BookField.imageUrl) Varchar(1000),
                    \(BookField.totalAmount) Double DEFAULT 0,
                    \(BookField.startDate) Double,
                    \(BookField.endDate) Double,
                    \(BookField.typeId) integer DEFAULT 0,
                    \(BookField.createdDate) Double NOT NULL);
                """
                
                let createRecordTableSQL = """
                    CREATE TABLE IF NOT EXISTS \(RecordField.RECORD) (
                    \(RecordField.id) integer NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 0,
                    \(RecordField.bookId) integer NOT NULL,
                    \(RecordField.amount) Double DEFAULT 0,
                    \(RecordField.title) Varchar(150),
                    \(RecordField.note) Varchar(550),
                    \(RecordField.date) Double,
                    \(RecordField.categoryId) integer,
                    \(RecordField.accountId) integer,
                    \(RecordField.createdDate) Double NOT NULL);
                """
                let createCategoryTableSQL = """
                    CREATE TABLE IF NOT EXISTS \(CategoryField.CATEGORY) (
                    \(CategoryField.id) integer NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 0,
                    \(CategoryField.title) Varchar(150),
                    \(CategoryField.isExpense) Boolean DEFAULT 1,
                    \(CategoryField.colorHex) char(6),
                    \(CategoryField.iconImageName) varchar(50));
                """
                
                let createAccountTableSQL = """
                    CREATE TABLE IF NOT EXISTS \(AccountField.ACCOUNT) (
                    \(AccountField.id) integer NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 0,
                    \(AccountField.bookId) integer NOT NULL,
                    \(AccountField.name) Varchar(150),
                    \(AccountField.budget) Double DEFAULT 0,
                    \(AccountField.amount) Double DEFAULT 0,
                    \(AccountField.iconImageName) varchar(50));
                """
                
                self.database.executeStatements(createBookTableSQL + createRecordTableSQL + createCategoryTableSQL + createAccountTableSQL)
                print("file copy to: \(self.pathToDatabase)")
            }
        } else {
            print("Datebase allready exists.")
            //print("DID-NOT copy db file, file allready exists at path:\(self.pathToDatabase)")
        }
    }
    
    /// 取得 .sqlite 連線
    /// - Returns: Bool
    func openConnection() -> Bool {
        var isOpen: Bool = false
        
        self.database = FMDatabase(path: self.pathToDatabase)
        
        if self.database != nil {
            if self.database.open() {
                isOpen = true
            } else {
                print("Could not get the connection.")
            }
        }
        
        return isOpen
    }
    
    // MARK: - BOOK
    
    /// 新增一筆新的book
    /// - Parameters:
    ///   - bookName: 帳本名稱
    ///   - country: 國家
    ///   - currency: 貨幣
    ///   - coverImageNo: 封面圖片編號(cover_image_bk_id)，可為null
    ///   - startDate: 開始日期
    ///   - daysInterval: 旅遊天數 (結束-開始)
    ///   - createTime: 新增資料時間
    /// - Returns: 若新增成功回傳新的book，否則為nil
    func insertNewBook(bookName: String, country: String, currency: String, imageUrl: String?, startDate: Double, endDate: Double, createTime: Double = Date().timeIntervalSince1970) -> Book? {
        var newBook: Book? = nil
        if self.openConnection() {
            let insertSQL: String = """
                        INSERT INTO \(BookField.BOOK) (
                        \(BookField.name),
                        \(BookField.country),
                        \(BookField.currency),
                        \(BookField.imageUrl),
                        \(BookField.startDate),
                        \(BookField.endDate),
                        \(BookField.createdDate)) VALUES (?, ?, ?, ?, ?, ?, ?)
                        """
            if !self.database.executeUpdate(insertSQL, withArgumentsIn: [bookName, country, currency, imageUrl ?? NSNull() , startDate, endDate, createTime]) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            
            let newId = Int(self.database.lastInsertRowId)
            newBook = self.getBookById(newId)
            self.database.close()
        }
        return newBook
    }

    func addTestNewBook(id: Int, bookName: String, country: String, currency: String, imageUrl: String?, startDate: Double, endDate: Double, createTime: Double = Date().timeIntervalSince1970) -> Book? {
        var newBook: Book? = nil
        if self.openConnection() {
            let insertSQL: String = """
                        INSERT INTO \(BookField.BOOK) (
                        \(BookField.id),
                        \(BookField.name),
                        \(BookField.country),
                        \(BookField.currency),
                        \(BookField.imageUrl),
                        \(BookField.startDate),
                        \(BookField.endDate),
                        \(BookField.createdDate)) VALUES (? ,?, ?, ?, ?, ?, ?, ?)
                        """
            if !self.database.executeUpdate(insertSQL, withArgumentsIn: [id, bookName, country, currency, imageUrl ?? NSNull() , startDate, endDate, createTime]) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            
            let newId = Int(self.database.lastInsertRowId)
            newBook = self.getBookById(newId)
            self.database.close()
        }
        return newBook
    }
    

    /// 更新指定Book內容
    /// - Parameters:
    ///   - bookName: 帳本名稱
    ///   - country: 國家
    ///   - coverImageNo: 封面圖片編號(cover_image_bk_id)
    ///   - startDate: 開始日期
    ///   - daysInterval: 旅遊天數 (結束-開始)
    ///   - bookId: 帳本編號
    /// - Returns: 若更新成功回傳該book，否則為nil
    func updateBook(bookId: Int, bookName: String, country: String, coverImageNo: Int? = nil, startDate: Double, endDate: Double) -> Book? {
        var book: Book? = nil
        
        if self.openConnection() {
            
            let updateSQL: String = "UPDATE \(BookField.BOOK) SET \(BookField.name) = ?, \(BookField.country) = ?, \(BookField.startDate) = ?, \(BookField.endDate) = ? WHERE \(BookField.id) = ?"

            do {
                try self.database.executeUpdate(updateSQL, values: [bookName, country, startDate, endDate])
                book = self.getBookById(bookId)
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        
        return book
    }
    
    func updateBook(bookId: Int, field: BookFieldForUpdate, value: NSObject) -> Book? {
        var book: Book? = nil
        var updateSQL = "UPDATE \(BookField.BOOK) SET "
        switch field {
        case .name:
            updateSQL += "\(BookField.name) = ?"
        case .country:
            updateSQL += "\(BookField.country) = ?"
        case .currency:
            updateSQL += "\(BookField.currency) = ?"
        case .startDate:
            updateSQL += "\(BookField.startDate) = ?"
        case .endDate:
            updateSQL += "\(BookField.endDate) = ?"
        case .imageUrl:
            updateSQL += "\(BookField.imageUrl) = ?"
        }
        
        updateSQL += " WHERE \(BookField.id) = ?"
        if self.openConnection() {
            do {
                try self.database.executeUpdate(updateSQL, values: [value, bookId])
                book = self.getBookById(bookId)
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        
        return book
    }
    
    
    /// 刪除指定帳本
    /// - Parameter bookId: 帳本編號
    func deleteBook(bookId: Int) {
        if self.openConnection() {
            let deleteSQL: String = "DELETE FROM \(BookField.BOOK) WHERE \(BookField.id) = ?"
            do {
                try self.database.executeUpdate(deleteSQL, values: [bookId])
            } catch {
                print(error.localizedDescription)
            }
            
            self.database.close()
        }
    }
    
    
    /// 取得指定帳本
    /// - Parameter bookId: 帳本編號
    /// - Returns: 若帳本存在回傳Book，否則為nil
    func getBookById(_ bookId: Int) -> Book? {
        var book: Book? = nil
        if self.openConnection() {
            let getBookSQL = "SELECT * FROM \(BookField.BOOK) WHERE \(BookField.id) = ?"
            do {
                let dataLists: FMResultSet = try database.executeQuery(getBookSQL, values: [bookId])
                
                if dataLists.next() {
                    book = Book.getBookByFMDBdata(FMDBdatalist: dataLists)
                }
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        
        return book
    }
    
    func getAllBooks(order: BookOrder) -> [Book] {
        var books: [Book] = []

        if self.openConnection() {
            var querySQL: String = "SELECT * FROM \(BookField.BOOK) ORDER BY "
            
            switch order {
            case .startDate:
                querySQL += "\(BookField.startDate) DESC"
            case .createdDate:
                querySQL += "\(BookField.createdDate) DESC"
            }

            do {
                let dataLists: FMResultSet = try database.executeQuery(querySQL, values: nil)

                var book: Book?
                while dataLists.next() {
                    book = Book.getBookByFMDBdata(FMDBdatalist: dataLists)
                    if let book = book {
                        books.append(book)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        return books
    }
    
   
    
    // MARK: - RECORD
    func addNewRecord(title: String, amount: Double, note: String, date: Double, bookId: Int, categoryId: Int, accountId: Int, createTime: Double = Date().timeIntervalSince1970) -> Record? {
        var newRecord: Record? = nil
        if self.openConnection() {
            let insertSQL: String = """
                        INSERT INTO \(RecordField.RECORD) (
                        \(RecordField.bookId),
                        \(RecordField.amount),
                        \(RecordField.title),
                        \(RecordField.note),
                        \(RecordField.date),
                        \(RecordField.categoryId),
                        \(RecordField.accountId),
                        \(RecordField.createdDate)) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                        """
            if !self.database.executeUpdate(insertSQL, withArgumentsIn: [bookId, amount, title, note, date, categoryId, accountId, createTime]) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            
            let newId = Int(self.database.lastInsertRowId)
            newRecord = self.getRecordById(newId)
            self.database.close()
        }
        return newRecord
    }
    
    func updateRecord(id: Int, title: String, amount: Double, note: String, date: Double, categoryId: Int, accountId: Int, createTime: Double = Date().timeIntervalSince1970) -> Record? {
        var record: Record? = nil
        
        if self.openConnection() {
            let updateSQL: String = "UPDATE \(RecordField.RECORD) SET \(RecordField.amount) = ?, \(RecordField.title) = ?, \(RecordField.note) = ?, \(RecordField.date) = ?, \(RecordField.categoryId) = ?, \(RecordField.accountId) = ? WHERE \(RecordField.id) = ?"

            do {
                try self.database.executeUpdate(updateSQL, values: [amount, title, note, date, categoryId, accountId, id])
                record = self.getRecordById(id)
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        
        return record
    }
    
    func deleteRecordById(recordId: Int) {
        if self.openConnection() {
            let deleteSQL: String = "DELETE FROM \(RecordField.RECORD) WHERE \(RecordField.id) = ?"
            do {
                try self.database.executeUpdate(deleteSQL, values: [recordId])
            } catch {
                print(error.localizedDescription)
            }
            
            self.database.close()
        }
    }
    
    func deleteRecordById(recordId: [Int]) {
        var marks: String = ""
        for _ in 0..<recordId.count {
            marks += "?,"
        }
        if marks.count > 0 {
            marks.removeLast()
        }
        
        if self.openConnection() {
            let deleteSQL: String = "DELETE FROM \(RecordField.RECORD) WHERE \(RecordField.id) in (\(marks))"
            do {
                try self.database.executeUpdate(deleteSQL, values: recordId)
            } catch {
                print(error.localizedDescription)
            }
            
            self.database.close()
        }
    }
    
    func deleteRecordsOfCategory(categoryId: Int) {
        if self.openConnection() {
            let deleteSQL: String = "DELETE FROM \(RecordField.RECORD) WHERE \(RecordField.categoryId) = ?"
            do {
                try self.database.executeUpdate(deleteSQL, values: [categoryId])
            } catch {
                print(error.localizedDescription)
            }
            
            self.database.close()
        }
    }
    
    func deleteRecordsOfAccount(accountId: Int) {
        if self.openConnection() {
            let deleteSQL: String = "DELETE FROM \(RecordField.RECORD) WHERE \(RecordField.accountId) = ?"
            do {
                try self.database.executeUpdate(deleteSQL, values: [accountId])
            } catch {
                print(error.localizedDescription)
            }
            
            self.database.close()
        }
    }
    
    func deleteRecordsOfBook(bookId: Int) {
        if self.openConnection() {
            let deleteSQL: String = "DELETE FROM \(RecordField.RECORD) WHERE \(RecordField.bookId) = ?"
            do {
                try self.database.executeUpdate(deleteSQL, values: [bookId])
            } catch {
                print(error.localizedDescription)
            }
            
            self.database.close()
        }
    }
    
    func getAllRecords() -> [Record] {
        var records: [Record] = []

        if self.openConnection() {
            let querySQL: String = "SELECT * FROM \(RecordField.RECORD) ORDER BY \(RecordField.date) DESC"

            do {
                let dataLists: FMResultSet = try database.executeQuery(querySQL, values: nil)

                var record: Record?
                while dataLists.next() {
                    record = Record.getRecordByFMDBdata(FMDBdatalist: dataLists)
                    if let record = record {
                        records.append(record)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        return records
    }
    
    func getCountFromCategory(categoryId: Int) -> Int {
        var count = 0
        if self.openConnection() {
            //select Count(id) from RECORD where record_category_id = 7
            let getCateSQL = "SELECT Count(\(RecordField.id)) count FROM  \(RecordField.RECORD) WHERE \(RecordField.categoryId) = ?"
            do {
                let dataLists: FMResultSet = try database.executeQuery(getCateSQL, values: [categoryId])
                
                if dataLists.next() {
                    count = Int(dataLists.int(forColumn: "count"))
                }
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        return count
    }
    
    /// 回傳指定帳本(book)內所有紀錄(record), createdDate (DESC)
    /// - Parameter bookId: 帳本id
    /// - Returns: [record]
    func getAllRecordsFromBook(_ bookId: Int) -> [Record] {
        var records: [Record] = []

        if self.openConnection() {
            let querySQL: String = "SELECT * FROM \(RecordField.RECORD) WHERE \(RecordField.bookId) = ?  ORDER BY \(RecordField.createdDate) DESC"

            do {
                let dataLists: FMResultSet = try database.executeQuery(querySQL, values: [bookId])

                var record: Record?
                while dataLists.next() {
                    record = Record.getRecordByFMDBdata(FMDBdatalist: dataLists)
                    if let record = record {
                        records.append(record)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        return records
    }
    
    func getRecordById(_ recordId: Int) -> Record? {
        var record: Record? = nil
        if self.openConnection() {
            let getBookSQL = "SELECT * FROM \(RecordField.RECORD) WHERE \(RecordField.id) = ?"
            do {
                let dataLists: FMResultSet = try database.executeQuery(getBookSQL, values: [recordId])
                
                if dataLists.next() {
                    record = Record.getRecordByFMDBdata(FMDBdatalist: dataLists)
                }
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        
        return record
    }
    
    
    // MARK: - CATEGORY
    func addNewCategory(title: String, colorCode: String, iconName: String) -> Category? {
        var newCategory: Category? = nil
        if self.openConnection() {
            let insertSQL: String = """
                        INSERT INTO \(CategoryField.CATEGORY) (
                        \(CategoryField.title),
                        \(CategoryField.colorHex),
                        \(CategoryField.iconImageName)) VALUES (?, ?, ?)
                        """
            if !self.database.executeUpdate(insertSQL, withArgumentsIn: [title, colorCode, iconName]) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            
            let newId = Int(self.database.lastInsertRowId)
            newCategory = self.getCategoryById(newId)
            self.database.close()
        }
        return newCategory
    }
    
    func updateCategory(id: Int, title: String, colorCode: String, iconName: String) -> Category? {
        var category: Category? = nil
        
        if self.openConnection() {
            let updateSQL: String = "UPDATE \(CategoryField.CATEGORY) SET \(CategoryField.title) = ?, \(CategoryField.colorHex) = ?, \(CategoryField.iconImageName) = ? WHERE \(CategoryField.id) = ?"

            do {
                try self.database.executeUpdate(updateSQL, values: [title, colorCode, iconName, id])
                category = self.getCategoryById(id)
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        
        return category
    }
    
    func getAllCategories() -> [Category] {
        var categories: [Category] = []

        if self.openConnection() {
            let querySQL: String = "SELECT * FROM \(CategoryField.CATEGORY) ORDER BY \(CategoryField.id)"

            do {
                let dataLists: FMResultSet = try database.executeQuery(querySQL, values: nil)

                var category: Category?
                while dataLists.next() {
                    category = Category.getCategoryByFMDBdata(FMDBdatalist: dataLists)
                    if let category = category {
                        categories.append(category)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        return categories
    }
    
    func getCategoryById(_ id: Int) -> Category? {
        var category: Category? = nil
        if self.openConnection() {
            let getCateSQL = "SELECT * FROM \(CategoryField.CATEGORY) WHERE \(CategoryField.id) = ?"
            do {
                let dataLists: FMResultSet = try database.executeQuery(getCateSQL, values: [id])
                
                if dataLists.next() {
                    category = Category.getCategoryByFMDBdata(FMDBdatalist: dataLists)
                }
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        
        return category
    }
    
    func deleteCategory(id: Int) {
        if self.openConnection() {
            let deleteSQL: String = "DELETE FROM \(CategoryField.CATEGORY) WHERE \(CategoryField.id) = ?"
            do {
                try self.database.executeUpdate(deleteSQL, values: [id])
            } catch {
                print(error.localizedDescription)
            }
            
            self.database.close()
        }
    }
    
    
    // MARK: - ACCOUNT
    func addNewAccount(bookId: Int, name: String, budget: Double = 0, iconName: String) -> Account? {
        var newAccount: Account? = nil
        if self.openConnection() {
            let insertSQL: String = """
                        INSERT INTO \(AccountField.ACCOUNT) (
                        \(AccountField.bookId),
                        \(AccountField.name),
                        \(AccountField.budget),
                        \(AccountField.iconImageName)) VALUES (?, ?, ?, ?)
                        """
            if !self.database.executeUpdate(insertSQL, withArgumentsIn: [bookId, name, budget, iconName]) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            
            let newId = Int(self.database.lastInsertRowId)
            newAccount = self.getAccountById(newId)
            self.database.close()
        }
        return newAccount
    }
    
    
    func updateAccount(accountId: Int, name: String, budget: Double, iconName: String) -> Account? {
        var account: Account? = nil
        let updateSQL = """
                UPDATE \(AccountField.ACCOUNT) SET
                \(AccountField.name) = ?,
                \(AccountField.budget) = ?,
                \(AccountField.iconImageName) = ?
                WHERE \(AccountField.id) = ?
                """
        if self.openConnection() {
            do {
                try self.database.executeUpdate(updateSQL, values: [name, budget, iconName, accountId])
                account = self.getAccountById(accountId)
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        
        return account
    }
    
    func deleteAccount(accountId: Int) {
        if self.openConnection() {
            let deleteSQL: String = "DELETE FROM \(AccountField.ACCOUNT) WHERE \(AccountField.id) = ?"
            do {
                try self.database.executeUpdate(deleteSQL, values: [accountId])
            } catch {
                print(error.localizedDescription)
            }
            
            self.database.close()
        }
    }
    
    func getAllAccountsFromBook(bookId: Int) -> [Account] {
        var accounts: [Account] = []

        if self.openConnection() {
            let querySQL: String = "SELECT * FROM \(AccountField.ACCOUNT) WHERE \(AccountField.bookId) = ? ORDER BY \(AccountField.id)"

            do {
                let dataLists: FMResultSet = try database.executeQuery(querySQL, values: [bookId])

                var account: Account?
                while dataLists.next() {
                    account = Account.getAccountByFMDBdata(FMDBdatalist: dataLists)
                    if let account = account {
                        accounts.append(account)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        return accounts
    }
    
    func getAccountById(_ id: Int) -> Account? {
        var account: Account? = nil
        if self.openConnection() {
            let getCateSQL = "SELECT * FROM \(AccountField.ACCOUNT) WHERE \(AccountField.id) = ?"
            do {
                let dataLists: FMResultSet = try database.executeQuery(getCateSQL, values: [id])
                
                if dataLists.next() {
                    account = Account.getAccountByFMDBdata(FMDBdatalist: dataLists)
                }
            } catch {
                print(error.localizedDescription)
            }
            self.database.close()
        }
        
        return account
    }
    
    
    
}
