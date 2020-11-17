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
    
    var backupTime: Date!
    
    private init() { }
    
//    // MARK: - Firebase Database 參照
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    let BACKUPLOG_DB_REF: DatabaseReference = Database.database().reference().child("BackupLog")
    
    // MARK: - Firebase Storage 參照
    let DBFILE_STORAGE_REF: StorageReference = Storage.storage().reference().child("DBfile")
//    let COVER_STORAGE_REF: StorageReference = Storage.storage().reference().child("COVER")

    
    func initSetting() {
        
    }
    
    func backupSQLite(completion: @escaping (_ result: CompletionResult, _ log: BackupLog?)->()) {
        // 確保已登入
        guard let uid = AuthService.currentUser?.uid else {
            completion(.failed, nil)
            return
        }

        let backupLogRef = BACKUPLOG_DB_REF.child(uid)

        let dbFileUrl = URL(fileURLWithPath: DBManager.shared.pathToDatabase)
        let storgeRef = DBFILE_STORAGE_REF.child("\(uid).sqlite")
        
        let _ = storgeRef.putFile(from: dbFileUrl, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                print("Error1")
                completion(.failed, nil)
                return
            }
            
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
                print("size: ", size)
                storgeRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error2")
                    completion(.failed, nil)
                    return
                }
                
                // store the backup log to database
                let fileUrl = downloadURL.absoluteString
                let date = Date()
                let timestamp = date.timeIntervalSince1970
                let log: [String : Any] = [backupLogField.backupUrl : fileUrl, backupLogField.timestamp : timestamp]
                backupLogRef.setValue(log)
                    
                let backupLog = BackupLog(url: fileUrl, date: date)
                completion(.success, backupLog)
            }
        }
    }
    
    func restoreBackup(completion: @escaping (_ result: CompletionResult) -> ()) {
        guard let uid = AuthService.currentUser?.uid else {
            completion(.failed)
            return
        }
        let dbFileRef = DBFILE_STORAGE_REF.child("\(uid).sqlite")

        let documentURL = URL(fileURLWithPath: DBManager.shared.pathToDatabase)
        dbFileRef.write(toFile: documentURL) { url, error in
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
}
