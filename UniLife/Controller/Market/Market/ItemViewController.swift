//
//  ItemViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/17/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert



class ItemViewController: UIViewController {

    
    @IBOutlet weak var sellerStar: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var likeOrEditButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var userRating: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var liked = [String]()
    var item: Item = Item()
    var authorRating: Float = 0.0
    var newRequest: Request = Request()
    var rateAlertController = UIAlertController()
    var rateStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        let windowScene = UIApplication.shared
                        .connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .first
        if let windowScene = windowScene as? UIWindowScene {
            let statusbarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: windowScene.statusBarManager?.statusBarFrame.size.height ?? 20))
            
            statusbarView.backgroundColor = UIColor(named: "White color")
            view.addSubview(statusbarView)
        }
        self.tableView.setContentOffset(.init(x: 0, y: 180), animated: false)
        let defaults = UserDefaults.standard.array(forKey: "likedItems")
        liked = defaults == nil ? [] : defaults as! [String]
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rateUser))
        userView.addGestureRecognizer(tapGesture)
        setupButtons()
        setupTableView()
        fetchItem()
        setupUser()
        // Do any additional setup after loading the view.
    }
    
    
    func setupUser(){
        fetchSeller()
        userImage.layer.cornerRadius = userImage.bounds.width/2
        userName.text = item.author.name
    }
    
    
    
    

    @IBAction func callPressed(_ sender: Any) {
        
        if !isSeller() {
            let storyboard = UIStoryboard(name: "Helper", bundle: nil)
            
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            if let contacts = item.contacts {
                let myAlert = storyboard.instantiateViewController(withIdentifier: "contactsAlert") as! ContactsAlertViewController
                myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                myAlert.contacts = contacts
                myAlert.contacts.append([
                    "type": "request",
                    "data": "Send request"
                ])
                myAlert.itemId = item.id
                self.present(myAlert, animated: true, completion: nil)
            } else {
                let myAlert = storyboard.instantiateViewController(withIdentifier: "myContactsAlert") as! MyContactsAlertViewController
                myAlert.delegate = self
                self.presentAsStork(myAlert, height: nil, showIndicator: true, showCloseButton: true)
            }
        } else {
            SPAlert.present(title: "Don't contact yourself", image: UIImage(systemName: "exclamationmark.circle")!)
        }
    }
    
    
    func configurationTextField(textField: UITextField!)
    {
        textField.placeholder = "Enter details. Example: price you want"
        if let text = textField.text {
            self.newRequest.details = text
        }
    }
    
    
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func likeOrEditPressed(_ sender: Any) {
        if isSeller() {
            let alert = UIAlertController(title: "Edit your item", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Reactive item", style: .default, handler: { (action) in
                self.item.reActivate { (message) in
                    if message == .error {
                        SPAlert.present(title: "Failed to reactivate", preset: .error)
                    } else {
                        SPAlert.present(title: "Succefully reactivated", preset: .done)
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Edit item details", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "editItem", sender: self.item)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            if let index = liked.firstIndex(of: item.id) {
                liked.remove(at: index)
            } else {
                liked.append(item.id)
            }
            UserDefaults.standard.set(liked, forKey: "likedItems")
        }
        
        setupButtons()
    }
    
    
    @IBAction func deletePressed(_ sender: Any) {
        let alert = UIViewController.actionAlert("Item can't be restored") {
            self.dismiss(animated: true) {
                self.item.firebaseDelete() { message in
                    if message == .error {
                        SPAlert.present(title: "Failed to delete", preset: .error)
                    } else {
                        SPAlert.present(title: "Succefully deleted", preset: .done)
                    }
                }
            }
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func isSeller()-> Bool {
        return Auth.auth().currentUser?.uid == item.author.uid || UserDefaults.standard.value(forKey: "anonymousId") as! String == item.author.uid
    }
    
    
    func setupButtons(){
        dismissButton.addShadow(radius: dismissButton.bounds.width/2)
        deleteButton.addShadow(radius: deleteButton.bounds.width/2)
        likeOrEditButton.addShadow(radius: likeOrEditButton.bounds.width/2)
        callButton.addShadow(radius: 18)
        
        if !isSeller() {
            if liked.contains(item.id) {
                likeOrEditButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            } else {
                likeOrEditButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            }
            likeOrEditButton.tintColor = .systemRed
            deleteButton.isHidden = true
        } else {
            likeOrEditButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            likeOrEditButton.tintColor = .systemOrange
            deleteButton.isHidden = false
        }
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editItem" {
            let destNav = segue.destination as! UINavigationController
            let dest = destNav.viewControllers[0] as! NewItemViewController
            dest.newItem = sender as! Item
            dest.editingMode = true
        }
    }
    

}




//MARK:- Setup table view
extension ItemViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if tableView.contentOffset.y < -100 {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            let transition: CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromBottom
            self.view.window!.layer.add(transition, forKey: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissButton.alpha = (100 + tableView.contentOffset.y)/100
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "ItemHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "ItemHeader")
        let sectionHeader = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(sectionHeader, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        }
        return isSeller() ? item.requests.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            //MARK: IMAGE cell
            if let urls = item.urls, urls.count > 0 {
                let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ItemImageTableViewCell
                
                imageCell.mainImage.setImage(from: URL(string: urls[0]))
                imageCell.urls = urls
                
                return imageCell
            } else {
                let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ItemImageTableViewCell
                imageCell.mainImage.image = nil
                imageCell.urls = []
                
                return imageCell
            }
        } else if indexPath.section == 1 {
            //MARK: DETAIL and CATEGORY cell
            if indexPath.row == 0 {
                let detailCell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
                detailCell.titleLabel.text = item.details
                
                return detailCell
            } else {
                let categoryCell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! ItemCategoriesTableViewCell
                
                categoryCell.categories = item.categoriesList
                
                return categoryCell
            }
        } else {
            //MARK: REQUEST cell
            let requestCell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
            
            let request = item.requests[indexPath.row]
            requestCell.textLabel?.text = request.name
            requestCell.detailTextLabel?.text = request.details
            
            return requestCell
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            //MARK: Section 0
            return nil
        } else if section == 1 {
            
            //MARK: Section 1
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "ItemHeader") as! ItemHeader
            
            header.backView.layer.cornerRadius = item.urls?.count ?? 0 > 0 ? 12 : 0
            header.backView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            header.titleLabel.text = item.title
            var attributeString: NSMutableAttributedString = NSMutableAttributedString()
            if item.price == -1 {
                attributeString = NSMutableAttributedString(string: "Negotiable")
            } else if item.price == 0 {
                attributeString = NSMutableAttributedString(string: "Free")
            } else {
                attributeString = NSMutableAttributedString(string: "\(item.price)₸")
            }
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray3, range: NSMakeRange(0, attributeString.length))
            var attrString = NSMutableAttributedString()
            if item.discountedPrice == -1 {
                attrString = NSMutableAttributedString(string: "    Negotiable")
            } else if item.discountedPrice == 0 {
                attrString = NSMutableAttributedString(string: "    Free")
            } else {
                attrString = NSMutableAttributedString(string: "    \(item.discountedPrice)₸")
            }
            attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen, range: NSMakeRange(0, attrString.length))
            attributeString.append(attrString)
            
            if item.price == item.discountedPrice {
                if item.discountedPrice == -1 {
                    header.priceLabel.text = "Negotiable"
                } else if item.discountedPrice == 0 {
                    header.priceLabel.text = "Free"
                } else {
                    header.priceLabel.text = "\(item.discountedPrice)₸"
                }
            } else {
                header.priceLabel.attributedText = attributeString
            }
            
            header.timeLabel.text = Helper.getReverse(timestamp: item.lastActive)
            
            return header
        } else {
            //MARK: Section 2
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
            
            header.titleLabel.text = "Requests"
            header.detailLabel.text = "\(item.requests.count) requests"
            header.bottomView.backgroundColor = .clear
        
            return isSeller() ? header : nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if section == 1 {
            return 100
        } else {
            return isSeller() ? 38 : 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if item.urls?.count ?? 0 > 0 {
                //MARK: CHANCGE OCCURRED
                if self.view.bounds.height > 700 {
                    return tableView.bounds.height-144
                } else {
                    return tableView.bounds.height-120
                }
            } else {
                return 36
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                return UITableView.automaticDimension
            } else {
                return 114
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let request = item.requests[indexPath.row]
            let storyboard = UIStoryboard(name: "Helper", bundle: nil)
            let myAlert = storyboard.instantiateViewController(withIdentifier: "contactsAlert") as! ContactsAlertViewController
            myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            myAlert.contacts = request.contacts ?? []
            self.present(myAlert, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @objc func rateUser(){
        
        if !isSeller() {
            rateAlertController = UIAlertController(title: item.author.name, message: "Please rate the item", preferredStyle: .alert)
            
            
            let tempView = UIView(frame: CGRect(x: 0, y: 80, width: 270, height: 45))
            
            let rect = CGRect(x: 0, y: 0, width: 270, height: 45)
            rateStackView = UIStackView(frame: rect)
            for i in 0...4 {
                let button = UIButton(frame: CGRect(x: 55+i*32, y: 0, width: 32, height: 45))
                button.tag = i + 1
                button.setImage(UIImage(systemName: "star"), for: .normal)
                button.addTarget(self, action: #selector(rateSeller), for: .touchDown)
                rateStackView.addSubview(button)
            }
            tempView.addSubview(rateStackView)
            
            
            let emptyAction = UIAlertAction(title: "\t\t\t\t\t\t", style: .default, handler: {(alert: UIAlertAction!) in})
            

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in })

            rateAlertController.addAction(emptyAction)
            rateAlertController.addAction(cancelAction)
            rateAlertController.view.addSubview(tempView)

            self.present(rateAlertController, animated: true, completion: nil)
        }
    }
    
    
    
    @objc func rateSeller(sender: UIButton){
        
        for i in 1...5 {
            if i <= sender.tag {
                (rateStackView.viewWithTag(i) as! UIButton).setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                (rateStackView.viewWithTag(i) as! UIButton).setImage(UIImage(systemName: "star"), for: .normal)
            }
            
        }
        

        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { timer in
            Constants.userRatingRef.child(self.item.author.uid).child(self.item.id).child(Auth.auth().currentUser!.uid).setValue(sender.tag)
            self.rateAlertController.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
}



//MARK:- Fetch data
extension ItemViewController: MyContactsAlertViewControllerProtocol {
    
    
    func sendRequest(request: Request) {
        request.firebaseAdd(itemId: item.id) { (message) in
            if message == .success {
                SPAlert.present(message: "Successfully requested")
            } else {
                SPAlert.present(message: "Failed to request")
            }
        }
    }
    
    
    func sendContacts(contacts: [[String : String]]) {
        
    }
    
    
    func fetchItem(){
        Item.getOne(item.id, female: item.female) { (item) in
            if item.notNull {
                self.item = item
                self.fetchSeller()
                self.tableView.setContentOffset(.init(x: 0, y: 180), animated: false)
                self.tableView.reloadData()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func fetchSeller(){
        Constants.userRatingRef.child(item.author.uid).observe(.value) { (snapshot) in
            var rating_count : Float = 0.0
            var rating_sum : Float = 0.0
            for child in snapshot.children {
                let value = (child as! DataSnapshot).value as! NSDictionary
                for baby in value {
                    rating_count += 1
                    rating_sum += baby.value as! Float
                }
            }
            
            self.authorRating = rating_count==0 ? 0 : rating_sum/rating_count
            if self.authorRating == 0 {
                self.sellerStar.image = UIImage(systemName: "star.slash")
            } else if self.authorRating > 0 && self.authorRating <= 2.5 {
                self.sellerStar.image = UIImage(systemName: "star.lefthalf.fill")
            } else {
                self.sellerStar.image = UIImage(systemName: "star.fill")
            }
            if self.item.author.name == "Anonymous" {
                self.userImage.image = UIImage(named: "user")
            } else {
                self.userImage.setImage(from: URL(string: self.item.author.image))
            }
            
            self.userRating.text = NSString(format: "%.01f", self.authorRating) as String
        }
    }
}
