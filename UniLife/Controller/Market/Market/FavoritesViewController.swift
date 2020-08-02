//
//  FavoritesViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/22/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert

class FavoritesViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var items = [(Item, Bool)]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        setupTableView()
        fetchItems()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            let dest = segue.destination as! ItemViewController
            dest.item = sender as! Item
        }
    }
}



extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {

    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return items.filter({$0.1}).count
        } else {
            return items.filter({!$0.1}).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavoriteTableViewCell
        let item = indexPath.section==0 ? items.filter({$0.1})[indexPath.row].0 : items.filter({!$0.1})[indexPath.row].0
        
        cell.titleLabel.text = item.title
        var attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(item.price)₸")
        if item.price == -1 {
            attributeString = NSMutableAttributedString(string: "Negotiable     ")
        } else if item.price == 0 {
            attributeString = NSMutableAttributedString(string: "Free       ")
        } else {
            attributeString = NSMutableAttributedString(string: "\(item.price)₸     ")
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
        attributeString.append(attrString)
        if item.discountedPrice == item.price {
            cell.priceLabel.attributedText = attrString
        } else {
            cell.priceLabel.attributedText = attributeString
        }
        
        cell.indexPath = indexPath
        cell.delegate = self
        cell.timeLabel.text = "Posted " + Helper.getReverse(timestamp: item.timestamp)
        if item.urls?.count ?? 0 > 0 {
            cell.mainImage.setImage(from: URL(string: item.urls![0]))
        } else {
            cell.mainImage.image = UIImage(named: item.category)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
            
        header.titleLabel.text = section==0 ? "My items" : "My favourites"
        header.detailLabel.text = ""
        header.topView.backgroundColor = .clear
        header.bottomView.backgroundColor = .clear
    
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = indexPath.section==0 ? items.filter({$0.1})[indexPath.row].0 : items.filter({!$0.1})[indexPath.row].0
        performSegue(withIdentifier: "showItem", sender: item)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    func fetchItems() {
        let liked = UserDefaults.standard.object(forKey: "savedItems")
        let favourites : [String: Bool] = liked == nil ? [:] : liked as! [String: Bool]
        self.items = []
        
        Item.getDefaultItem { (items) in
            self.items.removeAll(where: {$0.0.female == false})
            items.forEach { (item) in
                if item.author.uid == Auth.auth().currentUser?.uid || item.author.uid == UserDefaults.standard.value(forKey: "anonymousId") as! String {
                    self.items.append((item, true))
                } else if favourites.contains(where: {$0.key == item.id}){
                    self.items.append((item, false))
                }
            }
            self.tableView.reloadData()
        }
        Item.getFemaleItems { (items) in
            self.items.removeAll(where: {$0.0.female == true})
            items.forEach { (item) in
                if item.author.uid == Auth.auth().currentUser?.uid || item.author.uid == UserDefaults.standard.value(forKey: "anonymousId") as! String {
                    self.items.append((item, true))
                } else if favourites.contains(where: {$0.key == item.id}){
                    self.items.append((item, false))
                }
            }
            self.tableView.reloadData()
        }
    }
}



extension FavoritesViewController: RemoveFav {
    
    
    
    func remove(indexPath: IndexPath) {
        
    }
    
    
    func remove(_ indexPath: IndexPath) {
        let item = indexPath.section==0 ? items.filter({$0.1})[indexPath.row].0 : items.filter({!$0.1})[indexPath.row].0
        
        if indexPath.section == 0 {
            
            let alert = UIAlertController(title: "Delete " + item.title, message: "You cannot restore the item", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                item.firebaseDelete { (message) in
                    if message == .error {
                        SPAlert.present(title: "Failed to delete", preset: .error)
                    } else {
                        SPAlert.present(title: "Succefully deleted", preset: .done)
                    }
                }
                alert.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let liked = UserDefaults.standard.object(forKey: "savedItems")
            var favourites : [String: Bool] = liked == nil ? [:] : liked as! [String: Bool]
            
            if favourites.contains(where: {$0.0 == item.id}) {
                favourites.removeValue(forKey: item.id)
            }
            UserDefaults.standard.set(favourites, forKey: "savedItems")
        }
        fetchItems()
    }
    
}
