//
//  SwitchTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/10/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var customSwitch: UISwitch!
    var delegate: NewQuestionProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    @IBAction func switched(_ sender: Any) {
        delegate.switchChanged(isOn: customSwitch.isOn)
    }
    
}
