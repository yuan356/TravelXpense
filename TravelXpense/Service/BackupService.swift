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
    static let imageNameList = "imageNameList"
    static let timestamp = "timestamp"
}

struct BackupLog {
    var url: String
    var imageList: [String]
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
        
        setBackupTime {
            if UserDefaults.standard.bool(forKey: UserDefaultsKey.autoBackup.rawValue) {
                self.checkAutoBackup()
            }
        }
    }
    
    func setBackupTime(completion: @escaping ()->()) {
        let time = UserDefaults.standard.double(forKey: UserDefaultsKey.backupTime.rawValue)
        if time == 0.0 {
            getBackupTime { (time) in
                UserDefaults.standard.set(time, forKey: UserDefaultsKey.backupTime.rawValue)
                self.backupTimestamp = time
                completion()
            }
        } else {
            self.backupTimestamp = time
            completion()
        }
    }
    
    func backupSQLite(completion: ((_ result: CompletionResult)->())? = nil) {
        // 確保已登入
        guard let uid = AuthService.currentUser?.uid else {
            completion?(.failed)
            return
        }
        
        guard let nameList = backupImage() else {
            return
        }
        
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
                let log: [String : Any] = [backupLogField.backupUrl : url.absoluteString,
                                           backupLogField.imageNameList: nameList,
                                           backupLogField.timestamp : timestamp]
                backupLogRef.setValue(log)
                completion?(.success)
            }
        }
    }
    
    func backupImage() -> [String]? {
        guard let uid = AuthService.currentUser?.uid else {
            return nil
        }
        
        var imageNameList = [String]()
        let coverFolderPath = DBManager.shared.pathToDocument + "/imageCover"
        let coverRef = COVER_STORAGE_REF.child(uid)
        let fm = FileManager.default
        do {
            if fm.fileExists(atPath: coverFolderPath) {
                let items = try fm.contentsOfDirectory(atPath: coverFolderPath)
                for item in items {
                    let coverFileUrl = URL(fileURLWithPath: coverFolderPath + "/" + item)
                    coverRef.child(item).putFile(from: coverFileUrl, metadata: nil)
                    imageNameList.append(item)
                }
            }
        } catch {}
        return imageNameList
    }
    
    func restoreBackup(completion: @escaping (_ result: CompletionResult) -> ()) {
        guard let uid = AuthService.currentUser?.uid else {
            completion(.failed)
            return
        }
        
        let dbRef = BACKUPLOG_DB_REF.child(uid)
        dbRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                if let list = dict[backupLogField.imageNameList] as? [String] {
                    self.restoreImage(list)
                }
            } else {
                TXAlert.showCenterAlert(message: "There is no backup data.")
                completion(.failed)
                return
            }
        }
                
        let sqlFileRef = DBFILE_STORAGE_REF.child("\(uid).sqlite")
        let databaseURL = URL(fileURLWithPath: DBManager.shared.pathToDatabase)
        sqlFileRef.write(toFile: databaseURL) { url, error in
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
    
    func restoreImage(_ imageList: [String]) {
        guard let uid = AuthService.currentUser?.uid else {
            return
        }
        
        let coverRef = COVER_STORAGE_REF.child(uid)
        
        let localFolderPath = DBManager.shared.pathToDocument + "/imageCover/"
        
        for imageName in imageList {
            coverRef.child(imageName).write(toFile: URL(fileURLWithPath: localFolderPath + imageName))
        }
    }
    
    func getBackupTime(completion: @escaping (_ time: Double?)->()){
        guard let uid = AuthService.currentUser?.uid else {
            return
        }
            
        let backupLogRef = BACKUPLOG_DB_REF.child(uid)
        backupLogRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any],
               let timestamp = dict[backupLogField.timestamp] as? Double {
                completion(timestamp)
            }
        })
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
                   let timestamp = dict[backupLogField.timestamp] as? Double,
                   let list = dict[backupLogField.imageNameList] as? [String] {
                    let date = TXFunc.convertDoubleToDate(timeStamp: timestamp)
                    let imagelist = list
                    let log = BackupLog(url: url, imageList: imagelist, date: date)
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
    
    func resetBackupTime() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.backupTime.rawValue)
        self.backupTimestamp = nil
    }
}
