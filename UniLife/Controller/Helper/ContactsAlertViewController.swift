//
//  ContactsAlertViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 2/13/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import SPAlert


class ContactsAlertViewController: UIViewController, MyContactsAlertViewControllerProtocol {
    

    @IBOutlet weak var tableView: UITableView!
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
    var blurEffectView = UIVisualEffectView()
    var contacts: [[String: String]] = []
    var selectedContacts: [[String: String]] = []
    var itemId: String = ""
    var callState: Bool = true
    var delegate: MyContactsAlertViewControllerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.blurEffectView = UIVisualEffectView(effect: self.blurEffect)
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.alpha = 0.5
        self.view.addSubview(self.blurEffectView)
        self.view.bringSubviewToFront(self.blurEffectView)
        self.view.bringSubviewToFront(tableView)
        tableView.reloadData()
        self.tableView.layer.cornerRadius = 12
        self.tableView.heightConstraint?.constant = CGFloat((contacts.count+2)*48-2)
    }
}


extension ContactsAlertViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count + 2
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.row == contacts.count + 1 {
            cell.textLabel?.text = callState ? "Cancel" : "Next"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .link
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        } else {
            if indexPath.row == 0 {
                if callState {
                    cell.textLabel?.text = "Contact the seller"
                    cell.imageView?.image = nil
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.textColor = .label
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                } else {
                    cell.textLabel?.text = "Add your contacts"
                    cell.imageView?.image = nil
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.textColor = .label
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                }
            } else {
                let contact = contacts[indexPath.row - 1]
                if contact["type"] != "request" {
                    if !callState {
                        cell.accessoryType = self.selectedContacts.contains(contact) ? .checkmark : .none
                    }
                    cell.imageView?.image = UIImage.by(name: contact["type"]!)
                    cell.imageView?.tintColor = UIColor.by(name: contact["type"]!)
                    cell.textLabel?.text = contact["data"]!
                } else {
                    cell.textLabel?.text = "Send request"
                    cell.imageView?.image = UIImage(systemName: "arrowshape.turn.up.left")
                    cell.imageView?.tintColor = .lightGray
                }
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == contacts.count + 1 {
            if !callState {
                delegate.sendContacts(contacts: selectedContacts)
            }
            self.dismiss(animated: true, completion: nil)
        } else if indexPath.row != 0 {
            if callState {
                switch contacts[indexPath.row - 1]["type"]! {
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
                    let storyboard = UIStoryboard(name: "Helper", bundle: nil)
                    let myAlert = storyboard.instantiateViewController(withIdentifier: "myContactsAlert") as! MyContactsAlertViewController
                    myAlert.delegate = self
                    self.presentAsStork(myAlert, height: nil, showIndicator: true, showCloseButton: true)
                }
            } else {
                let contact = contacts[indexPath.row - 1]
                if let index = selectedContacts.firstIndex(of: contact){
                    selectedContacts.remove(at: index)
                } else {
                    selectedContacts.append(contact)
                }
                tableView.reloadData()
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    func sendRequest(request: Request) {
        request.firebaseAdd(itemId: itemId) { (message) in
            if message == .success {
                SPAlert.present(message: "Successfully requested")
            } else {
                SPAlert.present(message: "Failed to request")
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func sendContacts(contacts: [[String : String]]) {
        
    }
}
