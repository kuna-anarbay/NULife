//
//  MyCategoriesViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/27/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert

class MyCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let categories = ["Services", "Jobs", "Transport", "Kitchen", "Clothes", "Electronics", "Hobby", "Beauty&care", "Books", "Food", "Home", "Others", "Buy", "Female", "Free"]
    let help = ["How to register for a class", "How to make aad", "How to add new resource", "Book"]
    var booking : [(String, Bool, [Room])] = []
    let defaults = UserDefaults.standard
    var currentState : profileState = .categories
    var indicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
        if defaults.array(forKey: "myCategories") == nil {
            defaults.set([], forKey: "myCategories")
        }
        
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        switch currentState {
        case .categories:
            title = "My categories"
        case .help:
            title = "Help"
        case .booking:
            title = "Room booking"
            fetchRooms()
        }
    }
    
    
    
    func fetchRooms(){
        booking = []
        Constants.bookingRefs.observe(.value) { (snapshot) in
            for child in snapshot.children {
                let room = Room(child as! DataSnapshot)
                if let index = self.booking.firstIndex(where: {$0.0 == room.block}){
                    self.booking[index].2.append(room)
                } else {
                    self.booking.append((room.block, false, [room]))
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBooking" {
            let dest = segue.destination as! BookingViewController
            dest.room = sender as! Room
        }
    }
    

}



extension MyCategoriesViewController {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentState == .booking ? booking.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentState {
        case .categories:
            return categories.count
        case .help:
            return help.count
        case .booking:
            return booking[section].1 ? booking[section].2.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentState {
        case .categories:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.accessoryView?.removeFromSuperview()
            
            cell.textLabel?.text = categories[indexPath.row]
            var notifications = UserDefaults.standard.dictionary(forKey: "notifications")
            notifications = notifications != nil ? notifications as! [String: String] : [:]
            cell.imageView?.image = UIImage(named: categories[indexPath.row])?.sd_resizedImage(with: CGSize(width: 30, height: 30), scaleMode: .aspectFit)
            if notifications?.contains(where: {$0.key == categories[indexPath.row].lowercased()}) ?? false {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            
            return cell
        case .help:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.textLabel?.text = help[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case .booking:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.textLabel?.text = booking[indexPath.section].2[indexPath.row].room
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentState {
        case .categories:
            
            let alert = UIViewController.getAlert("Loading...")
            self.present(alert, animated: true, completion: nil)
            
            var notifications = UserDefaults.standard.dictionary(forKey: "notifications")
            notifications = notifications != nil ? notifications as! [String: String] : [:]
            let category = categories[indexPath.row].lowercased()
            if notifications?.contains(where: {$0.key == category}) ?? false {
                Constants.currentUserRef.child("notifications").child(category).removeValue { (err, ref) in
                    alert.dismiss(animated: true, completion: nil)
                    self.tableView.reloadData()
                }
            } else {
                if category == "female" {
                    User.setupCurrentUser { (user) in
                        if user.getIsFemale() {
                            Constants.currentUserRef.child("notifications").child(category).setValue("category") { (err, ref) in
                                alert.dismiss(animated: true, completion: nil)
                                self.tableView.reloadData()
                            }
                        } else {
                            alert.dismiss(animated: true) {
                                SPAlert.present(title: "You are not a NU Lady", preset: .error)
                            }
                        }
                    }
                } else {
                    Constants.currentUserRef.child("notifications").child(category).setValue("category") { (err, ref) in
                        alert.dismiss(animated: true, completion: nil)
                        self.tableView.reloadData()
                    }
                }
            
            }
            break
        case .help:
            break
        case .booking:
            performSegue(withIdentifier: "showBooking", sender: booking[indexPath.section].2[indexPath.row])
            break
        }
        
        tableView.reloadData()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentState == .booking {
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
            
            header.titleLabel.bottomConstraint?.constant = 11.5
            header.titleLabel.text = "Block " + booking[section].0
            header.titleLabel.font = UIFont(name: "SFProDisplay-medium", size: 17)
            header.detailLabel.text = ""
            header.topView.backgroundColor = .clear
            header.bottomView.backgroundColor = .clear
        
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openSection)))
            
            return header
        }
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return currentState == .booking ? 44 : 0
    }

    
    @objc func openSection(sender: UITapGestureRecognizer){
        // Get the view
        let index = (sender.view as! SectionHeader).section
        
        booking[index].1 = !booking[index].1
        
        tableView.reloadSections([index], with: .automatic)
        
    }
}
