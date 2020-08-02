//
//  EventDetailViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/22/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import RealmSwift

class EventDetailViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    private var isActiveState:Bool = true
    var days = [String]()
    let daysList = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var all_tasks : [String : [Task]] = [:]
    var event = Event()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDesign()
        setupTableView()
        get_today()
    }
    
    
    func setupDesign(){
        title = event.name
        titleLabel.text = event.name
        daysLabel.text = ""
        for i in 0..<event.days_list.count {
            if event.days_list[i] {
                daysLabel.text! += " " + self.daysList[i]
            }
        }
        detailLabel.text = event.location + " \u{2022} " + event.professor
        timeLabel.text = [Helper.display24HourTime(timestamp: event.start), Helper.display24HourTime(timestamp: event.end)].joined(separator: " - ")
        imageView.image = UIImage(systemName: event.icon)?.withTintColor(UIColor(hexString: event.color))
        imageView.tintColor = UIColor(hexString: event.color)
    }
    
    @IBAction func switchSegment(_ sender: UISegmentedControl) {
        isActiveState = sender.selectedSegmentIndex==0
        get_today()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func get_today() {
        var temp_all_tasks = isActiveState ? Array(Constants.realm.objects(Task.self).filter({$0.topic == self.event.name && $0.start > Int(Date().timeIntervalSince1970)})) : Array(Constants.realm.objects(Task.self).filter({$0.topic == self.event.name}))
        temp_all_tasks.sort { (task1, task2) -> Bool in
            return task1.start < task2.start
        }
        var temp_tasks : [String : [Task]] = [:]
        var allDays = [String]()
        for task in temp_all_tasks {
            if !allDays.contains(Helper.displayDayMonth(timestamp: task.start)) {
                allDays.append(Helper.displayDayMonth(timestamp: task.start))
            }
            if temp_tasks[Helper.displayDayMonth(timestamp: task.start)] == nil {
                temp_tasks[Helper.displayDayMonth(timestamp: task.start)] = [task]
            } else {
                if !temp_tasks[Helper.displayDayMonth(timestamp: task.start)]!.contains(where: {$0.identifier == task.identifier}) {
                    temp_tasks[Helper.displayDayMonth(timestamp: task.start)]!.append(task)
                }
            }
        }
        days = allDays
        all_tasks = temp_tasks
        tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            let dest = segue.destination as! AddEventViewController
            dest.currentState = .personal
            dest.new_task.topic = event.name
        }
    }
    

}


extension EventDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return all_tasks.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return all_tasks[days[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! LargeEventTableViewCell
        let task = all_tasks[days[indexPath.section]]![indexPath.row]
        
        cell.titleLabel.text = task.name
        cell.titleLabel.textColor = .label
           
        cell.detailLabel.text = task.location
        cell.detailLabel.textColor = .lightGray
        
        if task.end != 0 {
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
            
        header.titleLabel.text = days[section]
        header.detailLabel.text = ""
        header.topView.backgroundColor = .clear
        header.bottomView.backgroundColor = .clear
    
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
}
