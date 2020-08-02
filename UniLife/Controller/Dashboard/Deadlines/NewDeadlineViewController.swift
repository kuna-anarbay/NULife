//
//  NewDeadlineViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/12/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import SPAlert
import YPImagePicker
import MobileCoreServices
import SPAlert

class NewDeadlineViewController: UIViewController {


    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    var newDeadline = Deadline()
    
    
    var newResource: Resource?
    var courseId: String!
    var section: String!
    
    var currentState: newQuestionState = .normal
    var currentSelector: pickerState = .reminder
    
    var imagePicker = YPImagePicker()
    let picker = UIPickerView()
    let datePicker = UIDatePicker()
    var toolBar = UIToolbar()
    
    
    var reminderList = [ ("Not specified", -1), ("5 minutes", 5), ("10 minutes", 10), ("15 minutes", 15), ("20 minutes", 20), ("30 minutes", 30), ("45 minutes", 45), ("1 hour", 60), ("1.5 hours", 90), ("2 hours", 120), ("3 hourse", 180), ("6 hours", 360),  ("12 hourse", 720)]
    var assessmentList = ["Quiz", "Lab", "Midterm", "Final", "Homework"]
    var assessment : (String, String) = ("Quiz", "1")
    var semesterList = ["Fall", "Spring", "Summer"]
    var professorList = [String]()
    
    var images = [UIImage]()
    var fileURL : URL? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setupTableView()
        textField.delegate = self
        newDeadline.courseId = courseId
        newDeadline.section = section
       
