//
//  CourseDetailViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/7/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SPAlert

class CourseDetailViewController: UIViewController {

    //MARK: Setup fields
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    var documentInteractionController = UIDocumentInteractionController()
    var fileURL : URL?
    
    var course : Course!
    var deadline: Deadline!
    var event: ClubEvent!
    var currentState : courseDetailState = .add
    var delegate: SetupCoursesViewControllerProtocol?
    
    var picker: UIPickerView!
    var toolBar: UIToolbar!
    
    var reminderList = [ ("Not specified", -1), ("5 minutes", 5), ("10 minutes", 10), ("15 minutes", 15), ("20 minutes", 20), ("30 minutes", 30), ("45 minutes", 45), ("1 hour", 60), ("1.5 hours", 90), ("2 hours", 120), ("3 hourse", 180), ("6 hours", 360),  ("12 hourse", 720)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDesign()
        setupTableView()
        documentInteractionController.delegate = self
        if currentState != .deadline && currentState != .event {
            retrieveCourse()
        }
    }
    
    
    
    //MARK: Done pressed
    @IBAction func donePressed(_ sender: Any) {
        switch currentState {
            case .add:
                delegate?.add(at: course)
                self.dismiss(animated: true, completion: nil)
            break
            case .remove:
                delegate?.remove(at: course)
                self.dismiss(animated: true, completion: nil)
            break
            case .edit:
                let alert = UIViewController.getAlert("Updating course...")
                self.present(alert, animated: true, completion: nil)
                course.update(url: fileURL, completion: { (message) in
                    alert.dismiss(animated: true, completion: nil)
                    if message == .success {
                        SPAlert.present(title: "Successfully updated", preset: .done)
                    } else {
                        SPAlert.present(title: "Failed to update", preset: .done)
                    }
                    self.dismiss(animated: true, completion: nil)
                })
            break
            case .deadline:
                delegate?.add(at: deadline.asTask)
                self.dismiss(animated: true, completion: nil)
            break
            default:
                delegate?.add(at: event)
                self.dismiss(animated: true, completion: nil)
            break
        }
    }
    
    
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectColor" {
            let dest = segue.destination as! SelectorViewController
            dest.delegate = self
            dest.color = course.color
            dest.currentState = .color
        } else if segue.identifier == "showLocations" {
            let dest = segue.destination as! ShowTopicsViewController
            dest.delegate = self
            dest.selectedLocation = course.professor
            dest.currentState = .professors
        }
    }
    
}



extension CourseDetailViewController: UITextFieldDelegate, NewQuestionProtocol {
    
    func doneTopic(text: String) {
        
    }
    
    func doneBody(text: String) {
        
    }
    
    func switchChanged(isOn: Bool) {
        
    }
    
    func beginEditing(topic: Bool) {
        
    }
    
    func selectedTopic(topic: String) {
        
    }
    
    func selectedLocation(location: String) {
        course.professor = location
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
}


//MARK: Setup design
extension CourseDetailViewController {
 
    func setupDesign(){
        doneButton.layer.cornerRadius = 8
        
        switch currentState {
            case .add:
                doneButton.setTitle("Add a course", for: .normal)
            break
            case .edit:
                doneButton.setTitle("Edit course", for: .normal)
            break
            case .remove:
                doneButton.setTitle("Remove course", for: .normal)
                doneButton.backgroundColor = UIColor(named: "Danger color")
            break
            case .deadline:
                doneButton.setTitle("Add deadline", for: .normal)
            break
            default:
                doneButton.setTitle("Add event", for: .normal)
            break
        }
    }
}



//MARK:- BACK END
extension CourseDetailViewController {
    
    //MARK: Retrieve course from firebase
    func retrieveCourse(){
        let color = self.course.color
        let longTitle = self.course.longTitle
        Course.getByIdAndSection(course.id, course.section) { (course) in
            self.course = course
            self.course.color = color
            self.course.longTitle = longTitle
            self.tableView.reloadData()
        }
    }
}


//MARK:- Setup table view
extension CourseDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func setupTableView(){
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CourseHeaderTableViewCell", bundle: nil) , forCellReuseIdentifier: "courseHeaderCell")
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentState == .edit ? 2 : 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return (currentState == .deadline || currentState == .event) ? 4 : 3
        } else {
           return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "courseHeaderCell", for: indexPath) as! CourseHeaderTableViewCell
            
