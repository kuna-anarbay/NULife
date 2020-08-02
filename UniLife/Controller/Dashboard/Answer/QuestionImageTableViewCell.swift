//
//  QuestionImageTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/14/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

protocol showImagesProtocol {
    func showImages(_ question: Question)
    func showImages(_ answer: Answer)
}
class QuestionImageTableViewCell: UITableViewCell {

    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var detailLabel: UILabel!
    var question: Question!
    var delegate: showImagesProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func morePressed(_ sender: Any) {
        delegate.showImages(question)
    }
    
}
