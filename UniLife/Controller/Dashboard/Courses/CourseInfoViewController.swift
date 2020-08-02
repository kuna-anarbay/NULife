//
//  CourseInfoViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/9/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert


class CourseInfoViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var course: Course!
    var documentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        documentInteractionController.delegate = self
        setupCourse()
    }
    
}



//MARK:- Setup table view
extension CourseInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func setupCourse(){
        Course.getByIdAndSection(course.id, course.section) { (course) in
            self.course = course
            self.tableView.reloadData()
        }
    }
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CourseHeaderTableViewCell", bundle: nil) , forCellReuseIdentifier: "courseHeaderCell")
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return 1
        } else {
            return course.students.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "courseHeaderCell", for: indexPath) as! CourseHeaderTableViewCell
            
            cell.setup(title: course.title, detail: course.longTitle)
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Section"
                    cell.detailTextLabel?.text = course.section + "L"
                    cell.accessoryType = .none
                case 1:
                    cell.textLabel?.text = "Professor"
                    if course.professor == "" {
                        cell.detailTextLabel?.text = "Not set yet"
                    } else {
                        cell.detailTextLabel?.text = course.professor
                    }
                    cell.accessoryType = .none
                default:
                    cell.textLabel?.text = "Students"
                    cell.detailTextLabel?.text = "\(course.students.count) students"
            }
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
            cell.textLabel?.text = "Open syllabus"
            if course.syllabus != "" {
                cell.textLabel?.textColor = UIColor(named: "Main color")
            } else {
                cell.textLabel?.textColor = UIColor(named: "Muted text color")
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.textLabel?.text = course.students[indexPath.row].name
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .none
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75
        } else if indexPath.section == 1 {
            return 44
        } else {
            return 44
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
        
        if section == 1 {
            header.titleLabel.text = "Course info".uppercased()
        } else if section == 2 {
            header.titleLabel.text = ""
        } else if section == 3 {
            header.titleLabel.text = "Students".uppercased()
        }
        
        header.detailLabel.text = ""
        
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if section == 1 {
            return 38
        } else if section == 2 {
           return 16
        } else {
            return 38
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if course.syllabus != "" {
                let storageId = Constants.syllabusRef.child(course.id).child(course.section)
                
                self.storeAndShare(name: "Syllabus", ref: storageId, controller: self.documentInteractionController, contentType: "")
            } else {
                SPAlert.present(message: "No syllabus found")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
