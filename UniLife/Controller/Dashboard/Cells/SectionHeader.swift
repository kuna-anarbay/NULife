//
//  SectionHeader.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/8/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class SectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    var section: Int = 0
}
