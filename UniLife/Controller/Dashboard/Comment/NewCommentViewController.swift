//
//  NewCommentViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/14/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert

class NewCommentViewController: UIViewController {

    
    
    @IBOutlet weak var anonButton: UIBarButtonItem!
    @IBOutlet weak var modeButton: UIBarButtonItem!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var newMessageView: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    var answer = Answer()
    var newComment = Comment()
    let randomInt = Int.random(in: 0..<12)
    var editState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        setupNewComment()
        setupTableView()
        fetchAnswer()
        hideKeyboardWhenTapped()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        title = answer.courseId
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func anonPressed(_ sender: Any) {
        if let text = textView.text {
            newComment.body = text
        }
        newComment.setAnonymous()
        anonButton.title = newComment.author.name
    }
    
    
    
    @IBAction func modePressed(_ sender: Any) {
        if editState {
            editState = false
            newComment = Comment()
            textView.endEditing(true)
            setupNewComment()
        }
    }
    
    
    @IBAction func donePressed(_ sender: Any) {
        if let text = textView.text {
            newComment.body = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if newComment.isValid.0 {
            if editState {
                newComment.firebaseEdit(answer: answer) { (message) in
                    if message == .error {
                        SPAlert.present(title: "Failed to update", preset: .error)
                    } else {
                        SPAlert.present(title: "Successfully updated", preset: .done)
                    }
                }
                editState = false
            } else {
                newComment.firebaseAdd(answer: answer) { (message) in
                    if message == .error {
                        SPAlert.present(title: "Failed to add", preset: .error)
                    } else {
                        SPAlert.present(title: "Successfully added", preset: .done)
                    }
                }
            }
            textView.endEditing(true)
            newComment = Comment()
            setupNewComment()
        } else {
            SPAlert.present(message: newComment.isValid.1)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImages" {
            let dest = segue.destination as! ImagesViewController
            dest.refs = answer.urls ?? []
        }
    }


}


extension NewCommentViewController: UITextViewDelegate {
    
    
    func setupNewComment(){
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 5, right: 5)
        textView.delegate = self
        
        textView.text = newComment.body.count==0 ? "Type a comment" : newComment.body
        textView.textColor = newComment.body.count==0 ? .lightGray : UIColor(named: "Text color")
        textView.layer.borderWidth = 0.2
        textView.layer.cornerRadius = 17.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        
        modeButton.title = editState ? "Cancel editing" : "New comment"
        anonButton.title = newComment.author.name
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 512
    }
    
    
    //MARK: TEXT VIEW BEGIN EDITING
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(named: "Text color")
        }
    }
    
    
    //MARK: TEXT VIEW END EDITING
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type a comment"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if let constraint = toolBar.bottomConstraint, constraint.constant == 0.0 {
                toolBar.bottomConstraint?.constant = keyboardHeight
            }
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let constraint = toolBar.bottomConstraint, constraint.constant != 0.0 {
            toolBar.bottomConstraint?.constant = 0
        }
    }
}


extension NewCommentViewController: UITableViewDelegate, UITableViewDataSource {

    
    func fetchAnswer(){
        Answer.getOne(of: answer.courseId, sectionId: answer.sectionId, questionId: answer.questionId, id: answer.id) { (answer) in
            if answer.notNull {
                self.answer = answer
                self.answer.comments = self.answer.comments?.sorted(by: { (com1, com2) -> Bool in
                    return com1.timestamp < com2.timestamp
                })
                self.tableView.reloadData()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (answer.comments?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 {
            if answer.urls?.count ?? 0 > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "answerImageCell", for: indexPath) as! AnswerImageTableViewCell
                
                
                cell.delegate = self
                cell.answer = answer
                cell.authorLabel.textColor = UIColor(named: "Text color")
                cell.authorLabel.text = answer.author.name
                cell.commentLabel.text = "\(answer.comments?.count ?? 0) comments"
                cell.bodyLabel.text = answer.body
                cell.detailLabel.text = Helper.displayDate24HourFull(timestamp: answer.timestamp)
                
                let upvotes = answer.votes?.filter({$0.1 == true}).count
                let downvotes = answer.votes?.filter({$0.1 == false}).count
                
                if answer.votes?.contains(where: {$0.0 == Auth.auth().currentUser?.uid && $0.1 == true }) ?? false {
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
                cell.authorLabel.textColor = .black
                cell.authorLabel.text = answer.author.name
                cell.commentLabel.text = "\(answer.comments?.count ?? 0) comments"
                cell.bodyLabel.text = answer.body
                cell.detailLabel.text = Helper.displayDate24HourFull(timestamp: answer.timestamp)
                let upvotes = answer.votes?.filter({$0.1 == true}).count
                let downvotes = answer.votes?.filter({$0.1 == false}).count
                
                if answer.votes?.contains(where: {$0.0 == Auth.auth().currentUser?.uid && $0.1 == true }) ?? false {
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
                
                cell.upvoteButton.layer.cornerRadius = 10.5
                cell.downVoteButton.layer.cornerRadius = 10.5
                
                cell.state = answer.votes?.first(where: {$0.0==Auth.auth().currentUser?.uid})?.1
                
                
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
            
            cell.authorLabel.textColor = UIColor(hexString: staticList.colors[(indexPath.row+randomInt)%12])
            cell.authorLabel.text = answer.comments?[indexPath.row-1].author.name
            cell.bodyLabel.text = answer.comments?[indexPath.row-1].body
            cell.timeLabel.text = Helper.displayDate24HourFull(timestamp: answer.comments?[indexPath.row-1].timestamp ?? Int(Date().timeIntervalSince1970))
            
            return cell
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: SWIPE TABLE VIEW CELL
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, handler) in
            
            let comment = self.answer.comments?[indexPath.row-1]
            self.newComment = comment ?? Comment()
            self.editState = true
            self.setupNewComment()
            self.textView.becomeFirstResponder()
        }
        editAction.backgroundColor = .orange
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, handler) in
            
            let comment = self.answer.comments?[indexPath.row-1]
            comment?.firebaseDelete(answer: self.answer, completion: { (message) in
                if message == .error {
                    SPAlert.present(title: "Failed to delete", preset: .error)
                } else {
                    SPAlert.present(title: "Successfully deleted", preset: .done)
                }
            })
        }
        if indexPath.row > 0 {
            let authorId = self.answer.comments?[indexPath.row-1].author.uid
            if authorId == Auth.auth().currentUser?.uid || authorId == UserDefaults.standard.string(forKey: "anonymousId") {
                return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
            } else {
                return nil
            }
        } else {
            return nil
        }
        
    }
    
    
}


// MARK: HIDE KEYBOARD WHEN TAPPED ELSEWHERE
extension NewCommentViewController {
    
    func hideKeyboardWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    
    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension NewCommentViewController: showImagesProtocol {
    
    func showImages(_ question: Question) {
        
    }
    
    func showImages(_ answer: Answer) {
        performSegue(withIdentifier: "showImages", sender: answer)
    }
    
    
}
