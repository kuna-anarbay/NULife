//
//  SetupCoursesViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/3/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SPStorkController
import SPAlert

protocol SetupCoursesViewControllerProtocol {
    func add(at course: Course)
    func add(at event: ClubEvent)
    func add(at task: Task)
    func remove(at course: Course) 
}


class SetupCoursesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var currentUser = User()
    
    var allCourses = [Course]()
    var filteredCourses = [Course]()
    var selectedCourses = [Course]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupSearchBar()
        setupTableView()
        getAllCourses()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if selectedCourses.count > 3 {
            let alert = UIViewController.getAlert("Enrolling...")
            self.present(alert, animated: true) {
                for course in self.selectedCourses {
                    course.enroll()
                }
                User.setupCurrentUser(completion: { (user) in
                    alert.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "showMain", sender: nil)
                    }
                })
            }
            
        } else {
            SPAlert.present(message: "Please select at least 4 courses")
        }
    }
    
    
    
    @IBAction func dismissPressed(_ sender: Any) {
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



//MARK:- Fetch data from Firebase
extension SetupCoursesViewController {
    
    func getAllCourses(){
        Course.getAllCourses { (courses) in
            self.allCourses = courses
            self.getFilteredCourses()
            self.tableView.reloadSections([1], with: .automatic)
        }
    }
    
    func getFilteredCourses(){
        if searchBar.text?.isEmpty ?? true {
            filteredCourses = allCourses.filter({ (course) -> Bool in
                return !selectedCourses.contains(where: {$0.id == course.id})
            })
        } else {
            self.filteredCourses = self.allCourses.filter({ (course) -> Bool in
                return !selectedCourses.contains(where: {$0.id == course.id}) && course.title.contains(searchBar.text!.uppercased())
            })
        }
    }
}


//MARK:- SetupTableView
extension SetupCoursesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return selectedCourses.count
        }
        return filteredCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath)
        
        let course = indexPath.section == 0 ? selectedCourses[indexPath.row] : filteredCourses[indexPath.row]
        
        cell.textLabel?.text = course.title
        cell.detailTextLabel?.text = course.longTitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
        if section == 0 {
            
            header.titleLabel.text = "Selected courses".uppercased()
            if selectedCourses.count > 3 {
                header.detailLabel.textColor = UIColor(named: "Success color")
                header.detailLabel.text = "\(selectedCourses.count) courses".uppercased()
            } else {
                header.detailLabel.textColor = UIColor(named: "Danger color")
                header.detailLabel.text = "\(4-selectedCourses.count) courses remained".uppercased()
            }
        } else {
            header.titleLabel.text = "All courses".uppercased()
            header.detailLabel.textColor = UIColor(named: "Muted text color")
            header.detailLabel.text = "\(filteredCourses.count) courses".uppercased()
        }
        
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            popupDetailsView(at: selectedCourses[indexPath.row], at: false)
        } else {
            popupDetailsView(at: filteredCourses[indexPath.row], at: true)
        }
    }
}


//MARK:- SetupSearchBar
extension SetupCoursesViewController: UISearchBarDelegate {
    
    func setupSearchBar(){
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getFilteredCourses()
        self.view.endEditing(true)
        tableView.reloadSections([1], with: .automatic)
    }
    
}


//MARK:- Functions
extension SetupCoursesViewController: SetupCoursesViewControllerProtocol {
    
    
    func add(at task: Task) {
        
    }
    
    func add(at event: ClubEvent) {
        
    }
    
    //MARK: Show details popup
    func popupDetailsView(at course: Course, at isAdd: Bool){
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "CourseDetailViewController") as! CourseDetailViewController
        controller.course = course
        controller.delegate = self
        if !isAdd {
            controller.currentState = .remove
        } else {
            controller.currentState = .add
        }
        self.presentAsStork(controller, height: 451, showIndicator: true, showCloseButton: true)
    }
    
    
    //MARK: Add or Remove course protocol
    func add(at course: Course) {
        self.selectedCourses.append(course)
        getFilteredCourses()
        self.tableView.reloadSections(IndexSet(integersIn: 0...1), with: .automatic)
    }
    
    
    func remove(at course: Course) {
        self.selectedCourses.removeAll(where: {$0.title == course.title})
        getFilteredCourses()
        self.tableView.reloadSections(IndexSet(integersIn: 0...1), with: .automatic)
    }
}



