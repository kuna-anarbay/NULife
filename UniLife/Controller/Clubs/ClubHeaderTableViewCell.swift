//
//  ClubHeaderTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/13/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase


class ClubHeaderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    var club: Club = Club()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        followButton.layer.cornerRadius = 5
        followButton.setTitleColor(UIColor(named: "Main color"), for: .normal)
        followButton.layer.borderColor = UIColor(named: "Main color")?.withAlphaComponent(0.5).cgColor
        followButton.layer.borderWidth = 1.0
        followButton.backgroundColor = .clear
        backView.layer.cornerRadius = 16
    }

    
    
    @IBAction func followPressed(_ sender: Any) {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.tintColor = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        followButton.setTitle("", for: .normal)
        followButton.addSubview(spinner)
        spinner.centerVertically()
        spinner.centerHorizontally()
        spinner.startAnimating()
        if club.followers?.index(forKey: Auth.auth().currentUser!.uid) != nil {
            club.unFollow { (message) in
                if message == .success {
                    self.followButton.setTitle("Follow", for: .normal)
                    spinner.removeFromSuperview()
                }
            }
        } else {
            club.follow { (message) in
                if message == .success {
                    self.followButton.setTitle("Unfollow", for: .normal)
                    spinner.removeFromSuperview()
                }
            }
        }
    }
    
}
