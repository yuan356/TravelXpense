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
            } catch let err {
                print("Saving file resulted in error: ", err)
            }
        }
    }
    
    static func retrieveFromLocal(bookId id: Int, imageView: UIImageView) {
        let thread = Thread {
            if let filePath = filePath(bookId: id), let fileData = FileManager.default.contents(atPath: filePath.path) {
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: fileData)
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
