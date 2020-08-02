//
//  DatabaseManager.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 2/9/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase

//MARK: Completion types
enum completionType {
    case error
    case success
}


class DatabaseManager {
    
    
    
    //MARK: Create new key
    static func createKey(
        databaseRef: DatabaseReference,
        completion: @escaping(String) -> Void
    ){
        completion(databaseRef.childByAutoId().key!)
    }
    
    
    
    //MARK: Create new data
    static func create(
        databaseRef: DatabaseReference,
        object: [String: Any],
        completion: @escaping(completionType) -> Void
    ){
        databaseRef.setValue(object) { (error, _ ) in
            if error == nil {                      //Upload success
                completion(.success)
            } else {                               //Upload error
                completion(.error)
            }
        }
    }
    
    
    
    
    //MARK: Update old data
    static func update(
        databaseRef: DatabaseReference,
        object: [String: Any],
        completion: @escaping(completionType) -> Void
    ){
        databaseRef.updateChildValues(object) { (error, _ ) in
            if error == nil {                      //Upload success
                completion(.success)
            } else {                               //Upload error
                completion(.error)
            }
        }
    }
    
    
    
    
    //MARK: Delete old data
    static func delete(
        databaseRef: DatabaseReference,
        storageRef: StorageReference,
        childs: [String],
        completion: @escaping(completionType) -> Void
    ){
        if childs.count == 0 {                              //Delete only object
            databaseRef.removeValue { (error, _) in         //Delete from database
                if error == nil {
                    completion(.success)                    //Deleting success
                } else {
                    completion(.error)                      //Deleting error
                }
            }
        } else {                                            //Delete from storage
            self.deleteImages(storageRef: storageRef, childs: childs, index: 0) {
                databaseRef.removeValue { (error, _) in     //Delete from database
                    if error == nil {
                        completion(.success)                //Deleting success
                    } else {
                        completion(.error)                  //Deleting error
                    }
                }
            }
        }
    }
    
    
    //MARK: Upload all images
    static func uploadImages(
        storageRef: StorageReference,                   //Storage reference
        childs: [String],                               //Children storage references
        images: [UIImage],                              //Uploading images
        index: Int,                                     //Index of current image in images
        image_urls: [String: String],                   //Urls of images to save to Database
        completion: @escaping([String: String]) -> Void //Completion handler
    ){
        if images.count == index {                      //End of recursion
            completion(image_urls)                      //Return all urls
        } else {
            let data = compressImage(images[index])     //Compressed data
            
            if let image = data {                       //Compression success
                
                //Uploading data to Storage
                storageRef.child(childs[index]).putData(image, metadata: nil) { (meta, error) in
                    if error != nil {                   //Uploading error, return values
                        completion(image_urls)
                    } else {                            //Uploading success
                        //Get downloadURL of uploaded data
                        storageRef.child(childs[index]).downloadURL { (downloadURL, error) in
                            if let url = downloadURL {  //Download url success
                                
                                //Append url to urls list
                                var urls : [String: String] = [ childs[index] : "\(url)" ]
                                for image in image_urls {
                                    urls[image.key] = image.value
                                }
                                
                                //Upload next image
                                self.uploadImages(
                                    storageRef: storageRef,
                                    childs: childs,
                                    images: images,
                                    index: index + 1,
                                    image_urls: urls,
                                    completion: completion
                                )
                            } else {                    //Download url error
                                completion(image_urls)
                            }
                        }
                    }
                }
            } else {
                completion(image_urls)              //Compression error occurred
            }
        }
    }
    
    
    //MARK: Compress image to 100KB
    static func compressImage(_ image: UIImage) -> Data? {
        
        //Initialize compressing parameters
        var compression : CGFloat = 1
        let maxCompression : CGFloat = 0.0
        let maxFileSize : Int = 100*1024
        
        //Get longer size
        let max = (image.size.width > image.size.height) ? image.size.width : image.size.height
        
        //TODO: Resize image to 1280px
        var result = image
        if max > 1280 {
            result = image.resizeWithPercent(percentage: 1280/max)!
        } else {
            result = image
        }
        
        //TODO: Compress resized image to 100KB
        var imageData = result.jpegData(compressionQuality: compression)
        while (imageData!.count > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
    
    
    
    
    //MARK: Upload all images
    static func deleteImages(
        storageRef: StorageReference,                   //Storage reference
        childs: [String],                               //Children storage references
        index: Int,                                     //Index of current image in images
        completion: @escaping() -> Void                 //Completion handler
    ){
        if childs.count == index {                      //End of recursion
            completion()                                //Return
        } else {
            //Uploading data to Storage
            storageRef.child(childs[index]).delete { (error) in
                if error != nil {                       //Deleting error, return values
                    completion()
                } else {
                    self.deleteImages(
                        storageRef: storageRef,
                        childs: childs,
                        index: index + 1,
                        completion: completion
                    )
                }
            }
        }
    }
    
    
    
    //MARK: Upload data
    static func uploadData(
        storageRef: StorageReference,                   //Storage reference
        url: URL,                                       //Data url
        completion: @escaping(String?) -> Void          //Completion handler
    ){
        storageRef.putFile(from: url, metadata: nil) { (meta, error) in
            if error != nil {                           //Uploading error
                completion(nil)
            } else {                                    //Uploading success
                storageRef.downloadURL { (downloadURL, error) in
                    if let url = downloadURL {          //Download url success
                        completion("\(url)")
                    } else {                            //Download url error
                        completion(nil)
                    }
                }
            }
        }
    }
}
