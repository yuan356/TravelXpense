//
//  FirebaseService.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

enum backupLogField {
    static let backupUrl = "backupUrl"
    static let timestamp = "timestamp"
}

struct BackupLog {
    var url: String
    var date: Date
}

class BackupService {
    
    static let shared = BackupService()
    
    var backupTimestamp: Double?
    
    private init() { }
    
//    // MARK: - Firebase Database 參照
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    let BACKUPLOG_DB_REF: DatabaseReference = Database.database().reference().child("BackupLog")
    
    // MARK: - Firebase Storage 參照
    let DBFILE_STORAGE_REF: StorageReference = Storage.storage().reference().child("DBfile")
    let COVER_STORAGE_REF: StorageReference = Storage.storage().reference().child("Cover")
    
    func initSetting() {
        guard AuthService.currentUser != nil else {
            return
        }
        
        let time = UserDefaults.standard.double(forKey: UserDefaultsKey.backupTime.rawValue)
        self.backupTimestamp = time
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.autoBackup.rawValue) {
            self.checkAutoBackup()
        }
    }
    
    func backupSQLite(completion: ((_ result: CompletionResult)->())? = nil) {
        // 確保已登入
        guard let uid = AuthService.currentUser?.uid else {
            completion?(.failed)
            return
        }
        
        backupImage()
        let backupLogRef = BACKUPLOG_DB_REF.child(uid)

        let dbFileUrl = URL(fileURLWithPath: DBManager.shared.pathToDatabase)
        let storgeRef = DBFILE_STORAGE_REF.child("\(uid).sqlite")
        
        let uploadTask = storgeRef.putFile(from: dbFileUrl, metadata: nil)
        uploadTask.observe(.success) { (snapshot) in
            snapshot.reference.downloadURL { (url, error) in
                guard let url = url else { return }
                
                let date = Date()
                let timestamp = date.timeIntervalSince1970
                UserDefaults.standard.set(timestamp, forKey: UserDefaultsKey.backupTime.rawValue)
                self.backupTimestamp = timestamp
                let log: [String : Any] = [backupLogField.backupUrl : url.absoluteString, backupLogField.timestamp : timestamp]
                backupLogRef.setValue(log)
                completion?(.success)
            }
        }
    }
    
    func backupImage() {
        guard let uid = AuthService.currentUser?.uid else {
            return
        }
        
        let coverFolderPath = DBManager.shared.pathToDocument + "/imageCover"
        let coverRef = COVER_STORAGE_REF.child(uid)
        let fm = FileManager.default
        do {
            if fm.fileExists(atPath: coverFolderPath) {
                let items = try fm.contentsOfDirectory(atPath: coverFolderPath)
                for item in items {
                    let coverFileUrl = URL(fileURLWithPath: coverFolderPath + "/" + item)
                    coverRef.child(item).putFile(from: coverFileUrl, metadata: nil)
                }
            }
        } catch {}
    }
    
    func restoreBackup(completion: @escaping (_ result: CompletionResult) -> ()) {
        guard let uid = AuthService.currentUser?.uid else {
            completion(.failed)
            return
        }
        restoreImage()
        
        let dbFileRef = DBFILE_STORAGE_REF.child("\(uid).sqlite")

        let databaseURL = URL(fileURLWithPath: DBManager.shared.pathToDatabase)
        dbFileRef.write(toFile: databaseURL) { url, error in
           if let error = error {
                print(error.localizedDescription)
                completion(.failed)
                return
           } else {
                // database initialize load data
                CategoryService.shared.getAllCategoriesToCache()
                BookService.shared.getAllBooksToCache()
                completion(.success)
           }
        }
    }
    
    func restoreImage() {
        guard let uid = AuthService.currentUser?.uid else {
            return
        }
        
        let coverRef = COVER_STORAGE_REF.child(uid).child("1.jpg")
        let coverFolderPath = DBManager.shared.pathToDocument //+ "/imageCover"
        let databaseURL = URL(fileURLWithPath: DBManager.shared.pathToDocument + "/good")

        coverRef.write(toFile: databaseURL)
    }
    
    
    
    func getBackupLog(completion: @escaping (_ log: BackupLog?)->()) {
        guard let uid = AuthService.currentUser?.uid else {
            completion(nil)
            return
        }
        
        let backupLogRef = BACKUPLOG_DB_REF.child(uid)
        backupLogRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                if let url = dict[backupLogField.backupUrl] as? String,
                   let timestamp = dict[backupLogField.timestamp] as? Double {
                    let date = TXFunc.convertDoubleToDate(timeStamp: timestamp)
                    let log = BackupLog(url: url, date: date)
                    completion(log)
                }
            }
        })
    }
    
    func checkAutoBackup() {
        guard let timestamp = BackupService.shared.backupTimestamp else {
          return
        }
        
        let backupDate = TXFunc.convertDoubleToDate(timeStamp: timestamp)
        let days = TXFunc.getDaysInterval(start: backupDate, end: Date()) ?? 0
        if days >= 7 {
            self.backupSQLite()
        }
    }
}
