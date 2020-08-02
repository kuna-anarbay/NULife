//
//  AddLessonViewController.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 8/18/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import RealmSwift
import SPAlert

protocol AddToTimetable {
    func add()
}

class AddLessonViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var navigation: UINavigationBar!
    @IBOutlet weak var nameBackgroundView: UIView!
    @IBOutlet weak var lessonName: UITextField!
    
    @IBOutlet weak var selectColorView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var startTime: UITextField!
    
    @IBOutlet weak var endView: UIView!
    @IBOutlet weak var endTime: UITextField!
    
    @IBOutlet weak var daysStackView: UIStackView!
    
    @IBOutlet weak var Location: UITextField!
    @IBOutlet weak var locationView: UIView!
    
    @IBOutlet weak var professorView: UIView!
    @IBOutlet weak var Professor: UITextField!
    
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var notifyTextField: UITextField!

    @IBOutlet weak var donePressed: UIBarButtonItem!
    
    var new_event = Event()
    var delegate: AddToTimetable?
    let datePicker = UIDatePicker()
    var reminder_list = [ ("Not specified", -1), ("5 minutes", 5), ("10 minutes", 10), ("15 minutes", 15), ("20 minutes", 20), ("30 minutes", 30), ("45 minutes", 45), ("1 hour", 60), ("1.5 hours", 90), ("2 hours", 120), ("3 hourse", 180), ("6 hours", 360),  ("12 hourse", 720)]
    
    
    //MARK: View did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        setup_design()
        
        
        
        daysStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(select_days)))
        
        selectColorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(go_to_select_color)))
        
        Location.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(go_to_select_location)))
        Professor.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(go_to_select_professor)))
        
        setup_stack_design()
        
        
        setup_start_time_picker()
        setup_end_time_picker()
        setup_reminder_picker()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    //
    //  MARK: Done pressed
    //
    @IBAction func donePressed(_ sender: Any) {
        if check_fields() {
            new_event.add()
            SPAlert.present(title: "Added to schedule", preset: .done)
           
            
            self.dismiss(animated: true){
                self.delegate?.add()
            }
        }
    }
    
    
    
    //
    //  MARK: Cancel pressed
    //
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //
    //  MARK: Perform segues
    //
    @objc func go_to_select_color(sender: UITapGestureRecognizer) {
        new_event.name = lessonName.text ?? "New routine"
        performSegue(withIdentifier: "selectColor", sender: nil)
    }
    
    @objc func go_to_select_location(sender: UITapGestureRecognizer) {
        let state : showListState = .locations
        performSegue(withIdentifier: "selectLocation", sender: state)
    }
    
    @objc func go_to_select_professor(sender: UITapGestureRecognizer) {
        let state : showListState = .professors
        performSegue(withIdentifier: "selectLocation", sender: state)
    }
    //
    //  MARK: End perform segues
    //
    
    
    
    //
    //  MARK: Setup days stack view
    //
    func setup_stack_design(){
        for i in 1 ... 7 {
            let sub_view = (daysStackView.viewWithTag(i)!)
            
            
            if new_event.days[i-1] {
                sub_view.backgroundColor = UIColor(named: "Main color")
                (sub_view.viewWithTag(0) as! UILabel).textColor = .white
            } else {
                sub_view.backgroundColor = .systemBackground
                (sub_view.viewWithTag(0) as! UILabel).textColor = UIColor(named: "Text color")
            }
            sub_view.layer.cornerRadius = sub_view.bounds.width/2
        }
    }
    
    @objc func select_days(sender: UITapGestureRecognizer) {
        let location = sender.location(in: daysStackView)
        let x_axis = location.x/(self.daysStackView.bounds.width/7)
        
        new_event.days[Int(x_axis)] = new_event.days[Int(x_axis)] ? false : true
        
        setup_stack_design()
    }
    //
    //  MARK: End setup days stack view
    //
    
    
    
    //
    //  MARK: Date picker function
    //
    func setup_start_time_picker(){
        datePicker.datePickerMode = .time
        
        startTime.inputAccessoryView = get_toolbar(done_picker: #selector(done_start_picker), cancel_picker: #selector(cancel_date_picker))
        
        startTime.inputView = datePicker
    }
    
    func setup_end_time_picker(){
        datePicker.datePickerMode = .time
        
        endTime.inputAccessoryView = get_toolbar(done_picker: #selector(done_end_picker), cancel_picker: #selector(cancel_date_picker))
        
        endTime.inputView = datePicker
    }
    
    @objc func done_start_picker(){
        new_event.start = Int(datePicker.date.timeIntervalSince1970)
        startTime.text = Helper.display24HourTime(timestamp: new_event.start)
        
        self.view.endEditing(true)
    }
    
    @objc func done_end_picker(){
        new_event.end = Int(datePicker.date.timeIntervalSince1970)
        endTime.text = Helper.display24HourTime(timestamp: new_event.end)
        
        self.view.endEditing(true)
    }
    
    @objc func cancel_date_picker(){
        self.view.endEditing(true)
    }
    //
    //  MARK: End date picker function
    //

    
    
    //
    //  MARK: Setup reminder picker
    //
    func setup_reminder_picker(){
        let reminder_picker = UIPickerView()
        reminder_picker.dataSource = self
        reminder_picker.delegate = self
        
        notifyTextField.inputView = reminder_picker
        notifyTextField.inputAccessoryView = get_toolbar(done_picker: #selector(done_picker), cancel_picker: #selector(cancel_picker))
    }
    
    @objc func done_picker(){
        notifyTextField.text = new_event.reminder == -1 ? "Not specified" : reminder_list.first(where: { $0.1 == new_event.reminder})!.0 + " before"
        self.view.endEditing(true)
    }
    
    @objc func cancel_picker(){
        new_event.reminder = reminder_list[0].1
        notifyTextField.text = reminder_list[0].0
        
        self.view.endEditing(true)
    }
    //
    //  MARK: End setup reminder picker
    //
    
    
    
    
    //
    //  MARK: Prepare for a segue
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.setup_design()
        if segue.identifier == "selectColor" {
            let dest = (segue.destination as! ColorAndIconViewController)
            dest.new_event = new_event
            dest.delegate = self
        } else if segue.identifier == "selectLocation" {
            let dest = (segue.destination as! TitleListViewController)
            
            let state = sender as! showListState
            if state == .locations {
                dest.item_list = UserDefaults.standard.stringArray(forKey: "locations") ?? []
                dest.current_state = .location
                if new_event.location != "Not specified" {
                   dest.title_string = new_event.location
                }
            } else {
                dest.item_list = UserDefaults.standard.stringArray(forKey: "professors") ?? []
                dest.current_state = .professor
                if new_event.professor != "Not specified" {
                   dest.title_string = new_event.professor
                }
            }
            
            dest.delegate = self
        }
    }
    //
    //  MARK: End prepare for a segue
    //
    
    
}


//
//  MARK: Protocols
//
extension AddLessonViewController : SelectEventTopicProtocol, SelectIconAndColorProtocol {
    
    
    func select(topic: String) {
        self.new_event.location = topic
        setup_design()
    }
    
    func select(professor: String) {
        self.new_event.professor = professor
        setup_design()
    }
    
    
    func select(event: Event) {
        self.new_event = event
        setup_design()
    }
    
}
//
//  MARK: End protocols
//



//
//  MARK: Helper function
//
extension AddLessonViewController {
    
    
    //
    //  MARK: Hide the keyboard when the return key pressed
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == Professor {
            new_event.professor = Professor.text ?? "Not specified"
        }
        if textField == Location {
            new_event.location = Location.text ?? "Not specified"
        }
        if textField == lessonName {
            new_event.name = lessonName.text ?? "New routine"
        }
    }
    
    
    
    //
    //  MARK: Check input values
    //
    func check_fields() -> Bool {
        let title = lessonName.text
        let professor = Professor.text
        let location = Location.text
        
        if title == nil || title!.isEmpty {
            SPAlert.present(message: "Please enter routine name")
            return false
        }
        
        if professor == nil || professor!.isEmpty {
            new_event.professor = "Not specified"
        }
        
        if location == nil || location!.isEmpty {
            new_event.location = "Not specified"
        }
        
        if new_event.start == 0 || startTime.text == nil || startTime.text!.isEmpty {
            SPAlert.present(message: "Please enter start time")
            return false
        }
        
        if new_event.end == 0 || endTime.text == nil || endTime.text!.isEmpty {
            SPAlert.present(message: "Please enter end time")
            return false
        }
        
        if new_event.end <= new_event.start {
            SPAlert.present(message: "Please enter valid start and end time")
            return false
        }
        
        if !new_event.days.contains(true) {
            SPAlert.present(message: "Please select at least one day")
            return false
        }
        
        if new_event.isValid.0 == false {
            SPAlert.present(message: new_event.isValid.1)
            return false
        }
        
        return true
    }
    
    
    
    //
    //  MARK: Get toolbar
    //
    func get_toolbar(done_picker: Selector, cancel_picker: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: done_picker)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: cancel_picker)
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        return toolbar
    }
    
    
    
    //
    //  MARK: Setup initial design
    //
    func setup_design(){
        
        setup_stack_design()
        
        if new_event.days_list.count > 0 {
            new_event.days = Array(new_event.days_list)
        }
        
        colorView.layer.cornerRadius = 8
        colorView.backgroundColor = UIColor(hexString: new_event.color)
        iconImageView.image = UIImage(systemName: new_event.icon)
        iconImageView.tintColor = .white
        view.bringSubviewToFront(iconImageView)
        
        nameBackgroundView.layer.cornerRadius = 8
        lessonName.text = new_event.name
        lessonName.delegate = self
        
        reminderView.layer.cornerRadius = 8
        notifyTextField.delegate = self
        notifyTextField.text = new_event.reminder == -1 ? "" : reminder_list.first(where: { $0.1 == new_event.reminder})!.0 + " before"
            
        professorView.layer.cornerRadius = 8
        if new_event.professor == "Not specified" {
            Professor.placeholder = "Responsible's name"
        } else {
            Professor.text = new_event.professor
        }
        
        Professor.delegate = self
        
        locationView.layer.cornerRadius = 8
        if new_event.location == "Not specified" {
            Location.placeholder = "Enter location"
        } else {
            Location.text = new_event.location
        }
        Location.delegate = self
        
        startView.layer.cornerRadius = 8
        if new_event.start == 0 {
            startTime.placeholder = "None"
        } else {
            startTime.text = Helper.display24HourTime(timestamp: new_event.start)
        }
        
        endView.layer.cornerRadius = 8
        if new_event.end == 0 {
            endTime.placeholder = "None"
        } else {
            endTime.text = Helper.display24HourTime(timestamp: new_event.end)
        }
    }
    
}
//
//  MARK: End helper function
//



//
//  MARK: Picker configuration
//
extension AddLessonViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
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
    
        new_event.reminder = reminder_list[row].1
    }
}
//
//  MARK: End picker configuration
//
