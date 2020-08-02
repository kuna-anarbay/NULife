//
//  AnswerViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/14/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert

class AnswerViewController: UIViewController {

    
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var question = Question()
    var answers = [Answer]()
    let randomInt = Int.random(in: 0..<12)
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    var selectedAnswer : Answer?
    var anonBtn: UIButton!
    var deleteBtn: UIButton!
    var editBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupTableView()
        fetchData()
        hideKeyboard()
        topButton.layer.cornerRadius = topButton.bounds.width/2
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = question.courseId
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func scrollTop(_ sender: Any) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    
    @IBAction func newAnswer(_ sender: Any) {
        performSegue(withIdentifier: "newAnswer", sender: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newAnswer" {
            let dest = segue.destination as! UINavigationController
            let destView = dest.viewControllers[0] as! NewAnswerViewController
            destView.question = self.question
            if sender != nil {
                destView.editMode = true
                destView.newAnswer = sender as! Answer
            }
        } else if segue.identifier == "showComment" {
            let dest = segue.destination as! NewCommentViewController
            dest.answer = sender as! Answer
        } else if segue.identifier == "showImages" {
            let dest = segue.destination as! ImagesViewController
            if sender != nil && sender is Answer {
                let answer = sender as! Answer
                dest.refs = answer.urls ?? []
            } else {
                let question = sender as! Question
                dest.refs = question.urls ?? []
            }
            
        }
    }
    

}



extension AnswerViewController {
    
    
    func fetchData(){
        Question.getOne(of: question.courseId, section: question.section, id: question.id) { (question) in
            if question.notNull {
                self.question = question
                self.tableView.reloadData()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        Answer.getAllAnswers(of: question.courseId, sectionId: question.section, questionId: question.id) { (answers) in
            if self.question.notNull {
                self.answers = answers
                self.tableView.reloadData()
            }
        }
    }
}





extension AnswerViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count + 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            if question.urls?.count ?? 0 > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "questionImageCell", for: indexPath) as! AnswerImageTableViewCell
                
                if question.urls?.count ?? 0 > 1 {
                    cell.moreButton.setTitle("+\(question.urls!.count - 1) images", for: .normal)
                } else {
                    cell.moreButton.setTitle("See image", for: .normal)
                }
                cell.delegate = self
                cell.question = question
                cell.authorLabel.textColor = UIColor(named: "Text color")
                cell.authorLabel.text = question.author.name
                cell.commentLabel.text = question.title
                cell.bodyLabel.text = question.details
                cell.detailLabel.text = "\(question.answersCount) \u{2022} " + Helper.displayDate24HourFull(timestamp: question.timestamp)
                cell.upvoteButton.isHidden = true
                cell.downVoteButton.isHidden = true
                cell.mainImage.setImage(from: URL(string: question.urls![0]))
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! AnswerTableViewCell

                cell.authorLabel.textColor = UIColor(named: "Text color")
                cell.authorLabel.text = question.author.name
                cell.commentLabel.text = question.title
                cell.bodyLabel.text = question.details
                cell.detailLabel.text = "\(question.answersCount) \u{2022} " + Helper.displayDate24HourFull(timestamp: question.timestamp)
                cell.upvoteButton.isHidden = true
                cell.downVoteButton.isHidden = true

