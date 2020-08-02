//
//  ItemCollectionViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit


class ItemCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var mainImage: UIImageView!
    var id: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.contentView.layer.cornerRadius = 8
        self.addShadow(radius: 8, Offset: 0.2)
    }
    
    
    @IBAction func likePressed(_ sender: Any) {
        let liked = UserDefaults.standard.object(forKey: "savedItems")
        var favourites : [String: Bool] = liked == nil ? [:] : liked as! [String: Bool]
        
        if favourites.contains(where: {$0.0 == id}) {
            if favourites[id] == false {
                favourites.removeValue(forKey: id)
                likeButton.imageView?.tintColor = .systemGray2
                likeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            }
        } else {
            likeButton.imageView?.tintColor = .systemRed
            likeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            favourites[self.id] = false
        }
        UserDefaults.standard.set(favourites, forKey: "savedItems")
    }
}
