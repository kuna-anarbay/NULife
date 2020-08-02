//
//  BookingViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/27/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import SPAlert
import Firebase


class BookingViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    var room: Room = Room()
    let days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRoom()
        termsLabel.isUserInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    
    func fetchRoom(){
        Constants.bookingRefs.child(room.id).observe(.value) { (snapshot) in
            self.room = Room(snapshot)
            self.setupDesign()
            self.setupSegmentedControl()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func toggleTerms(_ sender: UITapGestureRecognizer) {
        let animation = UIViewPropertyAnimator(duration: 100, controlPoint1: .zero, controlPoint2: .zero) {
            self.termsLabel.numberOfLines = self.termsLabel.numberOfLines == 4 ? 20: 4
        }
        
        animation.startAnimation()
    }
    
    func setupSegmentedControl(){
        segmentedControl.removeAllSegments()
        for day in room.days {
            segmentedControl.insertSegment(withTitle: day.key, at: self.days.firstIndex(of: day.key)!, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
    }
    
    
    func setupDesign(){
        roomLabel.text = "Room " + room.room
        blockLabel.text = "Block " + room.block
        termsLabel.text = room.terms
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


extension BookingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if room.days[days[segmentedControl.selectedSegmentIndex]] != nil {
           return room.days[days[segmentedControl.selectedSegmentIndex]]!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let slot = room.days[days[segmentedControl.selectedSegmentIndex]]![indexPath.row]
        cell.textLabel?.text = Helper.display24HourTime(timestamp: slot.0) + " - " + Helper.display24HourTime(timestamp: slot.1)
        if room.list[days[segmentedControl.selectedSegmentIndex]] != nil {
            if let user = room.list[days[segmentedControl.selectedSegmentIndex]]?.first(where: {$0.0 == indexPath.row}) {
                cell.detailTextLabel?.text = user.2
            } else {
                cell.detailTextLabel?.text = ""
            }
        } else {
            cell.detailTextLabel?.text = ""
        }
        cell.accessoryType = .none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let user = room.list[days[segmentedControl.selectedSegmentIndex]]?.first(where: {$0.0 == indexPath.row}) {
            if user.1 == Auth.auth().currentUser?.uid {
                let slot = room.days[days[segmentedControl.selectedSegmentIndex]]![indexPath.row]
                let alert = UIAlertController(title: "Book room: " + room.block + "." + room.room, message: "Slot \(indexPath.row):" + Helper.display24HourTime(timestamp: slot.0) + " - " + Helper.display24HourTime(timestamp: slot.1), preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Remove me", style: .destructive, handler: { (action) in
                    self.room.remove(day: self.days[self.segmentedControl.selectedSegmentIndex], slot_id: indexPath.row)
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                SPAlert.present(message: "Sorry, but the slot is booked by somebody else")
            }
        } else {
            let slot = room.days[days[segmentedControl.selectedSegmentIndex]]![indexPath.row]
            let alert = UIAlertController(title: "Book room: " + room.block + "." + room.room, message: "Slot \(indexPath.row): " + Helper.display24HourTime(timestamp: slot.0) + " - " + Helper.display24HourTime(timestamp: slot.1), preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Book", style: .default, handler: { (action) in
                self.room.book(day: self.days[self.segmentedControl.selectedSegmentIndex], slot_id: indexPath.row)
                
                let task = Task(value: [
                    "identifier": self.room.id,
                    "name": "Booking " + self.room.block + "." + self.room.room,
                    "color": "#00CC99",
                    "start": slot.0,
                    "end": slot.1,
                    "topic": "Booking",
                    "location": self.room.block + "." + self.room.room,
                    "reminder": 30*60
                    ])
                task.add()
                alert.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
