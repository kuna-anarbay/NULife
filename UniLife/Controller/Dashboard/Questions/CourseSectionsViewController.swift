//
//  CourseSectionsViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/9/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import SPStorkController
import SPAlert



class CourseSectionsViewController: UIViewController {

    
    let documentInteractionController = UIDocumentInteractionController()
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var resources : [(String, [Resource])] = [(String, [Resource])]()
    var deadlines : [(String, [Deadline])] = [(String, [Deadline])]()
    var questions : [(String, Bool, [Question])] = [(String, Bool, [Question])]()
    
    var currentState: courseSectionsState = .questions
    var course: Course!
    var alert = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        documentInteractionController.delegate = self
        fetchData()
        setupTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        title = course.title
        tableView.reloadData()
    }
    
    
    
    @IBAction func segmentControllerChanged(_ sender: Any) {
        fetchData()
    }
    
    
    func fetchData(){
        if segmentController.selectedSegmentIndex == 0 {
            currentState = .questions
            fetchQuestions()
        } else if segmentController.selectedSegmentIndex == 1 {
            currentState = .deadlines
            fetchDeadlines()
        } else {
            currentState = .resources
            fetchResources()
        }
    }
    
    
    
    @IBAction func addPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let askAction = UIAlertAction(title: "Add question", style: .default, handler: { (action) in
            
            self.performSegue(withIdentifier: "addQuestion", sender: nil)
        })
        
        let addDeadline = UIAlertAction(title: "Add deadline", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "addDeadline", sender: true)
        })
        
        let addResource = UIAlertAction(title: "Add resource", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "addDeadline", sender: false)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(askAction)
        alert.addAction(addDeadline)
        alert.addAction(addResource)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addQuestion" {
            let dest = segue.destination as! UINavigationController
            let destView = dest.viewControllers[0] as! NewQuestionViewController
            destView.course = course
            if sender != nil {
                destView.editState = true
                destView.newQuestion = sender as! Question
            }
        } else if segue.identifier == "addDeadline" {
            let dest = segue.destination as! UINavigationController
            let destView = dest.viewControllers[0] as! NewDeadlineViewController
            destView.courseId = course.title
            destView.section = course.section
            destView.currentState = (sender as! Bool) ? .normal : .resource
        } else if segue.identifier == "showImages" {
            let dest = segue.destination as! ImagesViewController
            let resource = sender as! Resource
            dest.refs = resource.urls
            
        } else if segue.identifier == "showQuestion" {
            let dest = segue.destination as! AnswerViewController
            dest.question = sender as! Question
        }
    }
    

}



