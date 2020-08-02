//
//  TodayViewController.swift
//  GoStudy Widget
//
//  Created by Kuanysh Anarbay on 8/20/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    
    var config = Realm.Configuration()
    
    // Use the default directory, but replace the filename with the username
    
    var realmSwift = try! Realm()
    var currentDay : [AnyObject] = [AnyObject]()
    let days = ["monday", "tuesday", "wednesday", "thursday", "friday"]
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @IBOutlet weak var lessonTable: UITableView!
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var dayOfWeek: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realmDirectory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kuanysh-anarbay.unilife.realm")!
                let realmPath = realmDirectory.appendingPathComponent("db.realm").absoluteURL
        config.fileURL = realmPath
        realmSwift = try! Realm(configuration: config)
        lessonTable.delegate = self
        lessonTable.dataSource = self
        
        lessonTable.register(UINib(nibName: "LessonTableViewCell", bundle: nil) , forCellReuseIdentifier: "lessonCell")

        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        // Do any additional setup after loading the view.
    }
    
    func loadCourses(){
        currentDate.text = "\(Calendar.current.component(.day, from: Date()))"
        dayOfWeek.text = weekDays[Calendar.current.component(.weekday, from: Date()) - 1]
        
        let weekDay = Calendar.current.component(.weekday, from: Date()) > 1 ? Calendar.current.component(.weekday, from: Date()) - 2 : 6
        
        currentDay = Array(realmSwift.objects(Event.self).filter({ $0.days_list[weekDay]}))
        
        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar,
                                            year: calendar.component(.year, from: Date()),
                                            month: calendar.component(.month, from: Date()),
                                            day: calendar.component(.day, from: Date()))
        let date = Int(calendar.date(from: dateComponents)!.timeIntervalSince1970)
        currentDay.append(contentsOf: Array(realmSwift.objects(Task.self).filter{ $0.start >= date && $0.start < date + 24*3600 }))
        currentDay = currentDay.sorted { (first, second) -> Bool in
            return first.start <= second.start
        }
        lessonTable.reloadData()
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: 0, height: currentDay.count*55)
        }
    }
    
    
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        loadCourses()
        completionHandler(NCUpdateResult.newData)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lessonTable.dequeueReusableCell(withIdentifier: "lessonCell", for: indexPath) as! LessonTableViewCell
        let event = currentDay[indexPath.row]
        if event is Task {
            let task = event as! Task
            cell.lessonName!.text = task.name
            cell.lessonDetail?.text = Helper.display12HourTime(timestamp: task.start) + " - " + Helper.display12HourTime(timestamp: task.end) + " at " + task.location
            cell.cellBackground.backgroundColor = UIColor(hex: task.color)
        } else {
            let routine = event as! Event
            cell.lessonName!.text = routine.name
            cell.lessonDetail?.text = Helper.display12HourTime(timestamp: routine.start) + " - " + Helper.display12HourTime(timestamp: routine.end) + " at " + routine.location
            cell.cellBackground.backgroundColor = UIColor(hex: routine.color)
        }
        
        return cell
        
    }
    
}
