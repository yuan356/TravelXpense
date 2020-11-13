//
//  SaveImage.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class ImageStorage {

    static func store(image: UIImage, forKey key: String) {
       
        guard let filepath = filePath(forKey: key) else {
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
    
    private static func retrieveImage(forKey key: String) -> UIImage? {
        if let filePath = filePath(forKey: key),
            let fileData = FileManager.default.contents(atPath: filePath.path),
            let image = UIImage(data: fileData) {
            return image
        }
        return nil
    }
    
    private static func filePath(forKey key: String) -> URL? {
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
        
        return folderURL.appendingPathComponent(key + ".jpg")
    }
}
