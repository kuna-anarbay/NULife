//
//  ReviewTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/18/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    
    @IBOutlet weak var fifthStar: UIImageView!
    @IBOutlet weak var forthStar: UIImageView!
    @IBOutlet weak var thirdStar: UIImageView!
    @IBOutlet weak var secondStar: UIImageView!
    @IBOutlet weak var firstStar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
