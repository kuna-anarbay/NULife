//
//  FilterViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 3/2/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit

protocol filterItems {
    func filter(categories: [String], sort: String)
}

class FilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var sortCollectionView: UICollectionView!
    @IBOutlet weak var categoriesCollectionVIew: UICollectionView!
    var delegate: filterItems?
    var selectedCategories : [String] = []
    let sorts : [String] = ["Date: newest to oldest", "Date: oldest to newest", "Price: high to low", "Price: low to high"]
    var sortBy: String = "Date: newest to latest"
    let categories = ["Services", "Jobs", "Transport", "Home&Kitchen", "Clothes", "Electronics", "Hobby", "Beauty&care", "Books", "Food", "Home", "Kitchen", "Others", "Ladies", "Buy", "Sell", "Free", "Negotiable"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sortCollectionView.delegate = self
        sortCollectionView.dataSource = self
        sortCollectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        categoriesCollectionVIew.delegate = self
        categoriesCollectionVIew.dataSource = self
        categoriesCollectionVIew.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    

    
    @IBAction func donePressed(_ sender: Any) {
        delegate?.filter(categories: selectedCategories, sort: sortBy)
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sortCollectionView {
            return sorts.count
        } else {
            return categories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        cell.backView.layer.cornerRadius = 4
        
        if collectionView == sortCollectionView {
            cell.label.text = sorts[indexPath.row]
            if sortBy == sorts[indexPath.row] {
                cell.label.textColor = .white
                cell.backView.backgroundColor = UIColor(named: "Main color")
            } else {
                cell.label.textColor = UIColor(named: "Text color")
                cell.backView.backgroundColor = UIColor(named: "Background color")
            }
        } else {
            cell.label.text = categories[indexPath.row]
            if selectedCategories.contains(categories[indexPath.row]) {
                cell.label.textColor = .white
                cell.backView.backgroundColor = UIColor(named: "Main color")
            } else {
                cell.label.textColor = UIColor(named: "Text color")
                cell.backView.backgroundColor = UIColor(named: "Background color")
            }
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == sortCollectionView {
            self.sortBy = sorts[indexPath.row]
        } else {
            if let index = selectedCategories.firstIndex(of: categories[indexPath.row]) {
                selectedCategories.remove(at: index)
            } else {
                selectedCategories.append(categories[indexPath.row])
            }
        }
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == sortCollectionView {
            return CGSize(width: self.sortCollectionView.bounds.width, height: 32)
        } else {
            return CGSize(width: self.categoriesCollectionVIew.bounds.width/2 - 8, height: 32)
        }
    }
    
}
