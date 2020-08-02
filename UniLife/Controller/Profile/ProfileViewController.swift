//
//  ProfileViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var user = User()
    var profileImage = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        fetchUser()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func fetchUser() {
        User.getCurrentUser { (user) in
            self.user = user
            self.tableView.reloadData()
        }
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCategories" {
            let dest = segue.destination as! MyCategoriesViewController
            dest.currentState = sender as! profileState
        }
    }
    

}


extension ProfileViewController {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            (cell.viewWithTag(1) as! UIImageView).sd_setImage(with: URL(string: user.image), placeholderImage: nil, options: .refreshCached, context: nil)
            (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = 44
            (cell.viewWithTag(2) as! UILabel).text = user.name
            (cell.viewWithTag(3) as! UILabel).text = "\(user.getYear()) year student \n" + user.getFaculty()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            
            switch indexPath.row {
            case 0:
                cell.imageView?.tintColor = UIColor(hex: "#F6971F")
                cell.imageView?.image = UIImage(systemName: "rectangle.stack.fill.badge.person.crop")
                cell.textLabel?.text = "My categories"
                break
            case 1:
                cell.imageView?.tintColor = UIColor(hex: "#57608C")
                cell.imageView?.image = UIImage(systemName: "bag.fill")
                cell.textLabel?.text = "Saved items"
                break
            case 2:
                cell.imageView?.tintColor = UIColor(hex: "#0085E3")
                cell.imageView?.image = UIImage(systemName: "info.circle.fill")
                cell.textLabel?.text = "Terms"
                break
            default:
                cell.imageView?.tintColor = UIColor(hex: "#255016")
                cell.imageView?.image = UIImage(systemName: "captions.bubble")
                cell.textLabel?.text = "Contact NULife"
                break
            }
            
            return cell
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section==0 ? 120 : 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var state : profileState!
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                state = .categories
                performSegue(withIdentifier: "showCategories", sender: state)
                break
            case 1:
                let storyboard = UIStoryboard(name: "Market", bundle: nil)
                let navController = storyboard.instantiateViewController(identifier: "showFav") as! UINavigationController
                let likedViewController = navController.viewControllers[0]
                likedViewController.navigationController?.navigationBar.prefersLargeTitles = true
                self.show(likedViewController, sender: nil)
                break
            case 2:
                if let url = URL(string: "https://nulife.kz/terms") {
                  UIApplication.shared.open(url)
                }
                break
            case 3:
                if let url = URL(string: "https://t.me/nulife_contact") {
                  UIApplication.shared.open(url)
                }
                break
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
