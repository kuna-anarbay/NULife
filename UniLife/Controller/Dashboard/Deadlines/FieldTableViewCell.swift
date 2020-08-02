//
//  FieldTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/12/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class FieldTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var subTItleLabel: UILabel!
    var delegate: NewQuestionProtocol!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTextView()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension FieldTableViewCell: UITextViewDelegate {
    
    func setupTextView(){
        textView.delegate = self
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 100
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text == "Details" {
            textView.text = "Details"
            textView.textColor = UIColor(named: "Muted text color")
        } else {
            textView.textColor = .label
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text == "Details" {
            textView.text = ""
        }
        textView.textColor = .label
        delegate.beginEditing(topic: true)

    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate.doneTopic(text: textView.text)
    }
}

