//
//  NewItemViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/20/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import YPImagePicker
import SPAlert


class NewItemViewController: UIViewController {

    
    @IBOutlet weak var imagesCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    var images = [UIImage]()
    var newItem = Item()
    var editingMode: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        textView.layer.cornerRadius = 8
        setupFields()
        priceTextField.delegate = self
        setupDesign()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func addImagePressed(_ sender: Any) {
        if !editingMode {
            let imagePicker = ImagePicker.getYPImagePicker()
            images = []
            imagePicker.didFinishPicking { [unowned imagePicker] items, cancelled in
                UINavigationBar.appearance().tintColor = UIColor(named: "Main color")
                if !cancelled {
                    for item in items {
                        switch item {
                            case .photo(let photo):
                                self.images.append(photo.image)
                            case .video( _):
                                continue
                        }
                    }
                } else {
                    self.images = []
                }
                _ = self.setFields()
                self.setupFields()
                self.collectionView.reloadData()
                imagePicker.dismiss(animated: true, completion: nil)
            }
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        self.newItem.setAnonymous()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if checkFields() {
            let alert = UIViewController.getAlert("Uploading item...")
            self.present(alert, animated: true, completion: nil)
            if editingMode {
                newItem.firebaseEdit { (message) in
                    if message == .error {
                        SPAlert.present(title: "Failed to update", preset: .error)
                        alert.dismiss(animated: true, completion: nil)
                    } else {
                        SPAlert.present(title: "Succefully updated", preset: .done)
                        alert.dismiss(animated: true) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                newItem.firebaseAdd(self.images) { (message) in
                    if message == .error {
                        alert.dismiss(animated: true, completion: nil)
                        SPAlert.present(title: "Failed to add", preset: .error)
                    } else {
                        SPAlert.present(title: "Succefully added", preset: .done)
                        alert.dismiss(animated: true) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func contactsPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Helper", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "contactsAlert") as! ContactsAlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        let localContacts = UserDefaults.standard.dictionary(forKey: "contacts") as? [String: String]
        if let keys = localContacts?.keys {
            myAlert.contacts = Array(keys).map { (key) -> [String: String] in
                return [
                    "type": key,
                    "data": localContacts![key]!
                ]
            }
            myAlert.selectedContacts = newItem.contacts ?? []
            myAlert.delegate = self
            myAlert.callState = false
            self.present(myAlert, animated: true, completion: nil)
        } else {
            let alert = UIViewController.getEmptyAlert("Please fill contact info in the profile settings", "")
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func categoriesPressed(_ sender: Any) {
        if setFields() {
           performSegue(withIdentifier: "addCategory", sender: nil)
        }
    }
    
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         _ = self.setFields()
        self.setupFields()
        if segue.identifier == "addCategory" {
            let dest = segue.destination as! CategoriesViewController
            dest.selectedCategory = newItem.category
            dest.sell = newItem.sell
            dest.female = newItem.female
            dest.delegate = self
        }
    }
    

}


extension NewItemViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MyContactsAlertViewControllerProtocol {

    

    func sendRequest(request: Request) {
        
    }
    
    func sendContacts(contacts: [[String : String]]) {
        newItem.contacts = contacts
        self.contactsCollectionView.reloadData()
    }
    
    func setupDesign(){
        titleTextField.delegate = self
        priceTextField.delegate = self
        titleTextField.layer.cornerRadius = 12
        textView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        contactsCollectionView.delegate = self
        contactsCollectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        categoriesButton.layer.cornerRadius = 8
        contactButton.layer.cornerRadius = 8
        addImageButton.layer.cornerRadius = 8
    }
    
    func setupFields(){
        if newItem.urls?.count == 0 && self.images.count == 0 {
            imagesCollectionHeight.constant = 0
            self.view.layoutIfNeeded()
        } else {
            imagesCollectionHeight.constant = 90
            self.view.layoutIfNeeded()
        }
        
        categoriesLabel.text = newItem.categoriesString
        
        switchControl.isOn = newItem.author.name == "Anonymous"
        titleTextField.text = newItem.title
        if editingMode {
            switch newItem.discountedPrice {
            case -1:
                priceTextField.text = "Negotiable"
            case 0:
                priceTextField.text = "Free"
            default:
                priceTextField.text = "\(newItem.discountedPrice)"
            }
        } else {
            switch newItem.price {
            case -1:
                priceTextField.text = "Negotiable"
            case 0:
                priceTextField.text = "Free"
            default:
                priceTextField.text = "\(newItem.price)"
            }
        }
        
        textView.text = newItem.details?.count == 0 ? "Enter details" : newItem.details
        textView.textColor = newItem.details?.count == 0 ? .lightGray : UIColor(named: "Text color")
    }
    
    func setFields() -> Bool {
        if titleTextField.text != nil {
            newItem.title = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if priceTextField.text != nil {
            if editingMode {
                newItem.discountedPrice = Int(priceTextField.text!) ?? -1
            } else {
                newItem.price = Int(priceTextField.text!) ?? -1
            }
        }
        
        if textView.text != nil || textView.text.trimmingCharacters(in: .whitespacesAndNewlines) != "Enter details" {
            newItem.details = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return true
    }
    
    
    func checkFields() -> Bool {
        if titleTextField.text != nil {
            if titleTextField.text!.count > 0 {
                newItem.title = titleTextField.text!
            } else {
                SPAlert.present(message: "Please fill title")
                return false
            }
        }
        
        
        if priceTextField.text != nil {
            if editingMode {
                newItem.discountedPrice = Int(priceTextField.text!) ?? -1
            } else {
                newItem.price = Int(priceTextField.text!) ?? -1
            }
        }
        
        
        if textView.text != nil && textView.text.trimmingCharacters(in: .whitespacesAndNewlines) != "Enter details" {
            newItem.details = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        
        if newItem.isValid.0 == false {
            SPAlert.present(message: newItem.isValid.1)
            return false
        }
        
        return true
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if editingMode {
            return collectionView == self.collectionView ? (newItem.urls?.count ?? 0) : (newItem.contacts?.count ?? 0)
        } else {
            return collectionView == self.collectionView ? images.count : (newItem.contacts?.count ?? 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageItemCell", for: indexPath) as! ItemImageCollectionViewCell
        
        if collectionView == self.collectionView {
            cell.button.isHidden = false
            if editingMode {
                cell.imageView.setImage(from: URL(string: self.newItem.urls![indexPath.row]))
            } else {
                cell.imageView.image = images[indexPath.row]
                cell.imageView.contentMode = .scaleAspectFill
                let ratio = images[indexPath.row].size.height / 90
                cell.imageView.frame = CGRect(x: 0, y: 0, width: images[indexPath.row].size.height/ratio, height: 90)
            }
            
            cell.layer.cornerRadius = 8
            cell.index = indexPath
            cell.delegate = self
        } else {
            if let contact = newItem.contacts?[indexPath.row] {
                cell.imageView.image = UIImage.by(name: contact["type"]!)
            }
        }
        
        
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !editingMode && collectionView == self.collectionView {
            self.images.remove(at: indexPath.row)
            
            collectionView.reloadData()
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionView {
            if editingMode {
                return CGSize(width: 90, height: 90)
            } else {
                let ratio = images[indexPath.row].size.height / 90
                return CGSize(width: images[indexPath.row].size.height/ratio, height: 90)
            }
        } else {
            return CGSize(width: 30, height: 30)
        }
    }
    
    
}


extension NewItemViewController : UITextViewDelegate, UITextFieldDelegate, selectCategories {
    
    
    func remove(_ images: IndexPath) {
        if !self.editingMode {
            self.images.remove(at: images.row)
            self.collectionView.reloadData()
        }
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
         let numberOfChars = newText.count
         return numberOfChars <= 800
     }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let numberOfChars = newText.count
        return numberOfChars <= 50
    }
     
    
    
    
    func remove(_ images: Int) {
        
    }
    
    
    
    
    
    func select(_ categories: (String, Bool, Bool)) {
        newItem.category = categories.0
        newItem.sell = categories.1
        newItem.female = categories.2
        setupFields()
        _ = setFields()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == priceTextField && (priceTextField.text == "Negotiable") {
            priceTextField.text = ""
        } else if textField == priceTextField && priceTextField.text == "Free" {
            priceTextField.text = "0"
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == priceTextField {
            switch priceTextField.text {
            case "":
                priceTextField.text = "Negotiable"
            case "0":
                priceTextField.text = "Free"
            default:
                break
            }
            _ = setFields()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            priceTextField.becomeFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
        
        return true
    }
    
    
    
    //MARK: TEXT VIEW BEGIN EDITING
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(named: "Text color")
        }
    }
    
    
    //MARK: TEXT VIEW END EDITING
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter details"
            textView.textColor = UIColor.lightGray
        }
    }
}
