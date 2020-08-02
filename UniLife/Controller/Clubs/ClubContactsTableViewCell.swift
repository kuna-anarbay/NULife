//
//  ClubContactsTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/13/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit

class ClubContactsTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    
    
    
    @IBOutlet weak var tableView: UITableView!
    var contacts: [[String: String]] = [] {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath))
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contact = contacts[indexPath.row]
        
        
        cell.imageView?.image = UIImage.by(name: contact["type"]!)
        cell.imageView?.tintColor = UIColor.by(name: contact["type"]!)
        cell.textLabel?.text = contact["data"]!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch contacts[indexPath.row]["type"]! {
        case "location":
            self.tableView.deselectRow(at: indexPath, animated: true)
        case "email":
            guard let email = URL(string: "mailto:" + contacts[indexPath.row]["data"]!) else { return }
            UIApplication.shared.open(email)
            break
        case "phone":
            guard let number = URL(string: "tel://" + contacts[indexPath.row]["data"]!) else { return }
            UIApplication.shared.open(number)
            break
        case "vk":
            guard let vk = URL(string: "https://vk.com/" + contacts[indexPath.row]["data"]!) else { return }
            UIApplication.shared.open(vk)
        case "facebook":
            guard let fb = URL(string: "fb://profile/" + contacts[indexPath.row]["data"]!) else { return }
            UIApplication.shared.open(fb)
        case "instagram":
            guard let instagram = URL(string: "https://www.instagram.com/" + contacts[indexPath.row]["data"]!) else { return }
            UIApplication.shared.open(instagram)
        case "telegram":
            guard let telegram = URL(string: "https://telegram.me/" + contacts[indexPath.row]["data"]!) else { return }
            UIApplication.shared.open(telegram)
        case "link":
            guard let link = URL(string: contacts[indexPath.row]["data"]!) else { return }
            UIApplication.shared.open(link)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
