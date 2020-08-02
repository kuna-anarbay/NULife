//
//  TitleListViewController.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 11/15/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import RealmSwift


protocol SelectEventTopicProtocol {
    func select(topic: String)
    func select(professor: String)
}

class TitleListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var navTitle: UINavigationBar!
    
    enum state {
        case location
        case topic
        case professor
    }
    
    var delegate : SelectEventTopicProtocol!
    var current_state : state = .location
    var item_list = [String]()
    var filtered_list = [String]()
    var title_string = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        switch current_state {
        case .location:
            navTitle.topItem?.title = "My locations"
            searchBar.placeholder = "Enter a location"
            break
        case .topic:
            navTitle.topItem?.title = "My topics"
            searchBar.placeholder = "Enter a topic"
            break
        default:
            navTitle.topItem?.title = "My professors"
            searchBar.placeholder = "Enter a professor"
            break
        }
        searchBar.text = title_string
        
        tableView.delegate = self
        tableView.dataSource = self
        
        filtered_list = item_list
    }
   
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
    
    @IBAction func donePressed(_ sender: Any) {
        switch current_state {
        case .professor:
            self.dismiss(animated: true) {
                self.delegate.select(professor: self.title_string)
            }
        default:
            self.dismiss(animated: true) {
                self.delegate.select(topic: self.title_string)
            }
        }
    }
    
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}



extension TitleListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered_list.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filtered_list[indexPath.row]
        if title_string == filtered_list[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        title_string = filtered_list[indexPath.row]
        switch current_state {
        case .professor:
            self.dismiss(animated: true) {
                self.delegate.select(professor: self.title_string)
            }
        default:
            self.dismiss(animated: true) {
                self.delegate.select(topic: self.title_string)
            }
        }
    }
    
}



extension TitleListViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            title_string = searchText
            filtered_list = item_list.filter { $0.uppercased().contains(searchText.uppercased()) == true }
        } else {
            filtered_list = Array(item_list)
        }
        tableView.reloadData()
    }
}