                return cell
            }
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        } else if indexPath.row < answers.count + 2 {
            let answer = answers[indexPath.row-2]
            
            if answer.urls?.count ?? 0 > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "answerImageCell", for: indexPath) as! AnswerImageTableViewCell
                
                cell.delegate = self
                cell.answer = answer
                cell.authorLabel.textColor = UIColor(hexString: staticList.colors[(indexPath.row+randomInt)%12])
                cell.authorLabel.text = answer.author.name
                cell.commentLabel.text = "\(answer.comments?.count ?? 0) comments"
                cell.bodyLabel.text = answer.body
                cell.detailLabel.text = Helper.displayDate24HourFull(timestamp: answer.timestamp)
                cell.bodyLabel.numberOfLines = 50
                let upvotes = answer.votes?.filter({$0.1 == true}).count
                let downvotes = answer.votes?.filter({$0.1 == false}).count
                
                if answer.votes?.contains(where: {$0 == (Auth.auth().currentUser?.uid, true)}) ?? false {
                    cell.upvoteButton.tintColor = UIColor(named: "Success color")
                    cell.upvoteButton.setTitleColor(UIColor(named: "Success color"), for: .normal)
                    cell.upvoteButton.backgroundColor = UIColor(named: "Success color")?.withAlphaComponent(0.2)
                } else {
                    cell.upvoteButton.tintColor = UIColor(named: "Muted icon color")
                    cell.upvoteButton.setTitleColor(UIColor(named: "Muted icon color"), for: .normal)
                    cell.upvoteButton.backgroundColor = UIColor(named: "Muted icon color")?.withAlphaComponent(0.2)
                }
                
                if answer.votes?.contains(where: {$0.0 == Auth.auth().currentUser?.uid && $0.1 == false }) ?? false {
                    cell.downVoteButton.tintColor = UIColor(named: "Danger color")
                    cell.downVoteButton.setTitleColor(UIColor(named: "Danger color"), for: .normal)
                    cell.downVoteButton.backgroundColor = UIColor(named: "Danger color")?.withAlphaComponent(0.2)
                } else {
                    cell.downVoteButton.tintColor = UIColor(named: "Muted icon color")
                    cell.downVoteButton.setTitleColor(UIColor(named: "Muted icon color"), for: .normal)
                    cell.downVoteButton.backgroundColor = UIColor(named: "Muted icon color")?.withAlphaComponent(0.2)
                }
                
                cell.upvoteButton.setTitle("\(upvotes ?? 0)", for: .normal)
                cell.downVoteButton.setTitle("\(downvotes ?? 0)", for: .normal)
                
                
                cell.mainImage.setImage(from: URL(string: answer.urls![0]))
                if answer.urls?.count ?? 0 > 1 {
                    cell.moreButton.setTitle("+\(answer.urls!.count - 1) images", for: .normal)
                } else {
                    cell.moreButton.setTitle("See image", for: .normal)
                }
                
                cell.state = answer.votes?.first(where: {$0.0==Auth.auth().currentUser?.uid})?.1
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "answerCell", for: indexPath) as! AnswerTableViewCell
                
                cell.answer = answer
                cell.authorLabel.textColor = UIColor(hexString: staticList.colors[(indexPath.row+randomInt)%12])
                cell.authorLabel.text = answer.author.name
                cell.commentLabel.text = "\(answer.comments?.count ?? 0) comments"
                cell.bodyLabel.text = answer.body
                cell.detailLabel.text = Helper.displayDate24HourFull(timestamp: answer.timestamp)
                cell.bodyLabel.numberOfLines = 50
                
                let upvotes = answer.votes?.filter({$0.1 == true}).count
                let downvotes = answer.votes?.filter({$0.1 == false}).count
                

                cell.upvoteButton.layer.cornerRadius = 10.5
                cell.downVoteButton.layer.cornerRadius = 10.5
                
                if answer.votes?.contains(where: {$0 == (Auth.auth().currentUser?.uid, true)}) ?? false {
                    cell.upvoteButton.tintColor = UIColor(named: "Success color")
                    cell.upvoteButton.setTitleColor(UIColor(named: "Success color"), for: .normal)
                    cell.upvoteButton.backgroundColor = UIColor(named: "Success color")?.withAlphaComponent(0.2)
                } else {
                    cell.upvoteButton.tintColor = UIColor(named: "Muted icon color")
                    cell.upvoteButton.setTitleColor(UIColor(named: "Muted icon color"), for: .normal)
                    cell.upvoteButton.backgroundColor = UIColor(named: "Muted icon color")?.withAlphaComponent(0.2)
                }
                
                if answer.votes?.contains(where: {$0 == (Auth.auth().currentUser?.uid, false)}) ?? false {
                    cell.downVoteButton.tintColor = UIColor(named: "Danger color")
                    cell.downVoteButton.setTitleColor(UIColor(named: "Danger color"), for: .normal)
                    cell.downVoteButton.backgroundColor = UIColor(named: "Danger color")?.withAlphaComponent(0.2)
                } else {
                    cell.downVoteButton.tintColor = UIColor(named: "Muted icon color")
                    cell.downVoteButton.setTitleColor(UIColor(named: "Muted icon color"), for: .normal)
                    cell.downVoteButton.backgroundColor = UIColor(named: "Muted icon color")?.withAlphaComponent(0.2)
                }
                
                cell.upvoteButton.setTitle("\(upvotes ?? 0)", for: .normal)
                cell.downVoteButton.setTitle("\(downvotes ?? 0)", for: .normal)
                
                cell.state = answer.votes?.first(where: {$0.0==Auth.auth().currentUser?.uid})?.1
                
                return cell
            }
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        } else if indexPath.row == 1 {
            return 38
        } else if indexPath.row < answers.count + 2 {
            return UITableView.automaticDimension
        } else {
            return 72
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 1 && indexPath.row < answers.count+2 {
            let answer = answers[indexPath.row - 2]
            performSegue(withIdentifier: "showComment", sender: answer)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: LONG PRESS A CELL
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if indexPath.row >= 2 && indexPath.row < answers.count + 2 {
                    selectedAnswer = self.answers[indexPath.row-2]
                    
                    let authorId = selectedAnswer!.author.uid
                    if authorId == Auth.auth().currentUser?.uid || authorId == UserDefaults.standard.value(forKey: "anonymousId") as! String {
                        
                        self.blurEffectView = UIVisualEffectView(effect: self.blurEffect)
                        self.blurEffectView.isUserInteractionEnabled = true
                        self.blurEffectView.frame = self.view.bounds
                        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        self.view.addSubview(self.blurEffectView)
                        self.view.bringSubviewToFront(self.blurEffectView)
                        
                        let cell = self.tableView.cellForRow(at: indexPath)
                        cell?.layer.cornerRadius = 12
                        
                        let width = cell?.bounds.width
                        let height: CGFloat = 300
                        let y = (self.view.bounds.height - 300)/2
                        
                        
                        editBtn = UIButton(frame: CGRect(x: 8, y: y+height+52.5, width: 200, height: 44))
                        editBtn.setTitle("Edit", for: .normal)
                        editBtn.backgroundColor = .white
                        editBtn.setTitleColor(.black, for: .normal)
                        editBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editPressed)))
                        
                        
                        deleteBtn = UIButton(frame: CGRect(x: 8, y: y+height+97, width: 200, height: 44))
                        deleteBtn.setTitle("Delete", for: .normal)
                        deleteBtn.setTitleColor(.red, for: .normal)
                        deleteBtn.backgroundColor = .white
                        deleteBtn.layer.cornerRadius = 20
                        deleteBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deletePressed)))
                        
                        
                        anonBtn = UIButton(frame: CGRect(x: 8, y: y+height+8, width: 200, height: 44))
                        
                        if selectedAnswer?.author.name != "Anonymous" {
                            anonBtn.setTitle("Set anonymous", for: .normal)
                        } else {
                            anonBtn.setTitle("Set as you", for: .normal)
                        }
                        
                        anonBtn.backgroundColor = .white
                        anonBtn.layer.cornerRadius = 20
                        anonBtn.setTitleColor(.black, for: .normal)
                        anonBtn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                        anonBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setAnon)))
                        
                        cell?.frame = CGRect(x: 8, y: y, width: width!-16, height: height)
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        self.view.addSubview(cell!)
                        self.view.bringSubviewToFront(cell!)
                        
                        
                        self.view.addSubview(self.editBtn)
                        self.view.addSubview(self.deleteBtn)
                        self.view.addSubview(self.anonBtn)
                        
                        let transition = CATransition()
                        transition.duration = 0.25
                        transition.timingFunction = CAMediaTimingFunction(name: .default)
                        transition.type = .fade
                        self.view.layer.add(transition, forKey: nil)

                    }
                }
            }
        }
    }
    
    
    @objc func setAnon(sender: UITapGestureRecognizer){
        selectedAnswer?.setAnonymous()
        selectedAnswer?.setFirebaseAnonymous(completion: { (message) in
            if message == .error {
                SPAlert.present(title: "Failed to change", preset: .error)
            } else {
                SPAlert.present(title: "Successfully changed", preset: .done)
            }
        })
        self.blurEffectView.removeFromSuperview()
        self.editBtn.removeFromSuperview()
        self.deleteBtn.removeFromSuperview()
        self.anonBtn.removeFromSuperview()
    }
    
    @objc func deletePressed(sender: UITapGestureRecognizer){
        selectedAnswer?.firebaseDelete(completion: { (message) in
            if message == .error {
                SPAlert.present(title: "Failed to delete", preset: .error)
            } else {
                SPAlert.present(title: "Successfully deleted", preset: .done)
            }
        })
        self.blurEffectView.removeFromSuperview()
        self.editBtn.removeFromSuperview()
        self.deleteBtn.removeFromSuperview()
        self.anonBtn.removeFromSuperview()
    }
    
    @objc func editPressed(sender: UITapGestureRecognizer){
        self.blurEffectView.removeFromSuperview()
        self.editBtn.removeFromSuperview()
        self.deleteBtn.removeFromSuperview()
        self.anonBtn.removeFromSuperview()
        tableView.reloadData()
        performSegue(withIdentifier: "newAnswer", sender: selectedAnswer)
    }
    
}



extension AnswerViewController: showImagesProtocol {
    
    func showImages(_ question: Question) {
        performSegue(withIdentifier: "showImages", sender: question)
    }
    
    func showImages(_ answer: Answer) {
        performSegue(withIdentifier: "showImages", sender: answer)
    }
    
    
}


// MARK: HIDE KEYBOARD WHEN TAPPED ELSEWHERE
extension AnswerViewController {
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        let uitap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        uitap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(uitap)
        self.navigationController?.navigationBar.addGestureRecognizer(tap)
    }
    
    @objc override func dismissKeyboard() {
        if self.view.contains(blurEffectView) {
            self.blurEffectView.removeFromSuperview()
            self.editBtn.removeFromSuperview()
            self.deleteBtn.removeFromSuperview()
            self.anonBtn.removeFromSuperview()
            tableView.reloadData()
        }
        view.endEditing(true)
    }
}
