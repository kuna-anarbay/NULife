//
//  CourseHeaderTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/3/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class CourseHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func setup(title: String, detail: String){
        self.title.text = title
        self.detail.text = detail
    }
    
}
