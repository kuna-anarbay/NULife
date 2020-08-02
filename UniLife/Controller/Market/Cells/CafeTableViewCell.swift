//
//  CafeTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class CafeTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if logoImage != nil {
            self.logoImage.layer.cornerRadius = 8
            self.backView.layer.cornerRadius = 12
        }
        
        // Initialization code
    }
}
