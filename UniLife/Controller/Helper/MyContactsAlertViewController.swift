//
//  MyContactsAlertViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 2/13/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import SPAlert


protocol MyContactsAlertViewControllerProtocol {
    func sendRequest(request: Request)
    func sendContacts(contacts: [[String: String]])
}

class MyContactsAlertViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var contacts: [String: String] = UserDefaults.standard.dictionary(forKey: "contacts") as? [String : String] ?? [:]
    let contactsList = ["Location", "Phone", "Vk", "Telegram", "Email", "Instagram", "Facebook", "Link"]
    var selectedContacts: [[String: String]] = []
    var newContact: [String: String] = [:]
    let picker = UIPickerView()
    let alert = UIAlertController(title: "New contact", message: nil, preferredStyle: .alert)
    var delegate: MyContactsAlertViewControllerProtocol!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        textView.delegate = self
        textView.layer.cornerRadius = 12
        self.setupAlert()
        picker.delegate = self
        picker.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.heightConstraint?.constant = CGFloat((contacts.count+1)*44 + 208)
        tableView.reloadData()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightText {
            textView.text = ""
            textView.textColor = UIColor.label
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count == 0 || textView.text == "Enter details" {
            textView.text = "Enter details"
            textView.textColor = UIColor.lightText
        } else {
            textView.textColor = UIColor.label
        }
    }

}



extension MyContactsAlertViewController: UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section==0 ? contacts.count : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            let contact = Array(contacts.keys)[indexPath.row]
            cell.textLabel?.textAlignment = .natural
            cell.textLabel?.textColor = .label
            cell.accessoryType = selectedContacts.contains([
                "type": contact,
                "data": contacts[contact]!,
            ]) ? .checkmark : .none
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            cell.imageView?.image = UIImage.by(name: contact)
            cell.imageView?.tintColor = UIColor.by(name: contact)
            cell.textLabel?.text = contacts[contact]!
        } else {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Send contacts"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .link
                cell.imageView?.image = nil
                cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            case 1:
                cell.textLabel?.text = "Add new contact"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .label
                cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            default:
                cell.textLabel?.text = "Cancel"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .label
                cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let contact = Array(contacts.keys)[indexPath.row]
            if let index = selectedContacts.firstIndex(of: [
                "type": contact,
                "data": contacts[contact]!,
            ]){
                selectedContacts.remove(at: index)
            } else {
                selectedContacts.append([
                    "type": contact,
                    "data": contacts[contact]!,
                ])
            }
        } else {
            switch indexPath.row {
            case 0:
                if selectedContacts.count == 0 {
                    SPAlert.present(message: "Please send at least one contact")
                } else {
                    let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="Enter details" ? "" : textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.delegate.sendRequest(request: Request(text: text, contact: selectedContacts))
                    self.dismiss(animated: true, completion: nil)
                }
                break
            case 1:
                self.getAlert(nil)
                break
            default:
                self.dismiss(animated: true, completion: nil)
            }
        }
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section == 0 {
            let temp = Array(contacts.keys)[indexPath.row]
            let contact = [temp: contacts[temp]!]
            
            
            let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, handler) in
                self.getAlert(contact)
                self.tableView.reloadData()
            }
            editAction.backgroundColor = .systemOrange
            
            let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, sourceView, handler) in
                var localContacts = UserDefaults.standard.dictionary(forKey: "contacts") as? [String: String] ?? [:]
                localContacts.removeValue(forKey: temp)
                UserDefaults.standard.setValue(localContacts, forKey: "contacts")
                self.contacts = UserDefaults.standard.dictionary(forKey: "contacts") as? [String : String] ?? [:]
                self.tableView.reloadData()
            }
            deleteAction.backgroundColor = .systemRed
            
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section==0 ? 44 : 50
    }
    
    
    func get_toolbar(done_picker: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: done_picker)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

        toolbar.setItems([spaceButton, doneButton], animated: false)
        
        return toolbar
    }
    
    @objc func done_picker(){
        self.alert.textFields?[1].becomeFirstResponder()
    }
    
    
    func getAlert(_ contact: [String: String]?) {
        if let tempContact = contact {
            self.alert.textFields?[0].text = tempContact["type"]
            self.alert.textFields?[1].text = tempContact["data"]
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func setupAlert(){
        alert.addTextField { (textfield) in
            textfield.placeholder = "Contact type"
            self.picker.dataSource = self
            self.picker.delegate = self
            textfield.inputView = self.picker
            textfield.inputAccessoryView = self.get_toolbar(done_picker: #selector(self.done_picker))
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter contact info"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if let type = self.alert.textFields?[0].text, let data = self.alert.textFields?[1].text {
                var localContacts = UserDefaults.standard.dictionary(forKey: "contacts") as? [String: String] ?? [:]
                localContacts[type.lowercased()] = data
                UserDefaults.standard.setValue(localContacts, forKey: "contacts")
                self.alert.textFields?[0].text = ""
                self.alert.textFields?[1].text = ""
                self.alert.dismiss(animated: true) {
                    self.contacts = UserDefaults.standard.dictionary(forKey: "contacts") as? [String : String] ?? [:]
                    self.tableView.reloadData()
                }
            } else {
                SPAlert.present(message: "Please fill the fields")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.alert.dismiss(animated: true, completion: nil)
        }))
        
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return contactsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return contactsList[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        alert.textFields?[0].text = contactsList[row]
    }
    
    
}
