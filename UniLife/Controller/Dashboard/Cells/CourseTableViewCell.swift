//
//  CourseTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/8/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.colorView.layer.cornerRadius = 2.5
    }
    
    
    func setup(course: Course){
        self.title.text = course.title
        self.subTitle.text = course.longTitle
        self.colorView.backgroundColor = UIColor(hexString: course.color)
    }

}
