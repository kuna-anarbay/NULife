//
//  AddEventViewController.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 10/20/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import SPAlert

class AddEventViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navigation: UINavigationBar!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var notesView: UIView!
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorBackground: UIView!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UITextField!
    
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderView: UIView!
    
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var sectionView: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var setTimeView: UIView!
    
    @IBOutlet weak var endTimeView: UIView!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var eventname: UITextField!
    @IBOutlet weak var nameBackView: UIView!
    
    
    var new_task = Task()
    let datePicker = UIDatePicker()
    var reminderPicker: UIPickerView!
    var toolBar: UIToolbar!
    var delegate: AddToTimetable?
    var editState = false
    
    enum delegate_states {
        case location
        case topic
    }
    var current_state : delegate_states = .location
    
    var selectedCourseName: String?
    var selectedCourse: Course?
    var eventRef : DatabaseReference!
    enum state {
        case normal
        case personal
    }
    var currentState : state = .normal
    var reminder_list = [ ("Not specified", -1), ("5 minutes", 5), ("10 minutes", 10), ("15 minutes", 15), ("20 minutes", 20), ("30 minutes", 30), ("45 minutes", 45), ("1 hour", 60), ("1.5 hours", 90), ("2 hours", 120), ("3 hourse", 180), ("6 hours", 360),  ("12 hourse", 720)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDesign()
        
        setTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectTimePressed)))
        endTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectEndTimePressed)))
        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(go_to_select_location)))
        locationLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(go_to_select_location)))
        sectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(go_to_select_topic)))
        reminderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectReminderPressed)))
        colorBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeColor)))
    }
    
    
    
    //
    //  MARK: Dismiss view
    //
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //
    //  MARK: Add new task
    //
    @IBAction func donePressed(_ sender: Any) {
 
        if editState {
            view.endEditing(true)
        } else {
           if checkFields() {
                new_task.add()
                SPAlert.present(title: "Added to schedule", preset: .done)
                self.dismiss(animated: true){
                    self.delegate?.add()
                }
            }
        }
    }
    
    
    
    //
    //  MARK: Change color of task
    //
    @objc func changeColor(sender: UITapGestureRecognizer) {
        switch new_task.color {
        case "#00A89D":
            new_task.color = "#F6971F"
        case "#F6971F":
            new_task.color = "#DA143A"
        default:
            new_task.color = "#00A89D"
        }
        colorView.backgroundColor = UIColor(hexString: new_task.color)
    }
    
    
    //
    //  MARK: Date picker functions
    //
    @objc func selectTimePressed(sender: UITapGestureRecognizer) {
        if toolBar != nil && self.view.subviews.contains(toolBar) {
            toolBar.removeFromSuperview()
        }
        self.view.endEditing(true)
        
        configure_datepicker()
        self.view.addSubview(datePicker)

        configure_toolbar(done_picker: #selector(done_start_picker), cancel_picker: #selector(cancel_date_picker))
        self.view.addSubview(toolBar)
    }
    
    @objc func selectEndTimePressed(sender: UITapGestureRecognizer) {
        if toolBar != nil && self.view.subviews.contains(toolBar) {
            toolBar.removeFromSuperview()
        }
        self.view.endEditing(true)
        
        configure_datepicker()
        self.view.addSubview(datePicker)

        configure_toolbar(done_picker: #selector(done_end_picker), cancel_picker: #selector(cancel_date_picker))
        self.view.addSubview(toolBar)
    }
    
    @objc func done_start_picker(){
        new_task.start = Int(datePicker.date.timeIntervalSince1970)
        timeLabel.text = Helper.displayDate24HourFull(timestamp: new_task.start)
        datePicker.removeFromSuperview()
        toolBar.removeFromSuperview()
    }
    
    @objc func done_end_picker(){
        
        new_task.end = Int(datePicker.date.timeIntervalSince1970)
        endTimeLabel.text = Helper.displayDate24HourFull(timestamp: new_task.end)
        datePicker.removeFromSuperview()
        toolBar.removeFromSuperview()
    }
    
    @objc func cancel_date_picker(){
        
        new_task.end = -1
        endTimeLabel.text = "None"
        datePicker.removeFromSuperview()
        toolBar.removeFromSuperview()
    }
    
    
    func configure_datepicker() {
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .dateAndTime
        datePicker.backgroundColor = .systemBackground
        datePicker.frame = CGRect.init(x: 0.0, y: self.view.bounds.size.height - 300, width: self.view.bounds.size.width, height: 300)
    }
    //
    //  MARK: End date picker functions
    //
    
    
    //
    //  MARK: Perform segues
    //
    @objc func go_to_select_location(sender: UITapGestureRecognizer) {
        current_state = .location
        performSegue(withIdentifier: "selectLocation", sender: nil)
    }
    
    @objc func go_to_select_topic(sender: UITapGestureRecognizer) {
        current_state = .topic
        performSegue(withIdentifier: "selectLocation", sender: nil)
    }
    //
    //  MARK: End perform segues
    //
    
    
    
    //
    //  MARK: Prepare for a segue
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.setupDesign()
        if segue.identifier == "selectLocation" {
            let dest = (segue.destination as! TitleListViewController)
            switch current_state {
                case .location:
                    dest.item_list = UserDefaults.standard.stringArray(forKey: "locations") ?? []
                    if new_task.location != "Not specified" {
                       dest.title_string = new_task.location
                    }
                    dest.current_state = .location
                default:
                    dest.item_list = UserDefaults.standard.stringArray(forKey: "topics") ?? []
                    if new_task.topic != "Personal" {
                       dest.title_string = new_task.topic
                    }
                    dest.current_state = .topic
            }
            dest.delegate = self
        }
    }
    //
    //  MARK: End prepare for a segue
    //

    
    
    //
    //  MARK: Set reminder picker
    //
    @objc func selectReminderPressed(sender: UITapGestureRecognizer) {
        if toolBar != nil && self.view.subviews.contains(toolBar) {
            toolBar.removeFromSuperview()
        }
        self.view.endEditing(true)
        
        configure_reminder_picker()
        self.view.addSubview(reminderPicker)

        configure_toolbar(done_picker: #selector(done_reminder_picker), cancel_picker: #selector(cancel_reminder_picker))
        self.view.addSubview(toolBar)
    }
    
    func configure_reminder_picker(){
        reminderPicker = UIPickerView.init()
        reminderPicker.delegate = self
        reminderPicker.backgroundColor = .systemBackground
        reminderPicker.setValue(UIColor.label, forKey: "textColor")
        reminderPicker.frame = CGRect.init(x: 0.0, y: self.view.bounds.size.height - 300, width: self.view.bounds.size.width, height: 300)
    }
    
    @objc func done_reminder_picker() {
        reminderLabel.text = new_task.reminder == -1 ? "Not specified" : reminder_list.first(where: { $0.1 == new_task.reminder})!.0 + " before"
        reminderPicker.removeFromSuperview()
        toolBar.removeFromSuperview()
    }
    
    @objc func cancel_reminder_picker(){
        new_task.reminder = reminder_list[0].1
        reminderLabel.text = reminder_list[0].0
        
        reminderPicker.removeFromSuperview()
        toolBar.removeFromSuperview()
    }
    //
    //  MARK: End reminder picker
    //
    
    
    
    //
    //  MARK: SETUP DESIGN ELEMENTS
    //
    func setupDesign(){
        
        nameBackView.layer.cornerRadius = 8
        eventname.text = new_task.name
        eventname.delegate = self
        
        colorView.layer.cornerRadius = colorView.bounds.width/2
        colorView.backgroundColor = UIColor(hexString: new_task.color)
        
        
        setTimeView.layer.cornerRadius = 8
        timeLabel.text = Helper.displayDate24HourFull(timestamp: new_task.start)
        
        
        endTimeView.layer.cornerRadius = 8
        if new_task.start <= new_task.end {
            endTimeLabel.text = Helper.displayDate24HourFull(timestamp: new_task.end)
        } else {
            endTimeLabel.text = "None"
        }
        
        
        sectionView.layer.cornerRadius = 8
        sectionLabel.text = new_task.topic
        
        
        locationView.layer.cornerRadius = 8
        if new_task.location == "Not specified" {
            locationLabel.placeholder = "Enter location"
        } else {
            locationLabel.text = new_task.location
        }
        locationLabel.delegate = self
        
    
        reminderView.layer.cornerRadius = 8
        
        notesField.delegate = self
        notesView.layer.cornerRadius = 8
        notesField.text = new_task.note
    }
}



//
//  MARK: Protocols
//
extension AddEventViewController : SelectEventTopicProtocol {
    func select(topic: String) {
        switch current_state {
            case .location:
                self.new_task.location = topic
            default:
                self.new_task.topic = topic
        }
        setupDesign()
    }
    
    func select(professor: String) {
       
    }
}
//
//  MARK: End protocols
//



//
//  MARK: Helper function
//
extension AddEventViewController: UITextViewDelegate {
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 1000) {
            _ = self.notesView.topConstraint?.constant
            for _ in 0...374 {
                self.notesView.topConstraint?.constant -= 1
            }
        }
        self.editState = true
        self.navItem.rightBarButtonItem?.title = "Done editing"
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 1000) {
            for _ in 0...374 {
                self.notesView.topConstraint?.constant += 1
            }
        }
        new_task.note = textView.text
        editState = false
        self.navItem.rightBarButtonItem?.title = "Done"
    }
    
    //
    //  MARK: Hide the keyboard when the return key pressed
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == eventname {
            new_task.name = eventname.text ?? "New task"
        }
        if textField == locationLabel {
            new_task.location = locationLabel.text ?? "Not specified"
        }
    }
    
    
    
    //
    //  MARK: Check input values
    //
    func checkFields() -> Bool {
        let eventName = eventname.text
        let topic = sectionLabel.text
        let location = locationLabel.text
        
        if eventName == nil || eventName!.isEmpty {
            SPAlert.present(message: "Please enter task name")
            return false
        }
        
        
        if topic == nil || topic!.isEmpty {
            new_task.topic = "Personal"
        }

        if location == nil || location!.isEmpty {
            new_task.location = "Not specified"
        }

        
        if new_task.start <= Int(Date().timeIntervalSince1970) || timeLabel.text == nil || timeLabel.text!.isEmpty {
            SPAlert.present(message: "Please enter a valid start time")
            return false
        }

        if new_task.end == -1 || endTimeLabel.text == nil || endTimeLabel.text!.isEmpty || endTimeLabel.text == "None" {
            
            new_task.end = -1
        }
        
        if new_task.isValid.0 == false {
            SPAlert.present(message: new_task.isValid.1)
            return false
        }
        
        
        return true
    }
    
    
    
    //
    //  MARK: Get toolbar
    //
    func configure_toolbar(done_picker: Selector, cancel_picker: Selector) {
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: self.view.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: done_picker)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: cancel_picker)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    }
    
    
    
    //
    //  MARK: Setup initial design
    //
    
    
}
//
//  MARK: End helper function
//


//
//  MARK: Picker configuration
//
extension AddEventViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reminder_list.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return reminder_list[row].0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        new_task.reminder = reminder_list[row].1
    }
}
//
//  MARK: End picker configuration
//
