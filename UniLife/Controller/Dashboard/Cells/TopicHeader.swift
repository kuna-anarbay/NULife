//
//  TopicHeader.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/12/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import UIKit

class TopicHeader: UITableViewHeaderFooterView {
    
    
    @IBOutlet weak var moreIcon: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
//    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backView: UIView!
    
    var section: Int = 0
    
}