//MARK:- Setup table view
extension CourseSectionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CourseHeaderTableViewCell", bundle: nil) , forCellReuseIdentifier: "courseHeaderCell")
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
        let topicNib = UINib(nibName: "TopicHeader", bundle: nil)
        tableView.register(topicNib, forHeaderFooterViewReuseIdentifier: "topicHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch currentState {
            case .questions:
                return questions.count
            case .deadlines:
                return deadlines.count
            default:
                return resources.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentState {
            case .questions:
                return questions[section].1 ? questions[section].2.count : 0
            case .deadlines:
                return deadlines[section].1.count
            default:
                return resources[section].1.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch currentState {
            case .questions:
                let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! TopicQuestionTableViewCell
                let question = questions[indexPath.section].2[indexPath.row]
                
                cell.authorLabel.text = question.author.name
                cell.bodyLabel.text = question.title
                cell.detailsLabel.text = "\(question.answersCount) \u{2022} \(Helper.displayDate24HourFull(timestamp: question.timestamp))"
                cell.resolvedImageView.image = question.resolved ? UIImage(systemName: "checkmark") : nil
                
                if questions[indexPath.section].1 && indexPath.row == questions[indexPath.section].2.count-1 {
                    cell.backView.layer.cornerRadius = 12
                    cell.backView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                } else {
                    cell.backView.layer.cornerRadius = 0
                }
            
                return cell
            case .deadlines:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "deadlineCell", for: indexPath) as! DeadlineTableViewCell
                    let deadline = deadlines[indexPath.section].1[indexPath.row]
                    cell.titleLabel.text = deadline.title
                    cell.timelabel.text = Helper.display24HourTime(timestamp: deadline.timestamp)
                    if deadline.section == "0" {
                        cell.subTitleLabel.text = "All sections" + " \u{2022} " + (deadline.location ?? "")
                    } else {
                        cell.subTitleLabel.text = "Section-" + deadline.section + " \u{2022} " + (deadline.location ?? "")
                    }
                    
                    cell.colorView.backgroundColor = UIColor(hexString: deadline.color)
                    if Constants.realm.objects(Task.self).contains(where: {$0.identifier == deadline.id}) {
                        cell.stateImageView.image = UIImage(systemName: "checkmark.seal.fill")
                    } else {
                        cell.stateImageView.image = UIImage(systemName: "plus.circle")
                    }
                    
                    
                    return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "resourceCell", for: indexPath) as! ResourceTableViewCell
                    
                    let resource = resources[indexPath.section].1[indexPath.row]
                cell.typeImageView.image = UIImage(named: resource.contentType)
                
                cell.titleLabel.text = resource.assessment
                cell.subTitleLabel.text = resource.semester + " \u{2022} " + (resource.professor ?? "")
                
                    return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch currentState {
            case .questions:
                return 76
            default:
                return 70
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch currentState {
            case .questions:
                let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "topicHeader") as! TopicHeader
                
                header.section = section
                header.titleLabel.text = questions[section].0
                header.detailLabel.text = "\(questions[section].2.count) questions"
                header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openSection)))
                
                header.backView.layer.cornerRadius = 12
                if questions[section].1 {
                    header.backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                } else {
                    header.backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                }
                
                
                return header
            case .deadlines:
                let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
                
                header.titleLabel.text = deadlines[section].0
                header.detailLabel.text = ""
                header.backView.backgroundColor = .secondarySystemBackground
                header.topView.backgroundColor = .clear
                header.bottomView.backgroundColor = .clear
            
                return header
            default:
                let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
                
                header.titleLabel.text = resources[section].0
                header.detailLabel.text = ""
                header.backView.backgroundColor = .secondarySystemBackground
                header.topView.backgroundColor = .clear
                header.bottomView.backgroundColor = .clear
            
                return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch currentState {
            case .questions:
                return 70
            default:
                return 38
        }
    }
    
    
    //MARK: SWIPE TABLE VIEW CELL
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, handler) in
            
            let question = self.questions[indexPath.section].2[indexPath.row]
            self.performSegue(withIdentifier: "addQuestion", sender: question)
        }
        editAction.backgroundColor = .orange
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, handler) in
            let question = self.questions[indexPath.section].2[indexPath.row]
            question.firebaseDelete { (message) in
                if message == .success {
                    SPAlert.present(title: "Successfully deleted", preset: .done)
                } else {
                    SPAlert.present(title: "Failed to delete", preset: .error)
                }
            }
        }
        
        let deadLinedeleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, handler) in
            let deadline = self.deadlines[indexPath.section].1[indexPath.row]
            deadline.firebaseDelete { (message) in
                if message == .success {
                    SPAlert.present(message: "Successfully deleted")
                } else {
                    SPAlert.present(message: "Failed to delete")
                }
            }
        }
        
        
        let resourceDeleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, handler) in
            let resource = self.resources[indexPath.section].1[indexPath.row]
            resource.firebaseRemove { (message) in
                if message == .success {
                    SPAlert.present(message: "Successfully deleted")
                } else {
                    SPAlert.present(message: "Failed to delete")
                }
            }
        }
        
        
        let questionFollowAction = UIContextualAction(style: .normal, title: "Follow") { (action, sourceView, handler) in
            let question = self.questions[indexPath.section].2[indexPath.row]
            question.follow()
            self.tableView.reloadData()
        }
        questionFollowAction.backgroundColor = UIColor(named: "Main color")
        
        
        let questionUnFollowAction = UIContextualAction(style: .normal, title: "UnFollow") { (action, sourceView, handler) in
            let question = self.questions[indexPath.section].2[indexPath.row]
            question.unFollow()
            self.tableView.reloadData()
        }
        questionUnFollowAction.backgroundColor = UIColor(named: "Main color")
        
        var notifications = UserDefaults.standard.dictionary(forKey: "notifications")
        notifications = notifications != nil ? notifications as! [String: String] : [:]
        
        if currentState == .questions {
            let authorId = questions[indexPath.section].2[indexPath.row].author.uid
            if authorId == Auth.auth().currentUser?.uid || authorId == UserDefaults.standard.value(forKey: "anonymousId") as! String {
                if notifications?.contains(where: {$0.key == questions[indexPath.section].2[indexPath.row].id}) ?? false {
                    return UISwipeActionsConfiguration(actions: [deleteAction, editAction, questionUnFollowAction])
                } else {
                    return UISwipeActionsConfiguration(actions: [deleteAction, editAction, questionFollowAction])
                }
            } else {
                if notifications?.contains(where: {$0.key == questions[indexPath.section].2[indexPath.row].id}) ?? false {
                    return UISwipeActionsConfiguration(actions: [questionUnFollowAction])
                } else {
                    return UISwipeActionsConfiguration(actions: [questionFollowAction])
                }
            }
        } else if currentState == .deadlines {
            let authorId = self.deadlines[indexPath.section].1[indexPath.row].author.uid
            if authorId == Auth.auth().currentUser?.uid || authorId == UserDefaults.standard.value(forKey: "anonymousId") as! String {
                return UISwipeActionsConfiguration(actions: [deadLinedeleteAction])
            } else {
                return nil
            }
        } else {
            let authorId = self.resources[indexPath.section].1[indexPath.row].author.uid
            if authorId == Auth.auth().currentUser?.uid || authorId == UserDefaults.standard.value(forKey: "anonymousId") as! String {
                return UISwipeActionsConfiguration(actions: [resourceDeleteAction])
            } else {
                return nil
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentState == .deadlines {
            let deadline = deadlines[indexPath.section].1[indexPath.row]
            if Constants.realm.object(ofType: Task.self, forPrimaryKey: deadline.id) != nil {
                let alert = UIViewController.getAlertWithCancelButton("Remove from my timetable?")
                alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
                    let task = Constants.realm.object(ofType: Task.self, forPrimaryKey: deadline.id)
                    task?.delete()
                    self.tableView.reloadData()
                }))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                popupDetailsView(at: deadline)
            }
            
            
        } else if currentState == .resources {
            
            let resource = resources[indexPath.section].1[indexPath.row]
            var message = ""
            if let details = resource.details {
                message = "Details: " + details + "\n" + "Professor: " + (resource.professor ?? "")
            }
            
            alert = UIAlertController(title: resource.assessment, message: message, preferredStyle: .alert)
            
            let openAction = UIAlertAction(title: "Open", style: .default) { (action) in
                if resource.contentType != "img" {
                    let name = resource.courseId+"-"+resource.semester+"-\(resource.year)-"+resource.assessment
                    self.storeAndShare(name: name, url: URL(string: resource.urls[0])!, controller: self.documentInteractionController, contentType: resource.contentType)
                } else {
                    self.performSegue(withIdentifier: "showImages", sender: resource)
                }
                
            }
            
            alert.addAction(openAction)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
                self.alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "showQuestion", sender: questions[indexPath.section].2[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func openSection(sender: UITapGestureRecognizer){
        // Get the view
        let index = (sender.view as! TopicHeader).section
        
        questions[index].1 = !questions[index].1
        
        tableView.reloadSections([index], with: .automatic)
        
    }
    
    //MARK: Show details popup
    func popupDetailsView(at deadline: Deadline){
        let controller = self.storyboard!.instantiateViewController(identifier: "CourseDetailViewController") as! CourseDetailViewController
        let transitionDelegate = SPStorkTransitioningDelegate()
        transitionDelegate.customHeight = 560
        controller.transitioningDelegate = transitionDelegate
        controller.deadline = deadline
        controller.delegate = self
        controller.currentState = .deadline
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        self.present(controller, animated: true, completion: nil)
    }
    
}


extension CourseSectionsViewController: SetupCoursesViewControllerProtocol {
    func add(at event: ClubEvent) {
        
    }
    
    func add(at course: Course) {
        
    }
    
    func remove(at course: Course) {
        
    }
    
    func add(at task: Task){
        task.add()
        tableView.reloadData()
    }
}



//MARK:- Fetch data
extension CourseSectionsViewController {
    
    
    //MARK: Fetch questions
    func fetchQuestions() {
        Question.getAllQuestions(of: course.id) { (allQuestions) in
            Question.getSectionQuestions(of: self.course.id, of: self.course.section) { (questions) in
                var tempQuestions = allQuestions
                tempQuestions.append(contentsOf: questions)
                self.filterQuestions(tempQuestions: tempQuestions)
            }
        }
        tableView.reloadData()
    }
    
    //TODO: FILTER QUESTIONS
    func filterQuestions(tempQuestions: [Question]){
        questions = []
        let filtered = tempQuestions.sorted { (question1, question2) -> Bool in
            return question2.timestamp < question1.timestamp
        }
        for question in filtered {
            if let index = questions.firstIndex(where: {$0.0 == question.topic}) {
                questions[index].2.append(question)
            } else {
                questions.append((question.topic, false, [question]))
            }
        }
        tableView.reloadData()
    }
    
    
    //MARK: Fetch deadlines
    func fetchDeadlines() {
        Deadline.getDeadlines(of: course.id) { (deadlines) in
            self.filterDeadlines(tempDeadlines: deadlines)
        }
        tableView.reloadData()
    }
    
    //TODO: FILTER QUESTIONS
    func filterDeadlines(tempDeadlines : [Deadline]){
        
        deadlines = []
        
        let filteredDeadlines = tempDeadlines.filter({
            $0.timestamp >= Int(Date().timeIntervalSince1970)
                && ($0.section == course.section || $0.section == "0")
        }).sorted { (deadline1, deadline2) -> Bool in
            return deadline1.timestamp < deadline2.timestamp
        }
        
        for deadline in filteredDeadlines {
            if let index = deadlines.firstIndex(where: {$0.0 == deadline.day}) {
                deadlines[index].1.append(deadline)
            } else {
                deadlines.append((deadline.day, [deadline]))
            }
        }
        tableView.reloadData()
    }
    
    
    //MARK: Fetch deadlines
    func fetchResources() {
        Resource.getResources(of: course.id) { (resources) in
            self.filterResources(at: resources)
        }
        tableView.reloadData()
    }
    
    //TODO: FILTER QUESTIONS
    func filterResources(at resourcesArray: [Resource]){
        
        var tempResources = [(String, [Resource])]()
        let filtered = resourcesArray.sorted { (resource1, resource2) -> Bool in
            return resource1.year > resource2.year
        }
        for resource in filtered {
            if let index = tempResources.firstIndex(where: {$0.0 == "\(resource.year)"}) {
                tempResources[index].1.append(resource)
            } else {
                tempResources.append(("\(resource.year)", [resource]))
            }
        }
        self.resources = tempResources
        tableView.reloadData()
    }
}