        if currentState == .resource {
            textField.isEnabled = false
            textField.text = courseId
            newResource = Resource()
            newResource?.courseId = courseId
            title = "New resource"
            addButton.title = "Add"
        }
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func donePressed(_ sender: Any) {
        if currentState == .editing {
            bringNormalView()
            self.view.endEditing(true)
        } else if currentState == .normal {
            if let text = self.textField.text {
                self.newDeadline.title = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if newDeadline.isValid.0 {
                    let alert = UIViewController.getAlert("Uploading...")
                    self.present(alert, animated: true, completion: nil)
                    self.newDeadline.firebaseAdd { (message) in
                        alert.dismiss(animated: true) {
                            if message == .success {
                                SPAlert.present(title: "Successfully added", preset: .done)
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                SPAlert.present(title: "Failed to add", preset: .error)
                            }
                        }
                    }
                } else {
                    SPAlert.present(message: newDeadline.isValid.1)
                }
            } else {
                SPAlert.present(message: "Please write a title")
            }
        } else {
            if resourceFilled() {
                if Helper.connectedToNetwork() {
                    let alert = UIViewController.getAlert("Uploading resource...")
                    self.present(alert, animated: true, completion: nil)
                    self.newResource?.firebaseAdd(fileURL: self.fileURL, images: self.images) { (message) in
                        alert.dismiss(animated: true) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "No internet connection", message: "Please connect to the internet and send again", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        alert.dismiss(animated: true) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func resourceFilled() -> Bool {
        
        if newResource!.semester.count == 0 {
            SPAlert.present(message: "Please select semester")
            return false
        }
        
        if newResource!.assessment.count == 0 {
            SPAlert.present(message: "Please select assessment type")
            return false
        }
        
        if self.fileURL == nil && self.images.count == 0 {
            SPAlert.present(message: "Please select a file")
            return false
        }
        
        return true
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func changeState() {
        if currentState == .normal {
            currentState = .editing
            addButton.title = "Done writing"
            tableView.isScrollEnabled = false
            tableView.reloadSections([0], with: .none)
        }
    }
    
    
    func bringNormalView(){
        if currentState == .editing {
            if newResource == nil {
                currentState = .normal
            } else {
                currentState = .resource
            }
            addButton.title = "Add"
            tableView.isScrollEnabled = true
            tableView.reloadSections([0], with: .none)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        if self.view.subviews.contains(toolBar) {
            toolBar.removeFromSuperview()
        }
        if self.view.subviews.contains(datePicker) {
            datePicker.removeFromSuperview()
        }
        if self.view.subviews.contains(picker) {
            picker.removeFromSuperview()
        }
        if segue.identifier == "showLocations" {
            let dest = segue.destination as! ShowTopicsViewController
            dest.delegate = self
            if newResource == nil {
                dest.selectedLocation = newDeadline.location
                dest.currentState = .locations
            } else {
                dest.selectedLocation = newResource?.professor
                dest.currentState = .professors
            }
        }
    }
    

}


//MARK:- Setup table view
extension NewDeadlineViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentState == .normal {
            return section==0 ? 5 : 1
        } else if currentState == .editing {
            return section==0 ? 1 : 1
        } else {
            return section==0 ? 4 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if currentState == .normal {
                if indexPath.row < 4 {
                    
                    
                    switch indexPath.row {
                        case 0:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                            cell.textLabel?.text = "Set date and time"
                            cell.detailTextLabel?.text = Helper.displayDate24HourFull(timestamp: newDeadline.timestamp)
                            cell.accessoryType = .disclosureIndicator

                            return cell
                        case 1:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                            cell.textLabel?.text = "Set location"
                            cell.detailTextLabel?.text = newDeadline.location
                            cell.accessoryType = .disclosureIndicator

                            return cell
                        case 3:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "colorCell", for: indexPath)
                            cell.textLabel?.text = "Change priority"
                            cell.viewWithTag(100)?.layer.cornerRadius = 12
                            cell.viewWithTag(100)?.backgroundColor = UIColor(hexString: newDeadline.color)
                            cell.accessoryType = .disclosureIndicator

                            return cell
                        default:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                            cell.textLabel?.text = "Select section"
                            cell.detailTextLabel?.text = newDeadline.section==section ? "My section" : "All sections"
                            cell.accessoryType = .disclosureIndicator

                            return cell
                    }
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "fieldCell", for: indexPath) as! FieldTableViewCell
                    cell.delegate = self
                    
                    if newDeadline.details == "" {
                        cell.textView.text = "Details"
                        cell.textView.textColor = UIColor(named: "Muted text color")
                    } else {
                        cell.textView.text = newDeadline.details
                        cell.textView.textColor = UIColor(named: "Text color")
                    }
                    
                    return cell
                }
            } else if currentState == .editing {
                let cell = tableView.dequeueReusableCell(withIdentifier: "fieldCell", for: indexPath) as! FieldTableViewCell
                cell.delegate = self
                
                if newResource == nil {
                    if newDeadline.details == "" {
                        cell.textView.text = "Details"
                        cell.textView.textColor = UIColor(named: "Muted text color")
                    } else {
                        cell.textView.text = newDeadline.details
                        cell.textView.textColor = UIColor(named: "Text color")
                    }
                } else {
                    if newResource?.details == "" {
                        cell.textView.text = "Details"
                        cell.textView.textColor = UIColor(named: "Muted text color")
                    } else {
                        cell.textView.text = newResource?.details
                        cell.textView.textColor = UIColor(named: "Text color")
                    }
                }
                
                return cell
            } else {
                if indexPath.row < 3 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                    
                    switch indexPath.row {
                        case 0:
                            cell.textLabel?.text = "Assessment type"
                            cell.detailTextLabel?.text = newResource?.assessment
                            break
                        case 1:
                            cell.textLabel?.text = "Semester and year"
                            cell.detailTextLabel?.text = newResource!.semester + " \(newResource!.year)"
                            break
                        default:
                            cell.textLabel?.text = "Professor"
                            cell.detailTextLabel?.text = newResource?.professor
                            break
                    }
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "fieldCell", for: indexPath) as! FieldTableViewCell
                    cell.delegate = self
                    
                    if newResource?.details == "" {
                        cell.textView.text = "Details"
                        cell.textView.textColor = UIColor(named: "Muted text color")
                    } else {
                        cell.textView.text = newResource?.details
                        cell.textView.textColor = .black
                    }
                    
                    return cell
                }
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            if newResource == nil {
                cell.textLabel?.text = "Set reminder"
                cell.detailTextLabel?.text = reminderList.first(where: {$0.1 == newDeadline.reminder})?.0
            } else {
                cell.textLabel?.text = "Upload files"
                cell.detailTextLabel?.text = newResource?.contentType
            }
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentState != .editing  {
            if indexPath.section == 0 {
                if newResource != nil && indexPath.row == 3 {
                    return 98
                } else if newResource == nil && indexPath.row == 4 {
                   return 98
                }
                return 44
            } else {
                return 44
            }
        } else {
            return tableView.bounds.height
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
        
        if newResource == nil {
            header.titleLabel.text = section==0 ? "DEADLINE INFO" : "SETUP DEADLINE DETAILS"
            header.detailLabel.text = ""
        } else {
            header.titleLabel.text = section==0 ? "RESOURCE INFO" : "UPLOAD FILES"
            header.detailLabel.text = ""
        }
        
        return header
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        if newResource == nil {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    if self.view.subviews.contains(toolBar) {
                        toolBar.removeFromSuperview()
                    }
                    self.view.endEditing(true)
                    
                    configure_datepicker()
                    self.view.addSubview(datePicker)

                    configure_toolbar(done_picker: #selector(done_start_picker), cancel_picker: #selector(cancel_date_picker))
                    self.view.addSubview(toolBar)
                } else if indexPath.row == 1 {
                    performSegue(withIdentifier: "showLocations", sender: nil)
                } else if indexPath.row == 2 {
                    newDeadline.section = newDeadline.section==section ? "All" : section
                    tableView.reloadData()
                } else if indexPath.row == 3 {
                    switch newDeadline.color {
                    case "#00A89D":
                        newDeadline.color = "#DA143A"
                    default:
                        newDeadline.color = "#00A89D"
                    }
                    tableView.reloadData()
                } else {
                    changeState()
                }
                
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                addPicker()
            }
        } else {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    currentSelector = .assessment
                    addPicker()
                } else if indexPath.row == 1 {
                    currentSelector = .semester
                    addPicker()
                } else if indexPath.row == 2 {
                    performSegue(withIdentifier: "showLocations", sender: nil)
                } else {
                    changeState()
                }
                
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                if indexPath.row == 0 {
                    uploadFile()
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
    }
    
    
    
    //MARK: File picker
    func uploadFile() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let askAction = UIAlertAction(title: "Upload images", style: .default, handler: { (action) in
            
            self.selectImages()
        })
        
        
        let addDeadline = UIAlertAction(title: "Upload file", style: .default, handler: { (action) in
            let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf", "com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document"], in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(askAction)
        alert.addAction(addDeadline)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
    
    
    func selectImages(){
        imagePicker = ImagePicker.getYPImagePicker()
        images = []
        imagePicker.didFinishPicking { [unowned imagePicker] items, cancelled in
            UINavigationBar.appearance().tintColor = UIColor(named: "Main color")
            if !cancelled {
                for item in items {
                    switch item {
                        case .photo(let photo):
                            self.images.append(photo.image)
                    case .video( _):
                            break
                    }
                }
            } else {
                self.images = []
            }
            
            if self.images.count != 0 {
                self.fileURL = nil
                self.newResource?.contentType = "img"
            } else {
                self.newResource?.contentType = self.newResource?.contentType=="img" ? "" : self.newResource!.contentType
            }
            
            imagePicker.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    //
    //  MARK: Get toolbar
    //
    func configure_toolbar(done_picker: Selector, cancel_picker: Selector) {
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: self.view.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: done_picker)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: cancel_picker)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    }
    
    
    //
    //  MARK: Date picker functions
    //
    @objc func done_start_picker(){
        newDeadline.timestamp = Int(datePicker.date.timeIntervalSince1970)
        datePicker.removeFromSuperview()
        toolBar.removeFromSuperview()
        
        tableView.reloadData()
    }
    
    @objc func cancel_date_picker(){
        
        datePicker.removeFromSuperview()
        toolBar.removeFromSuperview()
    }
    
    
    func configure_datepicker() {
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.backgroundColor = .systemBackground
        datePicker.tintColor = .label
        datePicker.frame = CGRect.init(x: 0.0, y: self.view.bounds.size.height - 300, width: self.view.bounds.size.width, height: 300)
    }
    //
    //  MARK: End date picker functions
    //
}


//MARK:- Toolbar
extension NewDeadlineViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func addPicker(){
        if self.view.subviews.contains(toolBar) {
            toolBar.removeFromSuperview()
        }
        self.view.endEditing(true)
        
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
        
        tableView.reloadData()
    }
    
    //TODO: Number of components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return currentSelector == .reminder ? 1 : 2
    }
    
    //TODO: Number of Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch currentSelector {
            case .assessment:
                return component==0 ? assessmentList.count : 12
            case .semester:
                return component==0 ? semesterList.count : 5
            default:
                return reminderList.count
        }
    }
    
    //TODO: Values of the rows
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch currentSelector {
            case .assessment:
                return component==0 ? assessmentList[row] : "\(row+1)"
            case .semester:
                return component==0 ? semesterList[row] : "\(2019-row)"
            default:
                return reminderList[row].0
        }
    }
    
    //DidSelect the rows
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch currentSelector {
            case .assessment:
                if component == 0 {
                    assessment.0 = assessmentList[row]
                } else {
                    assessment.1 = "\(row+1)"
                }
                newResource?.assessment = assessment.0 + " " + assessment.1
            case .semester:
                if component == 0 {
                    newResource?.semester = semesterList[row]
                } else {
                    newResource?.year = 2019-row
                }
            default:
                newDeadline.reminder = reminderList[row].1
        }
    }
}


extension NewDeadlineViewController: UITextFieldDelegate, NewQuestionProtocol {
    
    func doneTopic(text: String) {
        if newResource == nil {
            newDeadline.details = text
        } else {
            newResource?.details = text
        }
    }
    
    func doneBody(text: String) {
        
    }
    
    func switchChanged(isOn: Bool) {
        
    }
    
    func beginEditing(topic: Bool) {
        self.changeState()
    }
    
    func selectedTopic(topic: String) {
        
    }
    
    func selectedLocation(location: String) {
        if newResource == nil {
            newDeadline.location = location
        } else {
            
            newResource?.professor = location
        }
        
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
}


//MARK:- Configure UIDocumentPicker
extension NewDeadlineViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        fileURL = urls[0].absoluteURL
        let extent = urls[0].absoluteURL.pathExtension
        
        newResource?.contentType = extent
        self.images = []
        
        tableView.reloadData()
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        fileURL = nil
        self.newResource?.contentType = self.newResource?.contentType=="img" ? "img" : ""
    }
}
