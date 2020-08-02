//
//  AnswerTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/14/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase


class AnswerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    
    @IBOutlet weak var downVoteButton: UIButton!
    var answer = Answer()
    var state : Bool? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func upvotePressed(_ sender: Any) {
        
        let ref = Constants.answersRef.child(answer.courseId).child(answer.sectionId)
         let voteRef = ref.child(answer.questionId).child(answer.id).child("votes")
         
         if let state = state {
             if state == false {
                 voteRef.child(Auth.auth().currentUser!.uid).updateChildValues([
                     "vote": true
                 ])
             } else {
                 voteRef.child(Auth.auth().currentUser!.uid).removeValue()
             }
         } else {
             voteRef.child(Auth.auth().currentUser!.uid).updateChildValues([
                 "vote": true
             ])
         }
        
    }
    
    @IBAction func downVotePressed(_ sender: Any) {
        let ref = Constants.answersRef.child(answer.courseId).child(answer.sectionId)
        let voteRef = ref.child(answer.questionId).child(answer.id).child("votes")
        
        if let state = state {
            if state == true {
                voteRef.child(Auth.auth().currentUser!.uid).updateChildValues([
                    "vote": false
                ])
            } else {
                voteRef.child(Auth.auth().currentUser!.uid).removeValue()
            }
        } else {
            voteRef.child(Auth.auth().currentUser!.uid).updateChildValues([
                "vote": false
            ])
        }
    }
    
}
