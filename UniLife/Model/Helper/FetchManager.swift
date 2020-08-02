//
//  FetchManager.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 2/10/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase

class FetchManager {
    
    //MARK: Get one Snapshot
    static func getOne(
        databaseRef: DatabaseReference,
        completion: @escaping(DataSnapshot) -> Void
    ){
        databaseRef.observe(.value) { (snapshot) in
            completion(snapshot)
        }
    }
    
    
    //MARK: Get custom type Snapshot
    static func getCustomOne(
        databaseRef: DatabaseReference,
        completion: @escaping(AnyObject) -> Void
    ){
        databaseRef.observe(.value) { (snapshot) in
            completion(snapshot)
        }
    }
    
    
    //MARK: Get all Snapshots
    static func getAll(
        databaseRef: DatabaseReference,
        completion: @escaping([DataSnapshot]) -> Void
    ){
        databaseRef.observe(.value) { (snapshot) in
            var snapshots = [DataSnapshot]()
            
            
            for child in snapshot.children {
                let value = child as! DataSnapshot
                if value.value != nil || value.hasChildren(){
                    snapshots.append(value)
                }
            }
            
            completion(snapshots)
        }
    }
    
    
    //MARK: Get all Snapshots
    static func getAll(
        databaseRef: DatabaseQuery,
        completion: @escaping([DataSnapshot]) -> Void
    ){
        databaseRef.observe(.value) { (snapshot) in
            var snapshots = [DataSnapshot]()
            
            for child in snapshot.children {
                snapshots.append(child as! DataSnapshot)
            }
            
            completion(snapshots)
        }
    }
    
    
    //MARK: Get custom type all Snapshots
    static func getCustomAll(
        databaseRef: DatabaseReference,
        completion: @escaping([AnyObject]) -> Void
    ){
        databaseRef.observe(.value) { (snapshot) in
            var snapshots = [AnyObject]()
            
            for child in snapshot.children {
                snapshots.append(child as AnyObject)
            }
            
            completion(snapshots)
        }
    }
    
}
