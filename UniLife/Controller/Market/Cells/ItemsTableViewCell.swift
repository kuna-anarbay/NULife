//
//  ItemsTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase

protocol ItemsTableViewCellProtocol {
    func selectedItem(_ item: Item)
    func changeState()
}


class ItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var delegate: ItemsTableViewCellProtocol!
    var gridItems : Bool = true {
        didSet {
            stateButton.setImage(UIImage(systemName: gridItems ? "square.grid.2x2.fill" : "list.dash"), for: .normal)
        }
    }
    var items: [Item] = [Item]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = gridItems ? 12 : 0
        layout.minimumLineSpacing = gridItems ? 12 : 0 
        collectionView.collectionViewLayout = layout
        setupCollectionView()
    }
    
    
    @IBAction func changeState(_ sender: Any) {
        delegate.changeState()
    }
    
    
}


extension ItemsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    
    func setupCollectionView(){
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridItems ? "itemCell" : "largeItemCell", for: indexPath) as! ItemCollectionViewCell
        let item = items[indexPath.row]
        
        cell.titleLabel.text = item.title
        if item.discountedPrice == -1 {
            cell.priceLabel.text = "Negotiable"
        } else if item.discountedPrice == 0 {
            cell.priceLabel.text = "Free"
        } else {
            cell.priceLabel.text = "\(item.discountedPrice)₸"
        }
        
        if item.urls?.count ?? 0 > 0 {
            cell.mainImage.sd_setImage(with: URL(string: item.urls![0]), placeholderImage: UIImage(named: item.category), options: .refreshCached, context: nil)
        } else {
            cell.mainImage.image = UIImage(named: item.category)
        }
        
        cell.likeButton.layer.cornerRadius = 18
        cell.id = item.id
        let liked = UserDefaults.standard.object(forKey: "savedItems")
        let favourites : [String: Bool] = liked == nil ? [:] : liked as! [String: Bool]
        
        if favourites.contains(where: {$0.0 == item.id}) {
            cell.likeButton.imageView?.tintColor = .systemRed
            cell.likeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
        } else {
            cell.likeButton.imageView?.tintColor = .systemGray2
            cell.likeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if gridItems {
            let width = (self.collectionView.bounds.width-12)/2
            let height = width*4/3
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: self.collectionView.bounds.width, height: 120)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate.selectedItem(items[indexPath.row])
    }
}
