//
//  TopHeader.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

protocol TopHeaderProtocol {
    func segmentChanged(_ firstSegment: Bool)
    func optionsPressed(_ firstSegment: Bool)
    func filterPressed(_ firstSegment: Bool)
    func sortPressed(_ firstSegment: Bool)
    func categoriesPressed()
    func searchPressed(_ text: String)
    func sortCategory(_ category: String)
}


class TopHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var secondaryView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    var delegate: TopHeaderProtocol!
    var selectedCategory = ""
    var categories = ["Services", "Jobs", "Transport", "Home&Kitchen", "Clothes", "Electronics", "Hobby", "Beauty&care", "Books", "Food", "Home", "Kitchen", "Others", "Buy", "Ladies", "Free"]
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        delegate.segmentChanged(segmentedControl.selectedSegmentIndex == 0)
    }
    
    
    @IBAction func optionsPressed(_ sender: Any) {
        delegate.optionsPressed(segmentedControl.selectedSegmentIndex == 0)
    }
    
    
    @IBAction func filterPressed(_ sender: Any) {
        delegate.filterPressed(segmentedControl.selectedSegmentIndex == 0)
    }
    
    
    @IBAction func sortPressed(_ sender: Any) {
        delegate.sortPressed(segmentedControl.selectedSegmentIndex == 0)
    }
    
    
    @IBAction func categoriesPressed(_ sender: Any) {
        delegate.categoriesPressed()
    }
    
    
}


extension TopHeader: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.label.text = categories[indexPath.row]
        if selectedCategory == categories[indexPath.row] {
            cell.label.textColor = .white
            cell.backView.backgroundColor = UIColor(named: "Main color")
        } else {
            cell.label.textColor = UIColor(named: "Text color")
            cell.backView.backgroundColor = UIColor(named: "Background color")
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedCategory == categories[indexPath.row] {
            delegate.sortCategory("")
        } else {
            delegate.sortCategory(categories[indexPath.row])
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (categories[indexPath.row].count+1)*12, height: 30)
        
    }
    
}



extension TopHeader: UISearchBarDelegate {
    
    func setupSearchBar(){
        let button = stackView.viewWithTag(3) as! UIButton
        button.layer.cornerRadius = 8
        let favButton = stackView.viewWithTag(1) as! UIButton
        favButton.layer.cornerRadius = 8
        searchBar.delegate = self
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        if let text = searchBar.text {
            delegate.searchPressed(text)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            delegate.searchPressed("")
        }
    }
}

