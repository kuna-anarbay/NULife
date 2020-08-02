//
//  ShowTopicsViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/9/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert

class ShowTopicsViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    var courseId : String = String()
    
    var currentState: showListState = .topics
    
    var topics = [String]()
    var filteredTopics = [String]()
    var selectedTopic : String!
    
    var locations = [String]()
    var filteredLocations = [String]()
    var selectedLocation : String!
    
    var delegate: NewQuestionProtocol!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        if currentState == .professors {
            textField.becomeFirstResponder()
        }
        setupTextField() 
        setupTableView()
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        fetchData()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func donePressed(_ sender: Any) {
        if currentState == .topics {
            if topics.contains(selectedTopic) {
                delegate.selectedTopic(topic: selectedTopic)
                if self.navigationController != nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
                   self.dismiss(animated: true, completion: nil)
                }
            } else {
                if let text = textField.text {
                    delegate.selectedTopic(topic: text.trimmingCharacters(in: .whitespacesAndNewlines))
                    if self.navigationController != nil {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                       self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else if currentState == .locations {
            if let text = textField.text {
                let location = text.trimmingCharacters(in: .whitespacesAndNewlines)
                
                delegate.selectedLocation(location: location)
                if self.navigationController != nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
                   self.dismiss(animated: true, completion: nil)
                }
            }
        } else if currentState == .professors {
            if let text = textField.text {
                let location = text.trimmingCharacters(in: .whitespacesAndNewlines)
                
                delegate.selectedLocation(location: location)
                if self.navigationController != nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
                   self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: Fetch topics
extension ShowTopicsViewController: UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= 40
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if currentState == .professors {
            if let text = textField.text {
                let location = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !locations.contains(location) {
                    locations.append(location)
                    UserDefaults.standard.set(locations, forKey: "professors")
                }
                delegate.selectedLocation(location: location)
                if self.navigationController != nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
                   self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        return true
    }
    
    
    @objc func textChanged(){
        if currentState == .topics, let text = textField.text {
            selectedTopic = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        fetchData()
    }
    
    
    
    
    
    func setupTextField(){
        if currentState == .topics {
            textField.text = selectedTopic
        } else if currentState == .locations {
            textField.text = selectedLocation
            title = "Select location"
        } else {
            textField.text = selectedLocation
            title = "Select professor"
        }
    }
    
    
    func fetchData(){
        if currentState == .topics {
            Constants.topicsRef.child(courseId).observe(.value) { (snapshot) in
                self.topics = []
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    self.topics.append(snap.value as! String)
                }
                self.filterData()
            }
        } else if currentState == .locations {
            locations = UserDefaults.standard.stringArray(forKey: "locations") ?? []
            self.filterData()
        } else {
            locations = UserDefaults.standard.stringArray(forKey: "professors") ?? []
            self.filterData()
        }
        
    }
    
    func filterData(){
        if currentState == .topics {
            if let text = textField.text, text.count > 0 {
                filteredTopics = topics.filter({ (topic) -> Bool in
                    return topic.lowercased().contains(text.lowercased())
                })
            } else {
                filteredTopics = topics
            }
        } else if currentState == .locations {
            if let text = textField.text, text.count > 0 {
                filteredLocations = locations.filter({$0.lowercased().contains(text.lowercased())})
            } else {
                filteredLocations = locations
            }
        } else {
            if let text = textField.text, text.count > 0 {
                filteredLocations = locations.filter({$0.lowercased().contains(text.lowercased())})
            } else {
                filteredLocations = locations
            }
        }
        
        
        tableView.reloadData()
    }
}

//MARK:- Setup table view
extension ShowTopicsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentState == .topics {
            return filteredTopics.count
        } else {
            return filteredLocations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if currentState == .topics {
            cell.textLabel?.text = filteredTopics[indexPath.row]
            cell.accessoryType = filteredTopics[indexPath.row] == selectedTopic ? .checkmark : .none
        } else {
            cell.textLabel?.text = filteredLocations[indexPath.row]
            cell.accessoryType = filteredLocations[indexPath.row] == selectedLocation ? .checkmark : .none
        }
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
        
        if currentState == .topics {
            header.titleLabel.text = "Enter a topic title"
        } else if currentState == .locations {
            header.titleLabel.text = "Enter a location"
        } else {
            header.titleLabel.text = "Enter professor name"
        }
        
        header.detailLabel.text = ""
        
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if currentState == .topics {
            selectedTopic = filteredTopics[indexPath.row]
            filterData()
            delegate.selectedTopic(topic: selectedTopic)
            if self.navigationController != nil {
                self.navigationController?.popViewController(animated: true)
            } else {
               self.dismiss(animated: true, completion: nil)
            }
        } else if currentState == .locations {
            selectedLocation = filteredLocations[indexPath.row]
            filterData()
            delegate.selectedLocation(location: selectedLocation)
            if self.navigationController != nil {
                self.navigationController?.popViewController(animated: true)
            } else {
               self.dismiss(animated: true, completion: nil)
            }
        } else {
            selectedLocation = filteredLocations[indexPath.row]
            filterData()
            delegate.selectedLocation(location: selectedLocation)
            if self.navigationController != nil {
                self.navigationController?.popViewController(animated: true)
            } else {
               self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
