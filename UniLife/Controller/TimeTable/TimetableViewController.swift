//
//  TimetableViewController.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 11/15/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import RealmSwift


class TimetableViewController: UIViewController {
    
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var addEventButton: UIView!
    @IBOutlet weak var changeStateButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let defaults = UserDefaults.standard
    var days : [String : [Int : String]] = [:]
    var weekDays = [(String, Int)]()
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let daysList = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var all_events : [String : [Int : [AnyObject]]] = [:]
    var dailyState = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
        

        if UserDefaults.standard.object(forKey: "weekView") == nil {
            defaults.set(false, forKey: "weekView")
        }
        

        changeStateButton.setTitle(defaults.bool(forKey: "weekView") ? "Weekly" : "Daily", for: .normal)
        setupSegmentedControl()
        get_today()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "weekView") == nil {
            defaults.set(false, forKey: "weekView")
        }
        setupSegmentedControl()
        get_today()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        
        if self.presentedViewController == nil {
            get_today()
        }
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        addActions()
    }
    
    
    func setupSegmentedControl(){
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool
        let calendar = Calendar.current
        
        if state {
            var i = 0
            segmentedControl.removeAllSegments()
            let isFirsthalf = calendar.component(.month, from: Date()) <= 6
            var startDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: Date()), month: isFirsthalf ? 0 : 7))!
            let secondDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: Date()), month: isFirsthalf ? 6 : 12))!
            
            while startDate <= secondDate {
                segmentedControl.insertSegment(withTitle: months[isFirsthalf ? i : i + 6], at: i, animated: false)
                startDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
                i += 1
            }
            segmentedControl.selectedSegmentIndex = isFirsthalf ? calendar.component(.month, from: Date()) - 1 : calendar.component(.month, from: Date()) - 7
            segmentedControl.removeSegment(at: 6, animated: false)
        } else {
            var i = 0
            weekDays = []
            segmentedControl.removeAllSegments()
            var startDate = calendar.date(byAdding: .day, value: -3, to: Date())!
            let secondDate = calendar.date(byAdding: .day, value: 3, to: Date())!
            while startDate <= secondDate {
                let weekDay = calendar.component(.weekday, from: startDate) > 1 ? calendar.component(.weekday, from: startDate) - 2 : 6
                weekDays.append((Helper.displayMonth(timestamp: Int(startDate.timeIntervalSince1970)), Helper.displayDayOfMonth(timestamp: Int(startDate.timeIntervalSince1970))))
                
                segmentedControl.insertSegment(withTitle: daysList[weekDay], at: i, animated: false)
                startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
                i += 1
            }
            segmentedControl.selectedSegmentIndex = 3
        }
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        get_today()
    }
    
    
    func addActions(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //TODO: LEAVE THE SELECTED COURSE
        alert.addAction(UIAlertAction(title: "Add routine", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "addEvent", sender: nil)
        }))
        
        //TODO: LEAVE THE SELECTED COURSE
        alert.addAction(UIAlertAction(title: "Add task", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "addTask", sender: nil)
        }))
        
        //TODO:  DISMISS ALERT
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.tableView.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func changeStatePressed(_ sender: Any) {
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool
        defaults.set(!state, forKey: "weekView")
        changeStateButton.setTitle(state ? "Weekly" : "Daily", for: .normal)
        setupSegmentedControl()
        get_today()
    }
    
    
    

    //
    //  MARK: Get today events
    //
    func get_today() {
        let calendar = Calendar.current
        let temp_all_events = Array(Constants.realm.objects(Event.self))
        let temp_all_tasks = Array(Constants.realm.objects(Task.self))
        
        let isFirsthalf = Calendar.current.component(.month, from: Date()) <= 6
        var startDate = calendar.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()), month: isFirsthalf ? 1 : 7, day: 1, hour: 0, minute: 0, second: 0))!
        let secondDate = calendar.date(from: DateComponents(year: isFirsthalf ? Calendar.current.component(.year, from: Date()) : Calendar.current.component(.year, from: Date()) + 1, month: isFirsthalf ? 7 : 1, day: 1, hour: 0, minute: 0, second: 0))!
        
        while startDate < secondDate {
            let weekDay = calendar.component(.weekday, from: startDate) > 1 ? calendar.component(.weekday, from: startDate) - 2 : 6
            let timestamp = Int(startDate.timeIntervalSince1970)
            
            if days[Helper.displayMonth(timestamp: Int(startDate.timeIntervalSince1970))] == nil{
                days[Helper.displayMonth(timestamp: Int(startDate.timeIntervalSince1970))] = [Helper.displayDayOfMonth(timestamp: Int(startDate.timeIntervalSince1970)) : daysList[weekDay]]
            } else {
                days[Helper.displayMonth(timestamp: Int(startDate.timeIntervalSince1970))]![Helper.displayDayOfMonth(timestamp: Int(startDate.timeIntervalSince1970))] = daysList[weekDay]
            }
            
            var eventsList : [AnyObject] = temp_all_events.filter{ $0.days_list[weekDay] == true }
            let tasksList : [AnyObject] = temp_all_tasks.filter{ $0.start >= timestamp && $0.start < timestamp + 24*3600 }
            eventsList.append(contentsOf: tasksList)
            let temp_events = eventsList.count == 0 ? ["NOTHING PLANNED"] as [AnyObject] : eventsList.sorted(by: { (first, second) -> Bool in
                if first is String || second is String {
                    return true
                } else {
                    return Helper.displayHourMinuteTimestamp(timestamp: first.start) <= Helper.displayHourMinuteTimestamp(timestamp: second.start)
                }
            })
            if all_events[Helper.displayMonth(timestamp: Int(startDate.timeIntervalSince1970))] == nil {
                all_events[Helper.displayMonth(timestamp: Int(startDate.timeIntervalSince1970))] = [Helper.displayDayOfMonth(timestamp: Int(startDate.timeIntervalSince1970)) : temp_events]
            } else {
                all_events[Helper.displayMonth(timestamp: Int(startDate.timeIntervalSince1970))]![Helper.displayDayOfMonth(timestamp: Int(startDate.timeIntervalSince1970))] = temp_events
            }
            
            
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }
        
        if !(UserDefaults.standard.object(forKey: "weekView") as! Bool) {
            todayLabel.text = Helper.displayWeekDayMonth(timestamp: Int(calendar.date(byAdding: .day, value: segmentedControl.selectedSegmentIndex-3, to: Date())!.timeIntervalSince1970))
        }
        
        tableView.reloadData()
        if UserDefaults.standard.object(forKey: "weekView") as! Bool {
            if Helper.displayMonth(timestamp: Int(Date().timeIntervalSince1970)) == months[segmentedControl.selectedSegmentIndex] {
                tableView.scrollToRow(at: IndexPath(row: 0, section: Helper.displayDayOfMonth(timestamp: Int(Date().timeIntervalSince1970)) - 1), at: .top, animated: false)
                todayLabel.text = days[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]![Helper.displayDayOfMonth(timestamp: Int(Date().timeIntervalSince1970))]!
                todayLabel.text! += ", \(Helper.displayDayOfMonth(timestamp: Int(Date().timeIntervalSince1970))) " + months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]
            } else {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                todayLabel.text = days[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]![1]!
                todayLabel.text! += ", \(1) " + months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]
            }
        }
    }
    
    
    //
    //  MARK: Prepare for a segue
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            let dest = segue.destination as! AddEventViewController
            dest.currentState = .personal
            dest.delegate = self
            if sender != nil {
                if sender is Task {
                    dest.new_task.copyFrom((sender as? Task)!)
                } else {
                    dest.new_task.topic = (sender as? Event)!.name
                }
            }
        } else if segue.identifier == "addEvent" {
            let dest = segue.destination as! AddLessonViewController
            dest.delegate = self
            if sender != nil {
                dest.new_event.copyFrom((sender as? Event)!)
            }
        } else if segue.identifier == "showEvent" {
            let destNav = segue.destination as! UINavigationController
            let dest = destNav.viewControllers[0] as! EventDetailViewController
            dest.event = sender as! Event
        }
    }
}