            switch currentState {
            case .deadline:
                cell.title.text = deadline.title
                cell.detail.text = deadline.courseId + " \u{2022} Section " + deadline.section
                break
            case .event:
                cell.title.text = event.title
                cell.detail.text = event.club["title"]
                break
            default:
                cell.title.text = course.title
                cell.detail.text = course.longTitle
                break
            }
            
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row < 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                
                switch indexPath.row {
                    case 0:
                        if currentState == .event {
                            cell.textLabel?.text = "Date and time"
                            cell.detailTextLabel?.text = Helper.displayDayMonth(timestamp: event.start) + ", " + Helper.display24HourTime(timestamp: event.start) + "-" + Helper.display24HourTime(timestamp: event.end)
                            cell.accessoryType = .disclosureIndicator
                        } else if currentState != .deadline {
                            cell.textLabel?.text = currentState != .edit ? "Select your section" : "Professor"
                            cell.detailTextLabel?.text = currentState != .edit ? course.section : course.professor
                            cell.accessoryType = .disclosureIndicator
                        } else {
                            cell.textLabel?.text = "Date and time"
                            cell.detailTextLabel?.text = Helper.displayDate24HourFull(timestamp: deadline.timestamp)
                            cell.accessoryType = .disclosureIndicator
                        }
                        break
                    case 1:
                        if currentState == .event {
                            cell.textLabel?.text = "Location"
                            cell.detailTextLabel?.text = event.location
                            cell.accessoryType = .disclosureIndicator
                        } else if currentState != .deadline {
                            cell.textLabel?.text = "Change color"
                            let colorView = UIView(frame: CGRect(x: self.tableView.bounds.width-58, y: 10, width: 24, height: 24))
                            colorView.backgroundColor = UIColor(hexString: course.color)
                            colorView.layer.cornerRadius = 12
                            cell.addSubview(colorView)
                            cell.detailTextLabel?.text = ""
                            cell.accessoryType = .disclosureIndicator
                        } else {
                            cell.textLabel?.text = "Location"
                            cell.detailTextLabel?.text = deadline.location
                            cell.accessoryType = .disclosureIndicator
                            
                        }
                        break
                    default:
                        if currentState == .event {
                            cell.textLabel?.text = "Author"
                            cell.detailTextLabel?.text = event.club["title"]
                            cell.accessoryType = .disclosureIndicator
                        } else if currentState != .deadline {
                            cell.textLabel?.text = currentState != .edit ? "Students" : "Change syllabus"
                            if currentState == .edit {
                                cell.detailTextLabel?.text = fileURL != nil ? fileURL?.absoluteURL.lastPathComponent : "\(course.syllabus != "" ? "Change" : "Add syllabus")"
                            } else {
                                cell.detailTextLabel?.text = "\(course.students.count) students"
                            }
                            cell.accessoryType = .disclosureIndicator
                        } else {
                            cell.textLabel?.text = "Author"
                            cell.detailTextLabel?.text = deadline.author.name
                            cell.accessoryType = .disclosureIndicator
                        }
                        break
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
                cell.textLabel?.text = "Details"
                if currentState == .deadline {
                    cell.detailTextLabel?.text = deadline.details
                } else {
                    cell.detailTextLabel?.text = event.details
                }
                
                
                return cell
            }
            
        } else {
            if currentState == .event {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                
                cell.textLabel?.text = "Set reminder"
                cell.detailTextLabel?.text = reminderList.first(where: {$0.1 == event.reminder})?.0
                cell.accessoryType = .disclosureIndicator
                
                return cell
            } else if currentState != .deadline {
                let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
                if course.syllabus != "" {
                    cell.textLabel?.textColor = UIColor(named: "Main color")
                } else {
                    cell.textLabel?.textColor = UIColor(named: "Muted text color")
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                
                cell.textLabel?.text = "Set reminder"
                cell.detailTextLabel?.text = reminderList.first(where: {$0.1 == deadline.reminder})?.0
                cell.accessoryType = .disclosureIndicator
                
                return cell
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75
        } else {
            if (currentState == .deadline || currentState == .event) && indexPath.row == 3 {
                return 98
            }
            return 44
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
        
        if currentState == .event {
            if section == 1 {
                header.titleLabel.text = "Event info".uppercased()
            } else if section == 2 {
                header.titleLabel.text = "setup event details".uppercased()
            }
        } else if currentState != .deadline {
            if section == 1 {
                header.titleLabel.text = currentState != .edit ? "Course info".uppercased() : "Change course info".uppercased()
            } else if section == 2 {
                header.titleLabel.text = ""
            }
        } else {
            if section == 1 {
                header.titleLabel.text = "Deadline info".uppercased()
            } else if section == 2 {
                header.titleLabel.text = "setup deadline details".uppercased()
            }
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
            return (currentState == .deadline || currentState == .event) ? 38 : 16
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentState {
            case .add:
                if indexPath.section == 1 {
                    if indexPath.row == 0 {
                        var list = [String]()
                        for i in 1...45 {
                            list.append("\(i)")
                        }
                        let sheet = UIAlertController.getActionSheet(list: list, selectedIndex: list.firstIndex(of: course.section))
                        sheet.delegate = self
                        self.present(sheet, animated: true, completion: nil)
                        
                    } else if indexPath.row == 1 {
                        performSegue(withIdentifier: "selectColor", sender: nil)
                    }
                } else if indexPath.section == 2 {
                    if course.syllabus != "" {
                        let storageId = Constants.syllabusRef.child(course.id).child(course.section)
                        
                        
                        self.storeAndShare(name: "Syllabus", ref: storageId, controller: self.documentInteractionController, contentType: "")
                    } else {
                        SPAlert.present(message: "No syllabus found")
                    }
                    
                }
            case .deadline:
                if indexPath.section == 2 {
                    addPicker()
                }
                tableView.deselectRow(at: indexPath, animated: true)
            case .event:
                if indexPath.section == 2 {
                    addPicker()
                }
                tableView.deselectRow(at: indexPath, animated: true)
            case .edit:
                if indexPath.section == 1 {
                    if indexPath.row == 0 {
                        performSegue(withIdentifier: "showLocations", sender: nil)
                    } else if indexPath.row == 1 {
                        performSegue(withIdentifier: "selectColor", sender: nil)
                    } else {
                        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
                        documentPicker.delegate = self
                        self.present(documentPicker, animated: true, completion: nil)
                    }
                }
        default:
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



//MARK:- Protocols
extension CourseDetailViewController: SelectorViewControllerProtocol, AlertViewControllerDelegate {
    
    
    func selectedRow(row: Int) {
        
    }
    
    func selectedString(string: String) {
        course.section = string
        retrieveCourse()
    }
    
    
    
    func selectColor(at color: String) {
        course.color = color
        tableView.reloadData()
    }
    
    func selectColorAndIcon(at color: String, at icon: String) {
        return
    }
    
}


//MARK:- Toolbar
extension CourseDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func addPicker(){
        if currentState != .deadline && currentState != .event {
           
        }
        
        picker = UIPickerView.init()
        picker.delegate = self
        picker.backgroundColor = UIColor.secondarySystemBackground
        picker.setValue(UIColor.label, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: self.view.bounds.size.height - 300, width: self.view.bounds.size.width, height: 300)
        self.view.addSubview(picker)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: self.view.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(donePicker))
        ]
        self.view.addSubview(toolBar)
    }
    
    
    //TODO: DONE SELECTING A SECTION
    @objc func donePicker(){
        picker.removeFromSuperview()
        toolBar.removeFromSuperview()
        
        if (currentState != .deadline && currentState != .event) {
            retrieveCourse()
        }
        
        tableView.reloadData()
    }
    
    //TODO: Number of components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //TODO: Number of Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (currentState != .deadline && currentState != .event) ? 45 : reminderList.count
    }
    
    //TODO: Values of the rows
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (currentState != .deadline && currentState != .event) ? "\(row + 1)" : reminderList[row].0
    }
    
    //DidSelect the rows
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (currentState != .deadline && currentState != .event) {
            course.section = "\(row+1)"
        } else if currentState == .deadline {
            deadline.reminder = reminderList[row].1
        } else {
            event.reminder = reminderList[row].1
        }
    }
}



//MARK:- Configure UIDocumentPicker
extension CourseDetailViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            fileURL = url.absoluteURL
            tableView.reloadData()
        }
    }
}
