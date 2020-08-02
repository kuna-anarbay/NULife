//
//  ItemImageCollectionViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/20/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class ItemImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var categories: Bool = false
    var delegate: selectCategories!
    var index = IndexPath(row: 0, section: 0)
    
    @IBAction func removePressed(_ sender: Any) {
        if categories {
            delegate.remove(index)
        } else {
            delegate.remove(index)
        }
    }
    
}
