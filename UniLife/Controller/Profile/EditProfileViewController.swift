//
//  EditProfileViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/22/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import YPImagePicker
import Firebase
import GoogleSignIn
import SPAlert


class EditProfileViewController: UIViewController {

    
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var femaleRequestText: UILabel!
    @IBOutlet weak var femaleSwitch: UISwitch!
    @IBOutlet weak var femaleText: UILabel!
    @IBOutlet weak var femaleCheckbox: UIImageView!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var majorField: UITextField!
    @IBOutlet weak var schoolField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    var image: YPMediaPhoto?
    let schoolPicker = UIPickerView()
    let facultyPicker = UIPickerView()
    let yearPicker = UIPickerView()
    var currentUser = User()
    var contacts: [String: String] = UserDefaults.standard.dictionary(forKey: "contacts") as? [String : String] ?? [:]
    let contactsList = ["Location", "Phone", "Vk", "Telegram", "Email", "Instagram", "Facebook", "Link"]
    var newContact: [String: String] = [:]
    let picker = UIPickerView()
    let alert = UIAlertController(title: "New contact", message: nil, preferredStyle: .alert)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupAlert()
        
        if Auth.auth().currentUser != nil {
            fetchUser()
            setupDesign()
        }
        tableView.heightConstraint?.constant = CGFloat(contacts.count*44)
        
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addContact(_ sender: Any) {
        self.getAlert(newContact.count == 0 ? nil : newContact)
    }
    
    
    @IBAction func signOut(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
            User.unRegisterToken()
            
            try firebaseAuth.signOut()
            try Constants.realm.write {
                Constants.realm.deleteAll()
            }
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            
            
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
            viewController.modalPresentationStyle = .fullScreen
            
            self.present(viewController, animated:true, completion:nil)
        } catch _ as NSError {
            return
        }
    }
    
    
    @IBAction func requestAsFemale(_ sender: UISwitch) {
        let requested = UserDefaults.standard.bool(forKey: "female_request")
        if requested {
        Constants.femaleRequestsRef.child(Auth.auth().currentUser!.uid).removeValue(completionBlock: { (error, ref) in
                UserDefaults.standard.set(false, forKey: "female_request")
            self.setupDesign()
            SPAlert.present(title: "Request was removed", preset: .done)
            })
        } else {
            Constants.femaleRequestsRef.child(Auth.auth().currentUser!.uid).setValue(true) { (err, ref) in
                UserDefaults.standard.set(true, forKey: "female_request")
                self.setupDesign()
                SPAlert.present(title: "Admin will contact you in 1 day", preset: .magic)
            }
        }
    }
    
    
    @IBAction func chagenImagePressed(_ sender: Any) {
        let imagePicker = ImagePicker.getYPImagePicker(1)
        imagePicker.didFinishPicking { [unowned imagePicker] items, cancelled in
            UINavigationBar.appearance().tintColor = UIColor(named: "Main color")
            if !cancelled {
                for item in items {
                    switch item {
                        case .photo(let photo):
                            self.image = photo
                        case .video( _):
                            break
                    }
                }
            } else {
                self.image = nil
            }
            self.profileImage.image = self.image?.originalImage
            imagePicker.dismiss(animated: true, completion: nil)
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func savePressed(_ sender: Any) {
        if image != nil {
            if Helper.connectedToNetwork() {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                let alert = UIViewController.getAlert("Uploading image...")
                self.present(alert, animated: true, completion: nil)
                Constants.userImageRef.child(Auth.auth().currentUser!.uid).putData(image!.originalImage.jpegData(compressionQuality: 1)!, metadata: metadata) { (meta, error) in
                    Constants.userImageRef.child(Auth.auth().currentUser!.uid).downloadURL { (url, error) in
                        self.currentUser.image = "\(url!)"
                        alert.dismiss(animated: true) {
                            self.currentUser.saveAcademicToDB(image: nil) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            } else {
                SPAlert.present(title: "Unable to send image", message: "No internet connection. Unable to send image", preset: .error)
                self.currentUser.saveAcademicToDB(image: nil) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            currentUser.saveAcademicToDB(image: nil) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}



extension EditProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func setupToolBar(donePicker: Selector, cancelPicker: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: donePicker)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: cancelPicker)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        return toolbar
    }
    
    
    func fetchUser() {
        User.getCurrentUser { (user) in
            self.currentUser = user
            self.setupDesign()
        }
    }
    
    func setupDesign(){

        self.profileImage.sd_setImage(with: URL(string: currentUser.image), placeholderImage: nil, options: .refreshCached, context: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        addContactButton.layer.cornerRadius = 8
        
        if currentUser.getIsFemale() {
            femaleRequestText.text = "You are NU Lady"
            femaleRequestText.textColor = .systemGreen
            femaleSwitch.isHidden = true
            femaleCheckbox.isHidden = false
            femaleCheckbox.image = UIImage(systemName: "checkbox")
        } else {
            if Auth.auth().currentUser != nil {
                Constants.femaleRequestsRef.child(Auth.auth().currentUser!.uid).observe(.value) { (snapshot) in
                    
                    if let requested = snapshot.value, requested is Bool, (requested as! Bool) {
                        self.femaleRequestText.text = "Waiting for approval"
                        self.femaleRequestText.textColor = .systemOrange
                        self.femaleSwitch.isOn = true
                    } else if let requested = snapshot.value, requested is Bool, !(requested as! Bool) {
                        self.femaleRequestText.text = "Request was rejected"
                        self.femaleRequestText.textColor = .darkGray
                        self.femaleSwitch.isHidden = true
                    } else {
                        self.femaleRequestText.text = "Request as female"
                        self.femaleRequestText.textColor = .label
                        self.femaleSwitch.isOn = false
                    }
                }
                femaleSwitch.isHidden = false
                femaleCheckbox.isHidden = true
            }
        }
        
        schoolPicker.dataSource = self
        schoolPicker.delegate = self
        schoolField.text = currentUser.getSchool()
        schoolField.inputView = schoolPicker
        schoolField.inputAccessoryView = setupToolBar(donePicker: #selector(donePicker), cancelPicker: #selector(donePicker))
        
        facultyPicker.dataSource = self
        facultyPicker.delegate = self
        majorField.text = currentUser.getFaculty()
        majorField.inputView = facultyPicker
        majorField.inputAccessoryView = setupToolBar(donePicker: #selector(donePicker), cancelPicker: #selector(donePicker))
        
        yearPicker.dataSource = self
        yearPicker.delegate = self
        yearField.inputView = yearPicker
        yearField.text = "\(currentUser.getYear())"
        yearField.inputAccessoryView = setupToolBar(donePicker: #selector(donePicker), cancelPicker: #selector(donePicker))
    }
    
    @objc func donePicker() {
        self.view.endEditing(true)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case schoolPicker:
            return staticList.schools.count
        
        case facultyPicker:
            return staticList.faculties[schoolPicker.selectedRow(inComponent: 0)].count
        
        case yearPicker:
            return 4
        default:
            return contactsList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case schoolPicker:
            return staticList.schools[row]
            
        case facultyPicker:
            return staticList.faculties[schoolPicker.selectedRow(inComponent: 0)][row]
        case yearPicker:
            return "\(row + 1)"
        default:
            return contactsList[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
            case schoolPicker:
                currentUser.setSchool(at: staticList.schools[row])
                currentUser.setFaculty(at: staticList.faculties[row][0])
                
                schoolField.text = staticList.schools[row]
                majorField.text = staticList.faculties[row][0]
            
            case facultyPicker:
                currentUser.setFaculty(at: staticList.faculties[schoolPicker.selectedRow(inComponent: 0)][row])
                majorField.text = staticList.faculties[schoolPicker.selectedRow(inComponent: 0)][row]
            
            case yearPicker:
                currentUser.setYear(at: row+1)
                yearField.text = "\(row + 1)"
            default:
                alert.textFields?[0].text = contactsList[row]
        }
    }
    
}



extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let contact = Array(contacts.keys)[indexPath.row]
        cell.imageView?.image = UIImage.by(name: contact)
        cell.imageView?.tintColor = UIColor.by(name: contact)
        cell.textLabel?.text = contacts[contact]!
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[Array(contacts.keys)[indexPath.row]]
        switch Array(contacts.keys)[indexPath.row] {
        case "location":
            self.tableView.deselectRow(at: indexPath, animated: true)
        case "email":
            guard let email = URL(string: "mailto:" + (contact ?? "")) else { return }
            UIApplication.shared.open(email)
            break
        case "phone":
            guard let number = URL(string: "tel://" + (contact ?? "")) else { return }
            UIApplication.shared.open(number)
            break
        case "vk":
            guard let vk = URL(string: "https://vk.com/" + (contact ?? "")) else { return }
            UIApplication.shared.open(vk)
        case "facebook":
            guard let fb = URL(string: "fb://profile/" + (contact ?? "")) else { return }
            UIApplication.shared.open(fb)
        case "instagram":
            guard let instagram = URL(string: "https://www.instagram.com/" + (contact ?? "")) else { return }
            UIApplication.shared.open(instagram)
        case "telegram":
            guard let telegram = URL(string: "https://telegram.me/" + (contact ?? "")) else { return }
            UIApplication.shared.open(telegram)
        case "link":
            guard let link = URL(string: (contact ?? "")) else { return }
            UIApplication.shared.open(link)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
                self.tableView.heightConstraint?.constant = CGFloat(self.contacts.count*44)
                self.tableView.reloadData()
            }
            deleteAction.backgroundColor = .systemRed
            
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        } else {
            return nil
        }
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
            self.alert.textFields?[0].text = tempContact.first?.key
            self.alert.textFields?[1].text = tempContact.first?.value
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
                    self.tableView.heightConstraint?.constant = CGFloat(self.contacts.count*44)
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
}

