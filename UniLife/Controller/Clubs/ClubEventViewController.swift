//
//  ClubEventViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/13/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import SPStorkController
import SPAlert

class ClubEventViewController: UIViewController, SetupCoursesViewControllerProtocol {
    
    @IBOutlet weak var CloseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    var event = ClubEvent()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let windowScene = UIApplication.shared
                        .connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .first
        if let windowScene = windowScene as? UIWindowScene {
            let statusbarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: windowScene.statusBarManager?.statusBarFrame.size.height ?? 20))
            
            statusbarView.backgroundColor = UIColor(named: "White color")
            view.addSubview(statusbarView)
        }
        setupTableView()
        fetchEvents()
        CloseButton.layer.cornerRadius = 18
        // Do any additional setup after loading the view.
    }
    

    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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


extension ClubEventViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, EventActionProtocol {
    
    func fetchEvents(){
        ClubEvent.getOne(event.id) { (event) in
            if event.notNull {
                self.event = event
                self.imageView.setImage(from: URL(string: event.urls[0]))
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //MARK: Show details popup
    func popupDetailsView(){
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "CourseDetailViewController") as! CourseDetailViewController
        let transitionDelegate = SPStorkTransitioningDelegate()
        transitionDelegate.customHeight = 560
        controller.transitioningDelegate = transitionDelegate
        controller.event = event
        controller.delegate = self
        controller.currentState = .event
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        self.present(controller, animated: true, completion: nil)
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if tableView.contentOffset.y < -100 {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            let transition: CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromBottom
            self.view.window!.layer.add(transition, forKey: nil)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y <= 0 {
            CloseButton.alpha = 1 - tableView.contentOffset.y*(-1)*2/100
            imageView.topConstraint?.constant = tableView.contentOffset.y*(-1)
        } else if tableView.contentOffset.y > 0 && tableView.contentOffset.y < tableView.frame.width*4/3 - 28 {
           imageView.topConstraint?.constant = tableView.contentOffset.y*(-1/2)
        }
    }
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 2
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
        } else {
            let eventInfoCell = tableView.dequeueReusableCell(withIdentifier: "eventInfoCell", for: indexPath) as! EventInfoTableViewCell
            
            eventInfoCell.delegate = self
            if Constants.realm.objects(Task.self).contains(where: {$0.identifier == event.id}){
                eventInfoCell.addButton.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
            } else {
                eventInfoCell.addButton.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
            }
            
            eventInfoCell.registration = event.registration
            eventInfoCell.eventId = event.id
            eventInfoCell.titleLabel.text = event.title
            eventInfoCell.bodyLabel.text = event.details
            eventInfoCell.locationLabel.text = event.location
            if event.end == 0 {
                eventInfoCell.timeLabel.text = Helper.displayDate24HourFull(timestamp: event.start)
            } else {
                if Helper.displayDayMonth(timestamp: event.start) == Helper.displayDayMonth(timestamp: event.end) {
                    eventInfoCell.timeLabel.text = Helper.display24HourTime(timestamp: event.start) + " - "
                                        + Helper.display24HourTime(timestamp: event.end)
                } else {
                    eventInfoCell.timeLabel.text = Helper.displayDate24HourFull(timestamp: event.start) + " - " + Helper.displayDayMonth(timestamp: event.end)
                }
            }
            eventInfoCell.clubLabel.text = event.club["title"]
            
            eventInfoCell.clubImage.setImage(from: URL(string: event.club["logo"]!))
            return eventInfoCell
        }
     }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.frame.width*4/3 - 28
        }
        
        return UITableView.automaticDimension
    }
    
}


extension ClubEventViewController {
    func add() {
        popupDetailsView()
    }
    
    func add(at event: ClubEvent) {
        event.add()
        self.tableView.reloadData()
    }
    
    func share() {
        
        let alert = UIViewController.getAlert("Preparing the event")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
        var registerLink: String = "nil"
        if let registration = event.registration {
            if let link = registration["link"] as? String {
                registerLink = "\nRegistration: " + link
            }
        }
        let titleString = event.title +
            "\n\nDate: " + Helper.displayDate12HourFull(timestamp: event.start) +
            "\nLocation: " + event.location +
            registerLink +
            "\n\n" + event.details
        
        var vc = UIActivityViewController(activityItems: [titleString], applicationActivities: [])
        if let url = URL(string: event.urls[0]) {
            do {
                if let image = UIImage(data: try Data(contentsOf: url)) {
                    vc = UIActivityViewController(activityItems: [titleString, image], applicationActivities: [])
                    alert.dismiss(animated: true) {
                        self.present(vc, animated: true)
                    }
                } else {
                    alert.dismiss(animated: true) {
                        self.present(vc, animated: true)
                    }
                }
            } catch {
                SPAlert.present(message: "Image not found")
                alert.dismiss(animated: true, completion: nil)
            }
        } else {
            alert.dismiss(animated: true) {
                self.present(vc, animated: true)
            }
        }
    }
    
    func add(at task: Task) {
        
    }
    
    
    
    func add(at course: Course) {
        
    }
    
    func remove(at course: Course) {
        
    }
    
    func remove() {
        let alert = UIViewController.getAlertWithCancelButton("Remove from my timetable?")
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
            let event = Constants.realm.object(ofType: Task.self, forPrimaryKey: self.event.id)
            event?.delete()
            self.tableView.reloadData()
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
}
