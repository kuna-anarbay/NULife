//
//  DeadlineTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/9/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class DeadlineTableViewCell: UITableViewCell {

    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var stateImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.cornerRadius = 2.5
        backView.layer.cornerRadius = 12
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
