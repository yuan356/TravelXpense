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

class FirebaseService {
    static let shared = FirebaseService()
    private init() { }
    
//    // MARK: - Firebase Database 參照
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    let BACKUPLOG_DB_REF: DatabaseReference = Database.database().reference().child("BackupLog")
    
    // MARK: - Firebase Storage 參照
    let DBFILE_STORAGE_REF: StorageReference = Storage.storage().reference().child("DBfile")
//    let COVER_STORAGE_REF: StorageReference = Storage.storage().reference().child("COVER")

    func backupSQLite(completion: @escaping (_ result: CompletionResult, _ timestamp: Double? )->()) {
        // 確保已登入
        guard let uid = AuthService.currentUser?.uid else {
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
                let timestamp = Date().timeIntervalSince1970
                    let log: [String : Any] = [backupLogField.backupUrl : fileUrl, backupLogField.timestamp : timestamp]
                backupLogRef.setValue(log)
                completion(.success, timestamp)
            }
        }
    }
    
    func getBackupLog() {
        guard let uid = AuthService.currentUser?.uid else {
            return
        }
        
        let backupLogRef = BACKUPLOG_DB_REF.child(uid)
        backupLogRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let log = snapshot.value as? [String: Any] {
                print("DBfile Url: ", log[backupLogField.backupUrl] ?? "")
                print("timestamp: ", log[backupLogField.timestamp] ?? "")
            }
            
            
        })
    }
}
