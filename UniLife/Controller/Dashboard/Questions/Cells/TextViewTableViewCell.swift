//
//  TextViewTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/10/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

protocol NewQuestionProtocol {
    func doneTopic(text: String)
    func doneBody(text: String)
    func switchChanged(isOn: Bool)
    func beginEditing(topic: Bool)
    func selectedTopic(topic: String)
    func selectedLocation(location: String)
}


class TextViewTableViewCell: UITableViewCell {

    
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var topicTextView: UITextView!
    var delegate: NewQuestionProtocol!
    var question: Question!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        setupTextView()
        // Initialization code
    }
    
    

}

extension TextViewTableViewCell: UITextViewDelegate {
    
    func setupTextView(){
        topicTextView.delegate = self
        bodyTextView.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        if textView == topicTextView {
            return numberOfChars <= 120
        } else if textView == bodyTextView {
            return numberOfChars <= 500
        }
        return numberOfChars <= 120
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == topicTextView {
            if textView.text == "" || textView.text == "Question title" {
                textView.text = "Question title"
                textView.textColor = UIColor(named: "Muted text color")
            } else {
                textView.textColor = .label
            }
        } else if textView == bodyTextView {
            if textView.text == "" || textView.text == "Question body" {
                textView.text = "Question body"
                textView.textColor = UIColor(named: "Muted text color")
            } else {
                textView.textColor = .label
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == topicTextView {
            if textView.text == "" || textView.text == "Question title" {
                textView.text = ""
            }
            textView.textColor = .label
            delegate.beginEditing(topic: true)
        } else if textView == bodyTextView {
            if textView.text == "" || textView.text == "Question body" {
                textView.text = ""
            }
            textView.textColor = .label
            delegate.beginEditing(topic: false)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == topicTextView {
            delegate.doneTopic(text: textView.text)
        } else {
            delegate.doneBody(text: textView.text)
        }
    }
}
