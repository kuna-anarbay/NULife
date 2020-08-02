//
//  Lists.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/4/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation


struct staticList {
    
    
    static let weekDays = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    
    static let reminderList = [ ("Not specified", -1), ("5 minutes", 5), ("10 minutes", 10), ("15 minutes", 15), ("20 minutes", 20), ("30 minutes", 30), ("45 minutes", 45), ("1 hour", 60), ("1.5 hours", 90), ("2 hours", 120), ("3 hours", 180), ("6 hours", 360),  ("12 hours", 720)]
    
    static let icons : [String] = ["list.bullet", "bookmark.fill", "mappin", "gift.fill", "book.fill", "creditcard.fill", "bitcoinsign.square.fill", "paperplane.fill", "trash.fill", "square.and.pencil", "person.fill", "gamecontroller.fill", "house.fill", "desktopcomputer", "music.note", "folder.fill", "tram.fill", "moon.fill", "sun.min.fill", "snow", "car", "cart.fill", "bag.fill", "gear", "chevron.left.slash.chevron.right", "circle.fill", "waveform.path.ecg", "heart.fill", "star.fill", "flame.fill"]
    
    static let colors : [String] = ["#00A89D", "#2887CA", "#D95F4C", "#8F7AC5", "#888DA6", "#FFC659", "#1C8E86", "#0085E3", "#F24024", "#825DDE", "#57608C", "#F6971F"]
    
    static var randomColor: String {
        get {
            colors[Int.random(in: 0..<self.colors.count)]
        }
    }
    
    static var randomIcon: String {
        get {
            icons[Int.random(in: 0..<self.icons.count)]
        }
    }
    
    
    static let schools = ["Graduate School of Business", "Graduate School of Education", "Graduate School of Public Policy", "School of Engineering and Digital Sciences", "School of Medicine", "School of Mining and Geosciences", "School of Sciences and Humanities"]

    
    static let faculties = [
        [
            "Full-Time MBA", "MSc in Finance", "Executive MBA", "Executive Education"
        ],
        [
            "M.Sc. in Educational Leadership", "M.A. in Multilingual Education", "Ph.D. in Education"
        ],
        [
            "Master in Public Policy", "Master in Public Administration", "PhD in Public Policy"
        ],
        [
            "BEng in Chemical and Materials Engineering", "BEng in Civil and Environmental Engineering","BEng in Electrical and Computer Engineering", "BEng in Mechanical and Aerospace Engineering", "BSc in Robotics and Mechatronics", "BSc in Computer Sciences", "Master of Engineering Management", "MSc in Chemical and Materials Engineering", "MSc in Civil and Environmental Engineering", "MSc in Electrical and Computer Engineering", "MSc in Mechanical and Aerospace Engineering", "MSc in Robotics", "MSc in Computer Sciences", "MSc in Data Sciences", "PhD in Science, Engineering and Technology"
        ],
        [
            "Doctor of Medicine", "Master of Public Health", "Master in Molecular Medicine", "Residency Program in General Surgery", "Residency Program in Obstetrics and Gynecology", "Residency Program in Pediatrics", "Residency Program in Internal Medicine", "Residency Program in Family Medicine", "Bachelor of Science In Nursing Program", "Bachelor in Applied Nursing Program", "Nursing Professional Development Program"
        ],
        [
            "BSc in Geology", "BSc in Petroleum Engineering", "BSc in Mining Engineering", "MSc in Petroleum Engineering", "MSc in Mining Engineering"
        ],
        [
            "Political Science and International Relations", "Economics", "History, Philosophy and Religious Studies", "Languages, Linguistics, and Literature", "Sociology", "Anthropology", "Biology", "Chemistry", "Mathematics", "Physics", "Master of Arts in Political Science and International Relations", "Master of Arts in Economics", "Master of Arts in Eurasian Studies", "Master of Science in Biological Sciences and Technologies", "Master of Science in Chemistry", "Master of Science in Applied Mathematics", "Master of Science in Physics", "Ph.D. in Eurasian Studies", "Summer School in Russian and Eurasian Studies"
        ]
    ]
    
}
