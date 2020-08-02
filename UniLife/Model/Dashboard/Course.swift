//
//  Course.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/2/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase


class Course {
    
    var id : String = ""
    var title : String = ""
    var longTitle : String = ""
    var section : String = "1"
    
    var professor : String? = ""
    var syllabus: String? = ""
    var color : String = staticList.colors[Int.random(in: 0...11)]
    
    var students : [Member] = []
    
    
    //MARK: Initializers
    init(fromAll snapshot: DataSnapshot) {
        self.id = snapshot.key
        self.title = snapshot.key
        self.longTitle = snapshot.value as! String
    }
    
    
    init(fromUser snapshot: DataSnapshot) {
        
        let value = snapshot.value as! [String : AnyObject]
        
        self.id = snapshot.key
        self.title = snapshot.key
        self.color = value["color"] as! String
        self.longTitle = value["long_title"] as! String
        self.section = value["section"] as! String
    }
    
    
    init(title: String, fromCourses snapshot: DataSnapshot){
        
        self.id = title
        self.title = title
        self.section = snapshot.key
        
        if snapshot.hasChildren() {
            let value = snapshot.value as! NSDictionary
            self.professor = value["professor"] as? String
            self.syllabus = value["syllabus"] as? String
            self.longTitle = value["long_title"] as? String ?? self.id
            
            for student in value["students"] as? [String: Any] ?? [:] {
                let studentValue = student.value as! [String: String]

                let member = Member(
                    name: studentValue["name"] ?? "Student",
                    uid: student.key,
                    image: studentValue["image"] ?? "url"
                )

                self.students.append(member)
            }
        }
    }
}


extension Course {
    
    //MARK: Enroll
    var enrollRepresentation: [String : String] {[
        "section": self.section,
        "color": self.color,
        "long_title": self.longTitle
    ]}
    
    
    //MARK: Update info
    var updateRepresentation: [String : String] {[
        "professor": self.professor ?? "",
        "syllabus": self.syllabus ?? ""
    ]}
    
    
    //MARK: Update color
    var colorUpdateRepresentation: [String : String] {[
        "color": self.color
    ]}
}


extension Course {
    
    //MARK: Enroll to course
    func enroll(){
        Constants.userCoursesRef.child(self.id).setValue(self.enrollRepresentation)
    }
    
    //MARK: Unenroll from course
    func unEnroll(){
        Constants.userCoursesRef.child(self.id).setValue(nil)
    }
    
    
    //MARK: Update course info
    func update(url: URL?, completion: @escaping(completionType) -> Void){
        if let url = url {
            DatabaseManager.uploadData(
                storageRef: Constants.syllabusRef.child(self.id).child(self.section),
                url: url
            ) { (downloadURL) in
                self.syllabus = downloadURL
                
                self.updateDatabase { (message) in
                    completion(message)
                }
            }
        } else {
            self.updateDatabase { (message) in
                completion(message)
            }
        }
    }
    
    
    //TODO: Update database
    private func updateDatabase(completion: @escaping(completionType) -> Void){
        DatabaseManager.update(
            databaseRef: Constants.coursesRef.child(self.id).child(self.section),
            object: self.updateRepresentation
        ) { (message) in
            if message == .success {
                DatabaseManager.update(
                    databaseRef: Constants.userCoursesRef.child(self.id),
                    object: self.colorUpdateRepresentation
                ) { (message) in
                    completion(message)
                }
            } else {
                completion(.error)
            }
        }
    }

    
    //MARK: Fetch courses from all_courses
    static func getAllCourses(completion: @escaping([Course]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.allCoursesRef) { (snapshots) in
            print("Get all courses")
            print(snapshots)
            completion(snapshots.map({ (snapshot) -> Course in
                return Course(fromAll: snapshot)
            }))
        }
    }
    
    
    //MARK: Fetch courses from user_courses
    static func getUserCourses(completion: @escaping([Course]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.userCoursesRef) { (snapshots) in
            completion(snapshots.map({ (snapshot) -> Course in
                return Course(fromUser: snapshot)
            }))
        }
    }
    
    
    //MARK: Yerbol is the best
    static func getByIdAndSection(
        _ id: String,
        _ section: String,
        completion: @escaping(Course) -> Void
    ){
        FetchManager.getOne(databaseRef: Constants.coursesRef.child(id).child(section)) { (snapshot) in
            completion(Course(title: id, fromCourses: snapshot))
        }
    }
}


class Member {
    
    var name : String = ""
    var uid: String = ""
    var image: String = ""
    
    init() {
        
    }
    
    init(name: String, uid: String) {
        self.name = name
        self.uid = uid
    }
    
    
    init(name: String, uid: String, image: String) {
        self.name = name
        self.uid = uid
        self.image = image
    }
    
    
    init(author: [String: String]) {
        self.name = author["name"]!
        self.uid = author["uid"]!
        self.image = author["image"]!
    }
    
    
    init(member: [String: [String: String]]) {
        self.uid = member.keys.first!
        self.name = member[self.uid]!["name"]!
        self.image = member[self.uid]!["image"]!
    }
    
    
    //MARK: Enroll
    var memberRepresentation: [String : [String: String]] {[
        self.uid: [
            "name": self.name,
            "image": self.image
        ]
    ]}
    
    
    var authorRepresentation: [String : String] {[
        "name": self.name,
        "uid": self.uid,
        "image": self.image
    ]}
}


