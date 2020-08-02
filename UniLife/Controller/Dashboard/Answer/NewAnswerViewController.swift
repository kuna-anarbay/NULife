//
//  NewAnswerViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/14/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import YPImagePicker
import SPAlert


class NewAnswerViewController: UIViewController, UITextViewDelegate {

    
    
    
    @IBOutlet weak var anonButton: UIBarButtonItem!
    @IBOutlet weak var pickImageButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var textView: UITextView!
    var question: Question!
    var newAnswer = Answer()
    var imagePicker = YPImagePicker()
    var images = [UIImage]()
    var editMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newAnswer.courseId = question.courseId
        newAnswer.sectionId = question.section
        newAnswer.questionId = question.id
        textView.delegate = self
        
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
        
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let text = textView.text {
            newAnswer.body = text
        }
    }
    
    
    func setup(){
        textView.text = newAnswer.body
        pickImageButton.title = images.count == 0 ? "Select images" : "\(images.count) images"
        anonButton.title = newAnswer.author.name
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 800
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            toolBar.bottomConstraint?.constant = keyboardHeight
            
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            toolBar.bottomConstraint?.constant = 0
        }
    }
    
    
    
    @IBAction func donePressed(_ sender: Any) {
        if let text = textView.text {
            newAnswer.body = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if newAnswer.isValid.0 {
            if editMode {
                self.dismiss(animated: true) {
                    self.newAnswer.firebaseEdit { (message) in
                        if message == .error {
                            SPAlert.present(title: "Failed to update", preset: .error)
                        } else {
                            SPAlert.present(title: "Successfully updated", preset: .done)
                        }
                    }
                }
            } else {
                if Helper.connectedToNetwork() {
                    let alert = UIViewController.getAlert("Uploading answer...")
                    self.present(alert, animated: true, completion: nil)
                    self.newAnswer.firebaseAdd(images: self.images) { message in
                        alert.dismiss(animated: true){
                            if message == .error {
                                SPAlert.present(title: "Failed to update", preset: .error)
                            } else {
                                SPAlert.present(title: "Successfully updated", preset: .done)
                            }
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "No internet connection", message: "Send question without images?", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Send without images", style: .default, handler: { (action) in
                        self.present(alert, animated: true, completion: nil)
                        self.newAnswer.firebaseAdd(images: []) { message in
                            alert.dismiss(animated: true) {
                                if message == .error {
                                    SPAlert.present(title: "Failed to update", preset: .error)
                                } else {
                                    SPAlert.present(title: "Successfully updated", preset: .done)
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        alert.dismiss(animated: true) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            SPAlert.present(message: newAnswer.isValid.1)
        }
    }
    
    
    
    @IBAction func pickImagePressed(_ sender: Any) {
        if !editMode {
            imagePicker = ImagePicker.getYPImagePicker()
            images = []
            imagePicker.didFinishPicking { [unowned imagePicker] items, cancelled in
                UINavigationBar.appearance().tintColor = UIColor(named: "Main color")
                if !cancelled {
                    for item in items {
                        switch item {
                            case .photo(let photo):
                                self.images.append(photo.image)
                        case .video( _):
                                break
                        }
                    }
                } else {
                    self.images = []
                }
                
                imagePicker.dismiss(animated: true) {
                    self.setup()
                }
            }
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func anonymousPressed(_ sender: Any) {
        if let text = textView.text {
            newAnswer.body = text
        }
        newAnswer.setAnonymous()
        setup()
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
