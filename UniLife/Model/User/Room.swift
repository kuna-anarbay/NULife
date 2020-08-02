//
//  Room.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/28/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase


class Room {
    
    var id: String = ""
    var room: String = ""
    var block: String = ""
    var terms: String = ""
    var banned: [String: String] = [:]
    var days: [String: [(Int, Int)]] = [:]
    var list: [String: [(Int, String, String)]] = [:]
    
    
    init(){
        
    }
    
    init(_ snapshot: DataSnapshot){
        
        let value = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.block = value["block"] as! String
        self.room = value["room"] as! String
        self.terms = value["terms"] as! String
        
        if snapshot.hasChild("banned"){
            for child in value["banned"] as! NSDictionary {
                banned[child.key as! String] = child.value as? String
            }
        }
        
        if snapshot.hasChild("days"){
            for child in value["days"] as! NSDictionary {
                let slots = child.value as! NSArray
                for slot in slots {
                    let slotVal = slot as! NSDictionary
                    if self.days[child.key as! String] != nil {
                       self.days[child.key as! String]?.append((slotVal["start"] as! Int, slotVal["end"] as! Int))
                    } else {
                       self.days[child.key as! String] = [(slotVal["start"] as! Int, slotVal["end"] as! Int)]
                    }
                    
                }
            }
        }
        
        if snapshot.hasChild("list"){
            for child in value["list"] as! NSDictionary {
                let slots = child.value as! NSDictionary
                for slot in slots {
                    let slotVal = slot.value as! NSDictionary
                    if self.list[child.key as! String] != nil {
                    
                        self.list[child.key as! String]?.append((slotVal["slot_id"] as! Int, slot.key as! String, slotVal["name"] as! String))
                    } else {
                       self.list[child.key as! String] = [(slotVal["slot_id"] as! Int, slot.key as! String, slotVal["name"] as! String)]
                    }
                }
            }
        }
    }
    
    
    
    func book(day: String, slot_id: Int){
        Constants.bookingRefs.child(self.id).child("list").child(day).child(Auth.auth().currentUser!.uid).setValue([
            "name": Auth.auth().currentUser!.displayName!,
            "slot_id": slot_id
        ])
    }
    
    
    func remove(day: String, slot_id: Int){
        Constants.bookingRefs.child(self.id).child("list").child(day).child(Auth.auth().currentUser!.uid).removeValue()
    }
}
