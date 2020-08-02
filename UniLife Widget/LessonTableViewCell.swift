//
//  LessonTableViewCell.swift
//  GoStudy Widget
//
//  Created by Kuanysh Anarbay on 8/21/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class LessonTableViewCell: UITableViewCell {

    @IBOutlet weak var lessonName: UILabel!
    @IBOutlet weak var lessonDetail: UILabel!
    @IBOutlet weak var cellBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lessonName.textColor = .white
        lessonDetail.textColor = .white
        cellBackground.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
