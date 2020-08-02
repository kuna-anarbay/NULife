//
//  SmallEventTableViewCell.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 11/15/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class SmallEventTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        backView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
