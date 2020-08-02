//
//  EventTableViewCell.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 11/15/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class LargeEventTableViewCell: UITableViewCell {

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        backView.layer.cornerRadius = 8
        borderView.layer.cornerRadius = 3
    }

}
