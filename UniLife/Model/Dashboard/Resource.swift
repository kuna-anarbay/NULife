//
//  Resource.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/2/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase
import YPImagePicker

class Resource {
    
    var courseId: String = ""
    var id: String = ""
    
    var author = Member()
    var authorRepresentation : [String: String] = [:]
    var semester: String = "Fall"
    var assessment: String = "Quiz 1"
    var year: Int = 2019
    
    var urls: [String] = [String]()
    var contentType: String = ""
    
    var details: String? = ""
    var professor: String? = ""
    
    init(){
        
    }
    
    init(from snapshot: DataSnapshot, courseId: String) {
        let value = snapshot.value as! NSDictionary
        
        self.courseId = courseId
        self.id = snapshot.key
        
        self.authorRepresentation = value["author"] as! [String: String]
        self.author = Member(
            name: authorRepresentation["name"]!,
            uid: authorRepresentation["uid"]!,
            image: authorRepresentation["image"]!
        )
        self.semester = value["semester"] as! String
        self.assessment = value["assessment"] as! String
        self.year = value["year"] as! Int
        
        self.urls = value["urls"] as? [String] ?? []
        self.contentType = value["content_type"] as! String
        
        self.details = value["details"] as? String
        self.professor = value["professor"] as? String
    }
    
    
    
    //MARK: Fetch all resources
    static func getResources(of courseId: String, completion: @escaping([Resource]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.resoursesRef.child(courseId)) { (snapshots) in
            completion(snapshots.map({ (snapshot) -> Resource in
                return Resource(from: snapshot, courseId: courseId)
            }))
        }
    }
}


extension Resource {
    
    //MARK: Representation
    var newRepresentation: [String : Any] {[
        "semester": self.semester,
        "assessment": self.assessment,
        "year": self.year,
        
        "content_type": self.contentType,
        "urls": self.urls,
        
        "professor": self.professor ?? "",
        "details": self.details ?? "",
        
        "author": self.author.authorRepresentation
    ]}
    
    
    
    //MARK: Functions
    func firebaseAdd(
        fileURL: URL?,
        images: [UIImage]?,
        completion: @escaping(completionType) -> Void
    ){
        
        DatabaseManager.createKey(
            databaseRef: Constants.resoursesRef.child(self.courseId)
        ){ (key) in
            if let images = images, images.count > 0 {
                DatabaseManager.uploadImages(
                    storageRef: Constants.resourseFilesRef.child(self.id),
                    childs: Array(0..<images.count).map({ (index) -> String in
                        return self.courseId + "-"
                            + self.semester
                            + "-\(self.year)-"
                            + self.assessment
                            + "-\(index)"
                    }),
                    images: images,
                    index: 0,
                    image_urls: [:]
                ) { (result) in
                        
                        self.urls = result.map({ (arg0) -> String in
                            return arg0.value
                        })
                    
                        self.firebaseCreate(
                            databaseRef: Constants.resoursesRef.child(self.courseId).child(key)
                        ) { (message) in
                            completion(message)
                        }
                }
            } else {
                if let url = fileURL {
                    DatabaseManager.uploadData(storageRef: Constants.resourseFilesRef.child(self.id).child("0"),
                        url: url
                    ) { (downloadURL) in
                        
                        self.urls = ["\(downloadURL!)"]
                        
                        self.firebaseCreate(
                            databaseRef: Constants.resoursesRef.child(self.courseId).child(key)
                        ) { (message) in
                            completion(message)
                        }
                    }
                } else {
                    completion(.error)
                }
            }
        }
    }

    
    func firebaseRemove(completion: @escaping(completionType) -> Void){
        Constants.resoursesRef.child(self.courseId).child(self.id).removeValue { (error, _) in
            if error != nil {
                Constants.resourseFilesRef.child(self.id).delete { (error) in
                    if error != nil {
                        completion(.error)
                    } else {
                        completion(.success)
                    }
                }
            } else {
                completion(.error)
            }
        }
    }
    
    
    private func firebaseCreate(
        databaseRef: DatabaseReference,
        completion: @escaping(completionType) -> Void
    ){
        User.getCurrentUser { (user) in
            self.author = Member(
                name: user.name,
                uid: user.id,
                image: user.image
            )
            DatabaseManager.create(
                databaseRef: databaseRef,
                object: self.newRepresentation
            ) { (message) in
                    completion(message)
            }
        }
    }
}
