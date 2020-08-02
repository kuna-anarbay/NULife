//
//  DashboardViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/3/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SPStorkController

class DashboardViewController: UIViewController {
    
    //MARK: Fields
    @IBOutlet weak var tableView: UITableView!
    var filteredCourses : [Course] = [Course]()
    var allCourses : [Course] = [Course]()
    let searchController = UISearchController(searchResultsController: nil)
    let impact = UIImpactFeedbackGenerator()
    var userCourses : [Course] = [Course]()

    
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchBarController()
        self.setupTableView()
        self.setupLongPressGesture()
        User.checkUser { (exists) in
            if !exists {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = mainStoryboard.instantiateViewController(identifier: "loginVC") as! InitialViewController
                loginViewController.providesPresentationContextTransitionStyle = true
                loginViewController.definesPresentationContext = true
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true, completion: nil)
            } else {
                if UserDefaults.standard.string(forKey: "anonymousId") == nil || UserDefaults.standard.string(forKey: "profile_url") == nil {
                    User.getCurrentUser { (user) in
                        UserDefaults.standard.setValue(user.anonymousId, forKey: "anonymousId")
                        UserDefaults.standard.setValue(user.image, forKey: "profile_url")
                    }
                }
                self.getUserCourses()
                AppConfigurations().registerForPushNotifications()
                AppConfigurations().registerPushNotificationCategories()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        User.checkUser { (exists) in
            if !exists {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = mainStoryboard.instantiateViewController(identifier: "loginVC") as! InitialViewController
                loginViewController.providesPresentationContextTransitionStyle = true
                loginViewController.definesPresentationContext = true
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true, completion: nil)
            }
        }
    }
    
    
    
    //MARK: Prepare for segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let dest = segue.destination as! CourseInfoViewController
            dest.course = sender as? Course
        } else if segue.identifier == "showCourse" {
            let dest = segue.destination as! CourseSectionsViewController
            dest.course = sender as? Course
        }
    }

}


//MARK:- Setup table view
extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    //MARK: Setup table view
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 72
    }
    
    
    //MARK: Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCourses.count
    }
    
    
    //MARK: Cell for row at
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        cell.setup(course: filteredCourses[indexPath.row])
        
        return cell
    }
    
    
    //MARK: Did select row at
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isFiltering() {
            performSegue(withIdentifier: "showCourse", sender: filteredCourses[indexPath.row])
        } else {
            popupDetailsView(at: filteredCourses[indexPath.row], at: .add)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: Swipe table view cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let course = filteredCourses[indexPath.row]
        
        
        //MARK: Edit course details
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, handler) in
            self.popupDetailsView(at: self.filteredCourses[indexPath.row], at: .edit)
        }
        editAction.image = UIImage(named: "editIcon")
        editAction.backgroundColor = .systemBackground
        
        
        //MARK: Unenroll from course
        let deleteAction = UIContextualAction(style: .normal, title: "Leave") { (action, sourceView, handler) in
            
            let alert = UIAlertController(title: "Leave " + course.title + "?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { (_) in
                course.unEnroll()
                self.getUserCourses()
                self.tableView.reloadSections([0], with: .automatic)
            }))
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        deleteAction.image = UIImage(named: "deleteIcon")
        deleteAction.backgroundColor = .systemBackground
        
        
        //MARK: Check filtering or not
        if !isFiltering() {
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        } else {
            return nil
        }
        
    }
}



//MARK:- Setup search controller
extension DashboardViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    
    //MARK: Setup search bar
    func setupSearchBarController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search courses"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    
    //MARK: Update search results
    func updateSearchResults(for searchController: UISearchController) {
        print("Textting")
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
    //MARK: Search text entered
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        getAllCourses()
    }
    
    
    // MARK: Get searched courses
    func filterContentForSearchText(_ searchText: String) {
        if searchText.count != 0 {
            self.filteredCourses = self.allCourses.filter({ (course) -> Bool in
                
                let userDontContain = userCourses.count == 0 || !userCourses.contains(where: {$0.id == course.id})
                let titleContains = course.title.uppercased() .contains(searchController.searchBar.text!.uppercased())
                let longTitleContains = course.longTitle.uppercased()
                    .contains(searchController.searchBar.text!.uppercased())
                
                print(userDontContain)
                print(titleContains)
                print(longTitleContains)
                return userDontContain && (titleContains || longTitleContains)
            })
            tableView.reloadData()
        } else {
            getUserCourses()
        }
    }
    
    
    //MARK: Check search bar
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    //MARK: Is filtering
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
}



//MARK:- Fetch data
extension DashboardViewController {
    
    
    //MARK: Get user courses
    func getUserCourses(){
        Course.getUserCourses { (courses) in
            self.filteredCourses = courses
            self.userCourses = courses
            self.tableView.reloadData()
        }
    }
    
    //MARK: Get all courses
    func getAllCourses() {
        Course.getAllCourses { (courses) in
            self.allCourses = courses
            self.tableView.reloadData()
        }
    }
}



//MARK:- Functions
extension DashboardViewController: SetupCoursesViewControllerProtocol {
    
    
    
    func add(at task: Task) {
        
    }
    
    
    
    func add(at event: ClubEvent) {
        
    }
    
    //MARK: Show details popup
    func popupDetailsView(at course: Course, at state: courseDetailState){
        let controller = self.storyboard!.instantiateViewController(identifier: "CourseDetailViewController") as! CourseDetailViewController
        controller.course = course
        controller.delegate = self
        controller.currentState = state
        self.presentAsStork(controller, height: 451, showIndicator: true, showCloseButton: true)
    }
    
    
    //MARK: Add or Remove course protocol
    func add(at course: Course) {
        course.enroll()
        
        searchController.isActive = false
        searchController.searchBar.endEditing(true)
    }
    
    
    func remove(at course: Course) {
        course.unEnroll()
    }
}



//MARK:- Show course info
extension DashboardViewController {
    
    //MARK: SETUP LONG PRESS GESTURE RECOGNIZER
    func setupLongPressGesture() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    
    //MARK: LONG PRESS A CELL
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if !isFiltering() {
            if sender.state == UIGestureRecognizer.State.began {
                impact.impactOccurred()
                let touchPoint = sender.location(in: self.tableView)
                if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                    let course = filteredCourses[indexPath.row]
                    performSegue(withIdentifier: "showDetails", sender: course)
                }
            }
        }
    }

}
