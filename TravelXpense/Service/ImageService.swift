//
//  SaveImage.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class ImageService {

    static func storeToLocal(image: UIImage, bookId id: Int) {
       
        guard let filepath = filePath(bookId: id) else {
            return
        }
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            do  {
                try imageData.write(to: filepath, options: .atomic)
                CacheManager.shared.cache(object: image, key: "\(id)")
            } catch let err {
                print("Saving file resulted in error: ", err)
            }
        }
    }
    
    static func initRetrieveImageForBook(bookId id: Int) {
        retrieveFromLocal(bookId: id)
    }
    
    
    static func deleteImageFromLocal(bookId id: Int) {
        if let filePath = filePath(bookId: id) {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {}
        }
    }
    
    static func retrieveFromLocal(bookId id: Int, imageView: UIImageView? = nil) {
        
        let thread = Thread {
            // 有在cache裡的話直接取得。
            if let image = CacheManager.shared.getFromCache(key: "\(id)") as? UIImage {
                DispatchQueue.main.async {
                    imageView?.image = image
                }
                return
            }
            
            if let filePath = filePath(bookId: id), let fileData = FileManager.default.contents(atPath: filePath.path) {
                guard let image = UIImage(data: fileData) else {
                    return }
                CacheManager.shared.cache(object: image, key: "\(id)")
                DispatchQueue.main.async {
                    imageView?.image = image
                }
            }
        }
        thread.start()
    }
    
    private static func filePath(bookId id: Int) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                             in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
           
        let folderName = "imageCover"
        let folderURL = documentURL.appendingPathComponent(folderName)
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                // Attempt to create folder
                try fileManager.createDirectory(atPath: folderURL.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                // Creation failed. Print error & return nil
                print(error.localizedDescription)
                return nil
            }
        }
        
        return folderURL.appendingPathComponent("\(id).jpg")
    }
}
