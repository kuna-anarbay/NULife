//
//  ClubTeamTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/13/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class ClubTeamTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var heads: [String: [String: String]] = [:] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }


}


extension ClubTeamTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headCell", for: indexPath) as! TeamMemberCollectionViewCell
        let head = heads[Array(heads.keys)[indexPath.row]]

        cell.mainImage.setImage(from: URL(string: head!["image"] ?? ""))
        cell.nameLabel.text = head!["name"]
        cell.roleLabel.text = head!["role"]
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/2, height: 120)
    }
    
}
