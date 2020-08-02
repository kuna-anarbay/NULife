//
//  ClubViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/13/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase

class ClubViewController: UIViewController {

    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var width : CGFloat = 0.0
    var firstSegment = true
    var club = Club()
    var events = [ClubEvent]()
    
    
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
        
        tableView.separatorStyle = .none
        width = self.view.bounds.width
        closeButton.layer.cornerRadius = 18
        backView.layer.cornerRadius = 16
        backView.layer.shadowColor = UIColor.lightGray.cgColor
        backView.layer.shadowOpacity = 0.4
        backView.layer.shadowOffset = .zero
        backView.layer.shadowRadius = 16
        setupTableView()
        fetchClubs()
    }
    
    
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEvent" {
            let dest = segue.destination as! ClubEventViewController
            dest.event = sender as! ClubEvent
        }
    }
    

}

extension ClubViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    func fetchEvents(){
        ClubEvent.getAll(self.club.id) { (events) in
            self.events = events
            self.tableView.reloadData()
        }
    }
    
    func fetchClubs(){
        Club.getOne(self.club.id) { (club) in
            if club.notNull {
                self.club = club
                self.imageView.setImage(from: URL(string: club.urls["background"] ?? ""))
                self.fetchEvents()
                self.tableView.reloadData()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
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
        handleScroll()
    }
    
    func handleScroll(){
        backView.leadingConstraint?.constant = 16 - 16*tableView.contentOffset.y/width
        backView.topConstraint?.constant = tableView.contentOffset.y*(-1/2) - 48
        backView.trailingConstraint?.constant = 16 - 16*tableView.contentOffset.y/width
        backView.layer.cornerRadius = 16 - 16*tableView.contentOffset.y/width
        
        if tableView.contentOffset.y <= 0 {
            closeButton.alpha = 1 - tableView.contentOffset.y*(-1)*2/100
            imageView.topConstraint?.constant = tableView.contentOffset.y*(-1)
        } else {
           imageView.topConstraint?.constant = tableView.contentOffset.y*(-1/2)
        }
    }
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellsCount = firstSegment ? 4 : events.count
        return section==0 ? 2 : cellsCount
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            } else {
                let headerCell =  tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! ClubHeaderTableViewCell
                
                headerCell.titleLabel.text = club.title
                headerCell.followersLabel.text = "\(club.followers?.count ?? 0) followers"
                headerCell.club = club
                headerCell.mainImage.setImage(from: URL(string: club.urls["logo"] ?? ""))
                headerCell.followButton.setTitle(club.followers?.index(forKey: Auth.auth().currentUser!.uid) != nil ? "Unfollow" : "Follow", for: .normal)
                
                return headerCell
            }
        } else {
            if firstSegment {
                if indexPath.row == 0 {
                    let aboutCell = tableView.dequeueReusableCell(withIdentifier: "bodyCell", for: indexPath) as! ClubTextTableViewCell
                    aboutCell.titleLabel.text = "About US"
                    aboutCell.bodyLabel.text = club.details
                    
                    return aboutCell
                } else if indexPath.row == 1 {
                    let membershipCell = tableView.dequeueReusableCell(withIdentifier: "bodyCell", for: indexPath) as! ClubTextTableViewCell
                    membershipCell.titleLabel.text = "How to join"
                    membershipCell.bodyLabel.text = club.membership
                    
                    return membershipCell
                } else if indexPath.row == 2 {
                    
                   let teamCell = tableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath) as! ClubTeamTableViewCell
                    
                    teamCell.heads = club.heads ?? [:]
                    
                    return teamCell
                } else {
                    let contactsCell = tableView.dequeueReusableCell(withIdentifier: "contactsCell", for: indexPath) as! ClubContactsTableViewCell
                    
                    contactsCell.contacts = club.contacts ?? []
                    
                    return contactsCell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
                
                let event = events[indexPath.row]

                cell.titleLabel.text = event.title
                cell.locationLabel.text = event.location
                if event.end == 0 {
                    cell.timeLabel.text = Helper.displayDate24HourFull(timestamp: event.start)
                } else {
                    if Helper.displayDayMonth(timestamp: event.start) == Helper.displayDayMonth(timestamp: event.end) {
                        cell.timeLabel.text = Helper.display24HourTime(timestamp: event.start) + " - "
                                            + Helper.display24HourTime(timestamp: event.end)
                    } else {
                        cell.timeLabel.text = Helper.displayDate24HourFull(timestamp: event.start) + " - " + Helper.displayDayMonth(timestamp: event.end)
                    }
                }
                
                cell.mainImage.setImage(from: URL(string: event.urls[0]))
                
                return cell
            }
            
        }
     }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !firstSegment && indexPath.section == 1 {
            performSegue(withIdentifier: "showEvent", sender: events[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return tableView.frame.width - 16
            } else {
                return 120
            }
        } else {
            if firstSegment {
                if indexPath.row == 2 {
                    let count = (club.heads?.count ?? 0)%2==0 ? (club.heads?.count ?? 0)/2 : (club.heads?.count ?? 0)/2+1
                    return CGFloat(count)*120 + 55
                } else if indexPath.row == 3 {
                    return CGFloat((club.contacts?.count ?? 0)*44 + 55)
                }
                return UITableView.automaticDimension
            } else {
                return 168
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section==0 ? 0 : 54
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customSC = UISegmentedControl(items: ["Info", "Events"])
        customSC.selectedSegmentIndex = firstSegment ? 0 : 1

        customSC.frame = CGRect(x: 16, y: 12, width: tableView.bounds.width-32, height: 30)
       
        // Add target action method
        customSC.addTarget(self, action: #selector(changeColor), for: .valueChanged)

        let back = UIView()
        back.backgroundColor = .systemBackground
        back.addSubview(customSC)
        
        return back
    }
    
    @objc func changeColor(sender: UISegmentedControl) {
        firstSegment = sender.selectedSegmentIndex==0
        tableView.allowsSelection = !firstSegment
        tableView.reloadSections([1], with: .automatic)
        handleScroll()
    }
    
}
