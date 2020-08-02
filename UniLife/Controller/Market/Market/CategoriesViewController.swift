//
//  CategoriesViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/20/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import YPImagePicker
import SPAlert

protocol selectCategories {
    func select(_ categories: (String, Bool, Bool))
    func remove(_ images: Int)
    func remove(_ images: IndexPath)
}


class CategoriesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var categories = ["Services", "Jobs", "Transport", "Clothes", "Electronics", "Hobby", "Beauty&care", "Books", "Food", "Home", "Kitchen", "Others"]
    var selectedCategory = "Food"
    var sell: Bool = true
    var female: Bool = false
    
    var delegate: selectCategories!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupDesign()
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func donePressed(_ sender: Any) {
        delegate.select((selectedCategory, sell, female))
        navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupDesign(){
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return categories.count
        } else if section == 1 {
            return 2
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            cell.accessoryType = selectedCategory == categories[indexPath.row] ? .checkmark : .none
            cell.imageView?.image = UIImage(named: categories[indexPath.row])?.sd_resizedImage(with: CGSize(width: 30, height: 30), scaleMode: .aspectFit)
            cell.textLabel?.text = categories[indexPath.row]
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.accessoryType = sell ? .none : .checkmark
            } else {
                cell.accessoryType = !sell ? .none : .checkmark
            }
            cell.imageView?.image = UIImage(named: indexPath.row==0 ? "Buy" : "Sell")?.sd_resizedImage(with: CGSize(width: 30, height: 30), scaleMode: .aspectFit)
            cell.textLabel?.text = indexPath.row==0 ? "Buy" : "Sell"
        } else {
            cell.accessoryType = !female ? .none : .checkmark
            cell.imageView?.image = UIImage(named: "Female")?.sd_resizedImage(with: CGSize(width: 30, height: 30), scaleMode: .aspectFit)
            cell.textLabel?.text = "Ladies"
        }
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedCategory = categories[indexPath.row]
        } else if indexPath.section == 1 {
            sell = indexPath.row != 0
        } else {
            User.setupCurrentUser { (user) in
                if user.getIsFemale() {
                    self.female = !self.female
                } else {
                    SPAlert.present(title: "You are not a NU Lady", preset: .error)
                }
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
            
        switch section {
        case 0:
            header.titleLabel.text = "Categories"
            break
        case 1:
            header.titleLabel.text = "Sell or Buy"
            break
        default:
            header.titleLabel.text = "Ladies category"
            break
        }
            
        header.detailLabel.text = ""
        header.topView.backgroundColor = .clear
        header.bottomView.backgroundColor = .clear
    
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
}

