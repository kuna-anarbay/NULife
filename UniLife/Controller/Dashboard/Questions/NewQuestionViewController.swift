//
//  NewQuestionViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/9/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import RealmSwift
import YPImagePicker
import SPAlert

class NewQuestionViewController: UIViewController {

    
    @IBOutlet weak var askButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var newQuestion = Question()
    var currentState: newQuestionState = .normal
    var course : Course!
    
    var imagePicker = YPImagePicker()
    var images = [UIImage]()
    var topicBeginEditing: Bool = true
    var editState = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        setupTableView()
        if !editState {
            newQuestion.section = course.section
            newQuestion.courseId = course.id
        }
        tableView.reloadData()
        
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func askPressed(_ sender: Any) {
        
        if currentState == .editing {
            bringNormalView()
            self.view.endEditing(true)
        } else {
            if newQuestion.isValid.0 {
                if editState {
                    self.newQuestion.firebaseEdit { (message) in
                        if message == .error {
                            SPAlert.present(title: "Failed to add", preset: .error)
                        } else {
                            SPAlert.present(title: "Successfully added", preset: .done)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    if Helper.connectedToNetwork() {
                        let alert = UIViewController.getAlert("Uploading question...")
                        self.present(alert, animated: true, completion: nil)
                        self.newQuestion.firebaseAdd(images: images) { message in
                            alert.dismiss(animated: true) {
                                if message == .error {
                                    SPAlert.present(title: "Failed to add", preset: .error)
                                } else {
                                    SPAlert.present(title: "Successfully added", preset: .done)
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } else {
                        let alert = UIAlertController(title: "No internet connection", message: "Send question without images?", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Send without images", style: .default, handler: { (action) in
                            self.newQuestion.firebaseAdd(images: []) { message in
                                alert.dismiss(animated: true, completion: nil)
                            }
                            self.dismiss(animated: true, completion: nil)
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                            alert.dismiss(animated: true) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                SPAlert.present(message: newQuestion.isValid.1)
            }
        }
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTopics" {
            let dest = segue.destination as! ShowTopicsViewController
            dest.selectedTopic = newQuestion.topic
            dest.delegate = self
            dest.courseId = self.course.id
            dest.currentState = .topics
        }
    }
    

}


//MARK:- Setup table view
extension NewQuestionViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func setupTableView(){
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
            return 1
        } else if section == 1 {
            return 3
        } else {
           return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextViewTableViewCell
            cell.delegate = self
            cell.question = newQuestion
            
            if currentState == .editing {
                if newQuestion.hasTitle() {
                    cell.topicTextView?.text = newQuestion.title
                    cell.topicTextView?.textColor = .label
                } else {
                    cell.topicTextView?.text = "Question title"
                    cell.topicTextView?.textColor = UIColor(named: "Muted text color")
                }
                
                if newQuestion.hasBody() {
                    cell.bodyTextView?.text = newQuestion.details
                    cell.bodyTextView?.textColor = .label
                } else {
                    cell.bodyTextView?.text = "Question body"
                    cell.bodyTextView?.textColor = UIColor(named: "Muted text color")
                }
            } else {
                if newQuestion.hasTitle() {
                    cell.topicTextView?.text = newQuestion.title
                    cell.topicTextView?.textColor = .label
                } else {
                    cell.topicTextView?.text = "Question title"
                    cell.topicTextView?.textColor = UIColor(named: "Muted text color")
                }
                
                if !newQuestion.hasBody() {
                    cell.bodyTextView?.text = "Question body"
                    cell.bodyTextView?.textColor = UIColor(named: "Muted text color")
                } else {
                    cell.bodyTextView?.text = newQuestion.details
                    cell.bodyTextView?.textColor = .label
                }
            }
            
            return cell
        } else if indexPath.section == 1 {
            
            switch indexPath.row {
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                    cell.textLabel?.text = "Ask from"
                    if newQuestion.section == "0" {
                        cell.detailTextLabel?.text = "All sections"
                    } else if newQuestion.section == course.section {
                        cell.detailTextLabel?.text = "My section"
                    }
                    cell.accessoryType = .disclosureIndicator
                
                    return cell
                
                case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
                    
                    cell.textLabel?.text = "Ask anonymously"
                    cell.customSwitch.isOn = newQuestion.author.name == "Anonymous"
                    cell.delegate = self
                    
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                    cell.textLabel?.text = "Related topic"
                    cell.textLabel?.textColor = .label
                    cell.detailTextLabel?.text = newQuestion.topic
                    cell.accessoryType = .disclosureIndicator
                    
                    return cell
                    
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Upload images"
            cell.textLabel?.textColor = UIColor(named: "Main color")
            cell.detailTextLabel?.text = "\(images.count) images"
            cell.accessoryType = .disclosureIndicator
            
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if currentState == .editing {
                return tableView.bounds.height
            } else {
               return 150
            }
        } else {
            return 44
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
        if section == 1 {
            header.titleLabel.text = "QUESTION DETAILS".uppercased()
        } else if section == 2 {
            header.titleLabel.text = ""
        }
        
        header.detailLabel.text = ""
        
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if section == 1 {
            return 38
        } else {
           return 16
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 0:
                changeState()
            case 1:
                switch indexPath.row {
                    case 0:
                        if !editState {
                            performSegue(withIdentifier: "showTopics", sender: nil)
                        }
                    case 1:
                        if !editState {
                            newQuestion.section = newQuestion.section != "0" ? "0" : course.section
                            tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
                        }
                    default:
                        newQuestion.setAnonymous()
                        tableView.reloadRows(at: [IndexPath(row: 2, section: 1)], with: .automatic)
                }
            default:
                selectImages()
                tableView.deselectRow(at: indexPath, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func selectImages(){
        if !editState {
            imagePicker = ImagePicker.getYPImagePicker()
            self.images = []
            imagePicker.didFinishPicking { [unowned imagePicker] items, cancelled in
                UINavigationBar.appearance().tintColor = UIColor(named: "Main color")
                if !cancelled {
                    for item in items {
                        switch item {
                        case .photo(let photo):
                            self.images.append(photo.image)
                        default:
                            break
                        }
                    }
                } else {
                    self.images = []
                }
                imagePicker.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func changeState() {
        if currentState == .normal {
            currentState = .editing
            askButton.title = "Done writing"
            tableView.isScrollEnabled = false
            tableView.reloadSections([0], with: .none)
            (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextViewTableViewCell).topicTextView.becomeFirstResponder()
        }
    }
    
    
    func bringNormalView(){
        if currentState == .editing {
            currentState = .normal
            askButton.title = "Ask"
            tableView.isScrollEnabled = true
            tableView.reloadSections([0], with: .none)
        }
    }
    
}


//MARK: Protocols
extension NewQuestionViewController: NewQuestionProtocol {
    
    func selectedLocation(location: String) {
        
    }
    
    
    func selectedTopic(topic: String) {
        newQuestion.topic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        tableView.reloadData()
    }
    
    
    func doneTopic(text: String) {
        newQuestion.title = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func doneBody(text: String) {
        newQuestion.details = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func switchChanged(isOn: Bool) {
        newQuestion.setAnonymous()
    }
    
    func beginEditing(topic: Bool) {
        topicBeginEditing = topic
        self.changeState()
    }
    
}
