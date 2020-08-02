//
//  DealTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase


class DealTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var delegate: ItemsTableViewCellProtocol!
    
    var items: [Item] = [Item]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        setupCollectionView()
    }
}


extension DealTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    func fetchSeller(uid: String, completion: @escaping(Float, Float, Float) -> Void){
        Constants.userRatingRef.child(uid).observe(.value) { (snapshot) in
            var rating_count : Float = 0.0
            var rating_sum : Float = 0.0
            for child in snapshot.children {
                let value = (child as! DataSnapshot).value as! NSDictionary
                for baby in value {
                    rating_count += 1
                    rating_sum += baby.value as! Float
                }
            }
            let rating = rating_count==0 ? rating_sum/rating_count : 0
            completion(rating_count, rating_sum, rating)
        }
    }
    
    
    
    func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! DealItemCollectionViewCell
        let item = items[indexPath.row]
        
        
        cell.titleLabel.text = item.title
        cell.discountButton.layer.cornerRadius = cell.discountButton.bounds.height/2
        cell.discountButton.setTitle("\(item.discount)%", for: .normal)
        if item.urls?.count ?? 0 > 0 {
            cell.mainImage.setImage(from: URL(string: item.urls![0]))
        } else {
            cell.mainImage.image = UIImage(named: item.category)
        }
        var attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(item.price)₸")
        if item.price == -1 {
            attributeString = NSMutableAttributedString(string: "Negotiable")
        } else if item.price == 0 {
            attributeString = NSMutableAttributedString(string: "Free")
        } else {
            attributeString = NSMutableAttributedString(string: "\(item.price)₸")
        }
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray3, range: NSMakeRange(0, attributeString.length))
        var attrString = NSMutableAttributedString()
        if item.discountedPrice == -1 {
            attrString = NSMutableAttributedString(string: "Negotiable")
        } else if item.discountedPrice == 0 {
            attrString = NSMutableAttributedString(string: "Free")
        } else {
            attrString = NSMutableAttributedString(string: "\(item.discountedPrice)₸")
        }
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen, range: NSMakeRange(0, attrString.length))
        cell.newPrice.attributedText = attrString
        cell.originalPrice.attributedText = attributeString
        
        
        fetchSeller(uid: item.author.uid) { (count, sum, rating) in
            cell.ratingCount.text = "\(Int(count))"
            cell.firstStar.image = rating >= 1 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            cell.secondStar.image = rating >= 2 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            cell.thirdStar.image = rating >= 3 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            cell.forthStar.image = rating >= 4 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            cell.fifthStar.image = rating >= 5 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        }
        
        
        cell.contentView.layer.cornerRadius = 12
        cell.likeButton.addShadow(radius: 18)
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
       
        
        return CGSize(width: (collectionView.bounds.width-12)/2, height: 250)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate.selectedItem(items[indexPath.row])
    }
}
