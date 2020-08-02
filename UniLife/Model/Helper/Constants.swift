//
//  Constants.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/2/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase


struct Constants {
    
    static let realm = try! Realm()
    
    static let rootRef = Database.database().reference()
    static let storageRef = Storage.storage().reference()
    
    
    
    //MARK: USER REFS
    static let currentUser = Auth.auth().currentUser
    static let currentUserRef =
        rootRef.child("users").child(currentUser!.uid)
    static let userRatingRef = rootRef.child("user_ratings")
    static let userCoursesRef =
        rootRef.child("users").child(currentUser!.uid).child("courses")
    static let userClubsRef =
    rootRef.child("users").child(currentUser!.uid).child("clubs")
    static let userImageRef = storageRef.child("users")
    static let anonymIdRef = rootRef.child("anonymous").child(Auth.auth().currentUser!.uid)
    //MARK: Female Requests REFS
    static let femaleRequestsRef = rootRef.child("female_requests")
    
    //MARK: Notifications REFS
    static let notificationsRef = rootRef.child("notifications")
    
    
    //MARK: COURSE REFS
    static let suggestionRef = rootRef.child("suggested_courses")
    static let allCoursesRef = rootRef.child("all_courses")
    static let coursesRef = rootRef.child("courses")
    static let syllabusRef = storageRef.child("syllabus")
    
    
    
    //MARK: TOPICS REFS
    static let topicsRef = rootRef.child("topics")
    
    
    
    //MARK: EVENTS REFS
    static let deadlinesRef = rootRef.child("deadlines")
    
    
    
    //MARK: QUESTIONS REFS
    static let questionsRef = rootRef.child("questions")
    static let questionImagesRef = storageRef.child("questions")
    
    
    
    //MARK: ANSWERS REFS
    static let answersRef = rootRef.child("answers")
    static let answersImagesRef = storageRef.child("answers")
    
    
    //MARK: RESOURSES REFS
    static let resoursesRef = rootRef.child("resources")
    static let resourseFilesRef = storageRef.child("resources")
    
    
    //MARK: CAFES REFS
    static let cafesRef = rootRef.child("cafes")
    static let cafesLogosRef = storageRef.child("cafes")
    
    
    //MARK: REVIEWS REFS
    static let reviewsRef = rootRef.child("reviews")
    static let reviewImagesRef = storageRef.child("reviews")
    
    
    //MARK: MEALS REFS
    static let mealsRef = rootRef.child("meals")
    static let mealImageRef = storageRef.child("meals")
    
    
    //MARK: ITEMS REFS
    static let itemsRef = rootRef.child("items")
    static let itemImageRef = storageRef.child("items")
    static let femaleItemsRef = rootRef.child("female_items")
    static let femaleItemImageRef = storageRef.child("female_items")
    
    
    //MARK: REQUESTS REFS
    static let requestsRef = rootRef.child("requests")
    
    
    
    //MARK: CLUBS REFS
    static let clubsRef = rootRef.child("clubs")
    static let clubsShortRef = rootRef.child("all_clubs")
    static let clubLogosRef = storageRef.child("clubs")
    static let clubBackgroundsRef = storageRef.child("clubBackgrounds")
    
    
    //MARK: EVENTS REFS
    static let eventsRef = rootRef.child("events")
    static let eventImageRef = storageRef.child("events")
    
    
    //MARK: BOOKING REFS
    static let bookingRefs = rootRef.child("booking")
    
}