//
//  MARK: Tableview configuration
//
extension TimetableViewController : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool
        let isFirsthalf = Calendar.current.component(.month, from: Date()) <= 6
        return state ? all_events[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]?.count ?? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool
        let isFirsthalf = Calendar.current.component(.month, from: Date()) <= 6
        if state {
            return all_events[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]?[section+1]?.count ?? 0
        } else {
            return all_events[weekDays[segmentedControl.selectedSegmentIndex].0]?[weekDays[segmentedControl.selectedSegmentIndex].1]?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool
        var anyObject : AnyObject! = nil
        let isFirsthalf = Calendar.current.component(.month, from: Date()) <= 6
        if state {
            anyObject = all_events[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]?[indexPath.section+1]?[indexPath.row]
        } else {
            anyObject =  all_events[weekDays[segmentedControl.selectedSegmentIndex].0]?[weekDays[segmentedControl.selectedSegmentIndex].1]?[indexPath.row]
        }
        
        if anyObject is Event {
            if state {
                let cell = tableView.dequeueReusableCell(withIdentifier: "smallEventCell", for: indexPath) as! SmallEventTableViewCell
                let event = anyObject as! Event
                cell.titleLabel.text = event.name
                cell.titleLabel.font = UIFont(name: "SfProDisplay-medium", size: 22)
                cell.titleLabel.textColor = .white
                   
                cell.detailLabel.text = Helper.display24HourTime(timestamp: event.start) + " - " + Helper.display24HourTime(timestamp: event.end)
                cell.detailLabel.textColor = .white
                
                
                
                if indexPath.row == 0 {
                    cell.dayLabel.text = "\(indexPath.section+1)"
                    cell.weekdayLabel.text = days[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]![indexPath.section+1]!
                } else {
                    cell.dayLabel.text = ""
                    cell.weekdayLabel.text = ""
                }
                
                
                cell.backView.backgroundColor = UIColor(hexString: event.color)
                cell.iconImageView.image = UIImage(systemName: event.icon)
                cell.iconImageView.tintColor = .white
                   
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! LargeEventTableViewCell
                let event = anyObject as! Event
                cell.titleLabel.text = event.name
                cell.titleLabel.textColor = .white
                   
                cell.detailLabel.text = event.location + " \u{2022} " + event.professor
                cell.detailLabel.textColor = .white
                   
                cell.timeLabel.text = Helper.display12HourTime(timestamp: event.start) + "\n" + Helper.display12HourTime(timestamp: event.end)
                   
                cell.backView.backgroundColor = UIColor(hexString: event.color)
                   
                cell.borderView.backgroundColor = nil
                cell.iconImageView.image = UIImage(systemName: event.icon)
                cell.iconImageView.tintColor = .white
                   
                return cell
            }
            
        } else if anyObject is Task {
            if state {
                let cell = tableView.dequeueReusableCell(withIdentifier: "smallEventCell", for: indexPath) as! SmallEventTableViewCell
                let task = anyObject as! Task
                cell.titleLabel.text = task.name
                cell.titleLabel.font = UIFont(name: "SfProDisplay-medium", size: 20)
                cell.titleLabel.textColor = .white
                
                if task.end > task.start {
                    cell.detailLabel.text = Helper.display24HourTime(timestamp: task.start) + " - " + Helper.display24HourTime(timestamp: task.end)
                } else {
                    cell.detailLabel.text = Helper.display24HourTime(timestamp: task.start)
                }
                
                cell.detailLabel.textColor = .white
                
                
                
                if indexPath.row == 0 {
                    cell.dayLabel.text = "\(indexPath.section+1)"
                    cell.weekdayLabel.text = days[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]![indexPath.section+1]!
                } else {
                    cell.dayLabel.text = ""
                    cell.weekdayLabel.text = ""
                }
                
                
                cell.backView.backgroundColor = UIColor(hexString: task.color)
                cell.iconImageView.image = UIImage(systemName: task.icon)
                cell.iconImageView.tintColor = .white
                   
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! LargeEventTableViewCell
                let task = anyObject as! Task
                
                cell.titleLabel.text = task.name
                cell.titleLabel.textColor = .label
                   
                cell.detailLabel.text = task.location + " \u{2022} " + task.topic
                cell.detailLabel.textColor = .lightGray
                   
                if task.end > task.start {
                    cell.timeLabel.text = Helper.display12HourTime(timestamp: task.start) + "\n" + Helper.display12HourTime(timestamp: task.end)
                } else {
                    cell.timeLabel.text = Helper.display12HourTime(timestamp: task.start)
                }
                   
                cell.backView.backgroundColor = .clear
                cell.borderView.backgroundColor = UIColor(hexString: task.color)
                   
                cell.iconImageView.image = UIImage(systemName: "location.fill")
                cell.iconImageView.tintColor = .lightGray
                   
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "smallEventCell", for: indexPath) as! SmallEventTableViewCell
            let message = anyObject as! String
            cell.titleLabel.text = message
            cell.titleLabel.font = UIFont(name: "SfProDisplay-medium", size: 15)
            cell.titleLabel.textColor = UIColor(named: "Muted text color")
               
            cell.detailLabel.text = "Tap to add"
            cell.detailLabel.textColor = UIColor(named: "Muted text color")
            if state {
                cell.dayLabel.text = "\(indexPath.section+1)"
                cell.weekdayLabel.text = days[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]![indexPath.section+1]!
            } else {
                cell.dayLabel.text = ""
                cell.weekdayLabel.text = ""
            }
            
               
            cell.backView.backgroundColor = .systemBackground
               
            cell.iconImageView.tintColor = .systemBackground
               
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool
        if scrollView == tableView && state {
            let indexPath = tableView.indexPathsForVisibleRows![0]
            
            let isFirsthalf = Calendar.current.component(.month, from: Date()) <= 6
            todayLabel.text = days[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]![indexPath.section+1]!
            todayLabel.text! += ", \(indexPath.section+1) " + months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool

        var anyObject : AnyObject! = nil
        if state {
            let isFirsthalf = Calendar.current.component(.month, from: Date()) <= 6
            anyObject = all_events[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]?[indexPath.section+1]?[indexPath.row]
        } else {
            anyObject =  all_events[weekDays[segmentedControl.selectedSegmentIndex].0]?[weekDays[segmentedControl.selectedSegmentIndex].1]?[indexPath.row]
        }
        if anyObject is String {
            addActions()
        } else if anyObject is Event {
            performSegue(withIdentifier: "showEvent", sender: anyObject as! Event)
        } else {
            
            let task = anyObject as! Task
            let alert = UIAlertController(title: task.name, message: task.note, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }


    func tableView(
      _ tableView: UITableView,
      contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint)
      -> UIContextMenuConfiguration? {
        // 1
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool

        var anyObject : AnyObject! = nil
        if state {
            let isFirsthalf = Calendar.current.component(.month, from: Date()) <= 6
            anyObject = all_events[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]?[indexPath.section+1]?[indexPath.row]
        } else {
            anyObject =  all_events[weekDays[segmentedControl.selectedSegmentIndex].0]?[weekDays[segmentedControl.selectedSegmentIndex].1]?[indexPath.row]
        }

        // 2
        let identifier = "\(indexPath.section),\(indexPath.row)" as NSString

        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            // 3
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, attributes: UIMenuElement.Attributes.destructive) { _ in

                if anyObject is Event {
                    (anyObject as! Event).delete()
                } else if anyObject is Task {
                    (anyObject as! Task).delete()
                }
                self.get_today()
            }

            // 4
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { _ in
                if anyObject is Event {
                    self.performSegue(withIdentifier: "addEvent", sender: anyObject as! Event)
                } else if anyObject is Task {
                    self.performSegue(withIdentifier: "addTask", sender: anyObject as! Task)
                }
            }

            let addTaskAction = UIAction(title: "Add task", image: UIImage(systemName: "plus")) { _ in
                self.performSegue(withIdentifier: "addTask", sender: anyObject as! Event)
            }
            
            let seeRoutineAction = UIAction(title: "See routine", image: nil) { _ in
                let event = Constants.realm.objects(Event.self).first { (tempEvent) -> Bool in
                    return tempEvent.name == (anyObject as! Task).topic
                }
                
                if event != nil {
                    self.performSegue(withIdentifier: "showEvent", sender: event)
                } else {
                    self.present(UIViewController.getAlertWithCancelButton("This task is not related to any routine"), animated: true, completion: nil)
                    
                }
            }

            if anyObject is Event {
                return UIMenu(title: "", image: nil,
                children: [addTaskAction, editAction, deleteAction])
            } else if anyObject is Task {
                return UIMenu(title: "", image: nil,
                children: [seeRoutineAction, editAction, deleteAction])
            } else {
                return nil
            }
        }
    }

    func tableView(_ tableView: UITableView,
                            previewForHighlightingContextMenuWithConfiguration
      configuration: UIContextMenuConfiguration)
      -> UITargetedPreview? {


        let identifier = configuration.identifier as? String
        let section = Int(String((identifier?.split(separator: ",")[0])!))
        let row = Int(String((identifier?.split(separator: ",")[1])!))
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool
         var anyObject : AnyObject! = nil
        if state {
             let isFirsthalf = Calendar.current.component(.month, from: Date()) <= 6
             anyObject = all_events[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]?[section!+1]?[row!]
         } else {
             anyObject =  all_events[weekDays[segmentedControl.selectedSegmentIndex].0]?[weekDays[segmentedControl.selectedSegmentIndex].1]?[row!]
         }

        if anyObject is Event {
            if state {
                return UITargetedPreview(view: (tableView.cellForRow(at: IndexPath(row: row!, section: section!)) as! SmallEventTableViewCell).backView!)
            } else {
                return UITargetedPreview(view: (tableView.cellForRow(at: IndexPath(row: row!, section: section!)) as! LargeEventTableViewCell).backView!)
            }
        } else if anyObject is Task {
            if state {
                return UITargetedPreview(view: (tableView.cellForRow(at: IndexPath(row: row!, section: section!)) as! SmallEventTableViewCell).backView!)
            } else {
                return UITargetedPreview(view: (tableView.cellForRow(at: IndexPath(row: row!, section: section!)) as! LargeEventTableViewCell).backView!)
            }
        } else {
            return nil
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let state = UserDefaults.standard.object(forKey: "weekView") as! Bool
        var anyObject : AnyObject! = nil
        if state {
            let isFirsthalf = Calendar.current.component(.month, from: Date()) <= 6
            anyObject = all_events[months[isFirsthalf ? segmentedControl.selectedSegmentIndex : segmentedControl.selectedSegmentIndex + 6]]?[indexPath.section+1]?[indexPath.row]
        } else {
            anyObject =  all_events[weekDays[segmentedControl.selectedSegmentIndex].0]?[weekDays[segmentedControl.selectedSegmentIndex].1]?[indexPath.row]
        }
        
        if state {
            return 50
        } else {
            if anyObject is Event {
                return 76
            } else if anyObject is Task {
                return 76
            } else {
                return 50
            }
        }
    }
    
    
}
//
//  MARK: End tableview configuration
//


extension TimetableViewController: AddToTimetable {
    func add() {
        get_today()
    }
}
