//
//  EventTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/25/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        backView.layer.cornerRadius = 8
        mainImage.layer.cornerRadius = 4
    }
    
}
