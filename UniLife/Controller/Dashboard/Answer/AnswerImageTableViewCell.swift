//
//  AnswerImageTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/14/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase

class AnswerImageTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    var answer = Answer()
    var state : Bool? = nil
    var delegate: showImagesProtocol!
    var question: Question?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        moreButton.layer.cornerRadius = 12
        mainImage.layer.cornerRadius = 12
        upvoteButton.layer.cornerRadius = 10.5
        downVoteButton.layer.cornerRadius = 10.5
        // Initialization code
    }

    
    @IBAction func morePressed(_ sender: Any) {
        if question == nil {
           delegate.showImages(answer)
        } else {
            delegate.showImages(question!)
        }
        
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

