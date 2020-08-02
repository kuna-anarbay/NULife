//
//  ClubsViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/25/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPStorkController


class ClubsViewController: UIViewController, SetupCoursesViewControllerProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    var events: [(String, [ClubEvent])] = [(String, [ClubEvent])]()
    var allEvents: [(String, [ClubEvent])] = [(String, [ClubEvent])]()
    var clubs = [Club]()
    var allClubs = [Club]()
    var clubsState = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupTableView()
        fetchClubs()
        if clubsState {
            fetchAllClubs()
        } else {
            fetchAllEvents()
        }
    }
    
    
    func setupDesign(){
        titleLabel.text = clubsState ? "Clubs" : "Events"
        segmentedControl.setTitle(clubsState ? "All Clubs" : "All Events", forSegmentAt: 1)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupDesign()
    }

    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func controlChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showClub" {
            let dest = segue.destination as! ClubViewController
            dest.club = sender as! Club
        } else if segue.identifier == "showEvent" {
            let dest = segue.destination as! ClubEventViewController
            dest.event = sender as! ClubEvent
        }
    }
    

}




extension ClubsViewController: UITableViewDelegate, UITableViewDataSource {

    
    
    
    func fetchEvents(){
        ClubEvent.getAll(self.clubs.map({ (club) -> String in
            return club.id
        })) { (events) in
            self.events = []
            events.sorted(by: { (event1, event2) -> Bool in
                return event1.start < event2.start
            }).forEach { (event) in
                if let index = self.events.firstIndex(where: {$0.0 == Helper.displayDayMonth(timestamp: event.start)}) {
                    self.events[index].1.append(event)
                } else {
                    self.events.append((Helper.displayDayMonth(timestamp: event.start), [event]))
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func fetchAllEvents(){
        ClubEvent.getAll(nil) { (events) in
            self.allEvents = []
            events.sorted(by: { (event1, event2) -> Bool in
                return event1.start < event2.start
            }).forEach { (event) in
                if let index = self.allEvents.firstIndex(where: {$0.0 == Helper.displayDayMonth(timestamp: event.start)}) {
                    self.allEvents[index].1.append(event)
                } else {
                    self.allEvents.append((Helper.displayDayMonth(timestamp: event.start), [event]))
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func fetchClubs(){
        Club.getUserClubs { (clubs) in
            self.clubs = clubs
            self.fetchEvents()
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
    }
    
    func fetchAllClubs(){
        Club.getAll { (clubs) in
            self.allClubs = clubs
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
    }
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let sectionHeader = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(sectionHeader, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if clubsState {
            return 1
        } else {
            return segmentedControl.selectedSegmentIndex==0 ? events.count : allEvents.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if clubsState {
            return segmentedControl.selectedSegmentIndex==0 ? clubs.count : allClubs.count
        } else {
            return segmentedControl.selectedSegmentIndex==0 ? events[section].1.count : allEvents[section].1.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if clubsState {
            let cell = tableView.dequeueReusableCell(withIdentifier: "clubCell", for: indexPath) as! ClubTableViewCell
            
            let club = segmentedControl.selectedSegmentIndex==0 ? clubs[indexPath.row] : allClubs[indexPath.row]

            cell.clubName.text = club.title
            cell.mainImage.setImage(from: URL(string: club.urls["logo"] ?? ""))
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
            
            let event = segmentedControl.selectedSegmentIndex==0 ? events[indexPath.section].1[indexPath.row] : allEvents[indexPath.section].1[indexPath.row]

            
            cell.titleLabel.text = event.title
            cell.locationLabel.text = event.location
            if Helper.displayDayMonth(timestamp: event.start) == Helper.displayDayMonth(timestamp: event.end) {
                cell.timeLabel.text = Helper.display24HourTime(timestamp: event.start) + " - "
                                    + Helper.display24HourTime(timestamp: event.end)
            } else {
                if event.end == 0 {
                    cell.timeLabel.text = Helper.displayDate24HourFull(timestamp: event.start)
                } else {
                    cell.timeLabel.text = Helper.displayDate24HourFull(timestamp: event.start) + " - "
                    + Helper.displayDayMonth(timestamp: event.end)
                }
                
            }
            
            cell.mainImage.setImage(from: URL(string: event.urls[0]))
            
            return cell
        }
    }
    
    
    
    //MARK: HEADER
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if clubsState {
            return nil
        } else {
            
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
            
            
            if segmentedControl.selectedSegmentIndex == 0 {
                header.titleLabel.text = events[section].0
            } else {
                header.titleLabel.text = allEvents[section].0
            }
            
                      
            
            header.titleLabel.font = UIFont(name: "SfProDisplay-medium", size: 15)
            header.backView.backgroundColor = .systemBackground
            header.backgroundColor = .systemBackground
            header.detailLabel.text = ""
            header.topView.isHidden = true
            header.bottomView.isHidden = true
        
            return header
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if clubsState {
            return 0
        }
        return 38
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if clubsState {
            return 72
        } else {
            return 168
        }
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if clubsState {
            performSegue(withIdentifier: "showClub", sender: segmentedControl.selectedSegmentIndex==0 ? clubs[indexPath.row] : allClubs[indexPath.row])
        } else {
            performSegue(withIdentifier: "showEvent", sender: segmentedControl.selectedSegmentIndex==0 ? events[indexPath.section].1[indexPath.row] : allEvents[indexPath.section].1[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func add(at course: Course) {
        
    }
    
    func add(at event: ClubEvent) {
        event.add()
        tableView.reloadData()
    }
    
    func remove(at course: Course) {
        
    }
    
    func add(at task: Task) {
         
     }
}
