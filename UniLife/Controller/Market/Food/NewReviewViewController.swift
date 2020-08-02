//
//  NewReviewViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/18/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import YPImagePicker
import SPAlert

class NewReviewViewController: UIViewController, UITextViewDelegate {

    
    
    
    
    @IBOutlet weak var addImagesButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var rateView: UIView!
    var newReview = Review()
    var images = [UIImage]()
    var cafeId: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        textView.layer.cornerRadius = 8
        addImagesButton.layer.cornerRadius = 8
        
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
         let numberOfChars = newText.count
         return numberOfChars <= 800
     }
    
    
    
    @IBAction func donePressed(_ sender: Any) {
        if let text = textView.text {
            if text != "Dear " {
                newReview.body = text
            }
        }
        if newReview.rating == 0 {
            SPAlert.present(message: "Please rate the cafe first")
        } else {
            let alert = UIViewController.getAlert("Uploading review...")
            self.present(alert, animated: true, completion: nil)
            newReview.firebaseAdd(cafeId: cafeId, images: images) { (message) in
                alert.dismiss(animated: true, completion: nil)
                if message == .success {
                    SPAlert.present(title: "Successfully rated", preset: .done)
                } else {
                    SPAlert.present(title: "Failed to rate", preset: .error)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addImagesPressed(_ sender: Any) {
        let imagePicker = ImagePicker.getYPImagePicker(1)
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
            if self.images.count > 0 {
                self.addImagesButton.setTitle("\(self.images.count) images", for: .normal)
            } else {
                self.addImagesButton.setTitle("Add images", for: .normal)
            }
            imagePicker.dismiss(animated: true, completion: nil)
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func ratePressed(_ sender: UIButton) {
        newReview.rating = sender.tag
        
        for i in 1...5 {
            if i <= sender.tag {
                (rateView.viewWithTag(i) as! UIButton).setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                (rateView.viewWithTag(i) as! UIButton).setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
        
    }
    
}
