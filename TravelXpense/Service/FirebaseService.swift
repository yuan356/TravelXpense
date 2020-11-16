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


class FirebaseService {
    static let shared = FirebaseService()
    private init() { }
    
//    // MARK: - Firebase Database 參照
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    let BACKUPLOG_DB_REF: DatabaseReference = Database.database().reference().child("BackupLog")
    
    // MARK: - Firebase Storage 參照
    let DBFILE_STORAGE_REF: StorageReference = Storage.storage().reference().child("DBFile")

}
