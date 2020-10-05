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
    static let coverImageNo = "book_coverImageNo"
    static let totalAmount = "book_totalAmount"
    static let book_budget = "book_budget"
    static let startDate = "book_startDate"
    static let daysInterval = "book_daysInterval"
    static let typeId = "book_type_id"
    static let createdDate = "book_createdDate"
}

enum RecordField {
    static let RECORD = "RECORD"
    static let id = "id"
    static let bookId = "record_book_id"
    static let title = "record_title"
    static let description = "record_description"
    static let dayNo = "record_dayNo"
    static let amount = "record_amount"
    static let categoryId = "record_category_id"
    static let accountId = "record_account_id"
    static let createdDate = "record_createdDate"
}

enum CategoryField {
    static let CATEGORY = "CATEGORY"
    static let id = "id"
    static let title = "category_title"
    static let colorCode = "category_colorCode"
    static let iconName = "category_iconName"
}


class DBManager: NSObject {
    
    static let shared = DBManager()
    
    var databaseFileName: String = "ACCOUNT_DATA.sqlite" // sqlite name
    var pathToDatabase: String = "" // sqlite path
    var database: FMDatabase! // FMDBConnection
    
    private override init() {
        super.init()
        
        // 取得sqlite在documents下的路徑(開啟連線用)
        self.pathToDatabase = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/" + self.databaseFileName
        
        print("filePath: \(self.pathToDatabase)")
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: Create Database
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
                    \(BookField.coverImageNo) integer,
                    \(BookField.totalAmount) Double DEFAULT 0,
                    \(BookField.book_budget) Double DEFAULT 0,
                    \(BookField.startDate) Double,
                    \(BookField.daysInterval) integer,
                    \(BookField.typeId) integer,
                    \(BookField.createdDate) Double NOT NULL);
                """
                
                let createRecordTableSQL = """
                    CREATE TABLE IF NOT EXISTS \(RecordField.RECORD) (
                    \(RecordField.id) integer NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 0,
                    \(RecordField.bookId) integer NOT NULL,
                    \(RecordField.title) Varchar(100),
                    \(RecordField.description) Varchar(100),
                    \(RecordField.dayNo) integer,
                    \(RecordField.amount) Double DEFAULT 0,
                    \(RecordField.categoryId) integer,
                    \(RecordField.accountId) integer,
                    \(RecordField.createdDate) Double NOT NULL);
                """
                let createCategoryTableSQL = """
                    CREATE TABLE IF NOT EXISTS \(CategoryField.CATEGORY) (
                    \(CategoryField.id) integer NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 0,
                    \(CategoryField.title) Varchar(50),
                    \(CategoryField.colorCode) char(7),
                    \(CategoryField.iconName) varchar(50));
                """
                
                self.database.executeStatements(createBookTableSQL + createRecordTableSQL + createCategoryTableSQL)
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
    
    // MARK: BOOK TABLE
    
    /// 新增一筆新的book
    /// - Parameters:
    ///   - bookName: 帳本名稱
    ///   - country: 國家
    ///   - coverImageNo: 封面圖片編號(cover_image_bk_id)，可為null
    ///   - startDate: 開始日期
    ///   - daysInterval: 旅遊天數 (結束-開始)
    ///   - createTime: 新增資料時間
    /// - Returns: 若新增成功回傳新的book，否則為nil
    func insertNewBook(bookName: String, country: String, coverImageNo: Int? = nil, startDateDouble: Double, daysInterval: Int, createTime: Double = Date().timeIntervalSince1970) -> Book? {
        var newBook: Book? = nil
        if self.openConnection() {
            let insertSQL: String = """
                        INSERT INTO \(BookField.BOOK) (
                        \(BookField.name),
                        \(BookField.country),
                        \(BookField.startDate),
                        \(BookField.daysInterval),
                        \(BookField.createdDate)) VALUES (?, ?, ?, ?, ?)
                        """
            if !self.database.executeUpdate(insertSQL, withArgumentsIn: [bookName, country, startDateDouble, daysInterval, createTime]) {
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
    func updateBook(bookName: String, country: String, coverImageNo: Int? = nil, startDate: Date, daysInterval: Int, bookId: Int) -> Book? {
        var book: Book? = nil
        
        if self.openConnection() {
            let updateSQL: String = "UPDATE \(BookField.BOOK) SET \(BookField.name) = ?, \(BookField.country) = ?, \(BookField.startDate) = ?, \(BookField.daysInterval) = ? WHERE \(BookField.id) = ?"

            do {
                try self.database.executeUpdate(updateSQL, values: [bookName, country, startDate, daysInterval, bookId])
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
    
    /// 取得所有book，排序由旅行開始時間新到舊
    /// ( order by createTime desc )
    /// - Returns: book array
    func getAllBooks() -> [Book] {
        var books: [Book] = []

        if self.openConnection() {
            let querySQL: String = "SELECT * FROM \(BookField.BOOK) ORDER BY \(BookField.startDate) DESC"

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
    
    
    // MARK: Record table
//    func insertNewRecord(withDepartmentChineseName departmentChineseName: String, departmentEnglishName: String) {
//
//        if self.openConnection() {
//            let insertSQL: String = "INSERT INTO DEPARTMENT (DEPARTMENT_ID, DEPT_CH_NM, DEPT_EN_NM) VALUES((SELECT IFNULL(MAX(DEPARTMENT_ID), 0) + 1 FROM DEPARTMENT), ?, ?)"
//
//            if !self.database.executeUpdate(insertSQL, withArgumentsIn: [departmentChineseName]) {
//                print("Failed to insert initial data into the database.")
//                print(database.lastError(), database.lastErrorMessage())
//            }
//
//            self.database.close()
//        }
//    }
//
//        /// 更新部門資料
//        ///
//        /// - Parameters:
//        ///   - departmentId: 部門ID
//        ///   - departmentEnglistName: 部門中文名稱
//        ///   - departmentChineseName: 部門英文名稱
//        func updateData(withDepartmentId departmentId: Int, departmentChineseName: String, departmentEnglistName: String) {
//            if self.openConnection() {
//                let updateSQL: String = "UPDATE DEPARTMENT SET DEPT_CH_NM = ?, DEPT_EN_NM = ? WHERE DEPARTMENT_ID = ?"
//
//                do {
//                    try self.database.executeUpdate(updateSQL, values: [departmentChineseName, departmentEnglistName, departmentId])
//                } catch {
//                    print(error.localizedDescription)
//                }
//
//                self.database.close()
//            }
//        }
        
//    /// 取得部門的所有資料
//    ///
//    /// - Returns: 部門資料
//    func queryData() -> [Department] {
//        var departmentDatas: [Department] = [Department]()
//
//        if self.openConnection() {
//            let querySQL: String = "SELECT * FROM DEPARTMENT"
//
//            do {
//                let dataLists: FMResultSet = try database.executeQuery(querySQL, values: nil)
//
//                while dataLists.next() {
//                    let department: Department = Department(departmentId: Int(dataLists.int(forColumn: "DEPARTMENT_ID")), departmentChNm: dataLists.string(forColumn: "DEPT_CH_NM")!, departmentEnNm: dataLists.string(forColumn: "DEPT_EN_NM")!)
//                    departmentDatas.append(department)
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//
//        return departmentDatas
//    }
        
//    /// 刪除部門資料
//    ///
//    /// - Parameter departmentId: 部門ID
//    func deleteData(withDepartmentId departmentId: Int) {
//        if self.openConnection() {
//            let deleteSQL: String = "DELETE FROM DEPARTMENT WHERE DEPARTMENT_ID = ?"
//
//            do {
//                try self.database.executeUpdate(deleteSQL, values: [departmentId])
//            } catch {
//                print(error.localizedDescription)
//            }
//
//            self.database.close()
//        }
//    }

}
