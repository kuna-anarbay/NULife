//
//  FavoriteTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/22/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit


protocol RemoveFav {
    func remove(_ indexPath: IndexPath)
    func remove(indexPath: IndexPath)
}


class FavoriteTableViewCell: UITableViewCell {

    
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    var delegate: RemoveFav!
    var indexPath = IndexPath()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    
    @IBAction func removePressed(_ sender: Any) {
        delegate.remove(indexPath)
    }
    

}
