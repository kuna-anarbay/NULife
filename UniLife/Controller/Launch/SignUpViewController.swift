//
//  SignUpViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 2/26/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert

class SignUpViewController: UIViewController {

    @IBOutlet weak var signUpText: UILabel!
    @IBOutlet weak var repeatBlur: UIVisualEffectView!
    @IBOutlet weak var passwordBlur: UIVisualEffectView!
    @IBOutlet weak var emailBlur: UIVisualEffectView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var repeatField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var backView: UIView!
    let loadingAlert = UIViewController.getAlert()
    var resetState = false
    var oobCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFields()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resendButton.isHidden = true
        emailBlur.subviews.forEach({ (view) in
            view.layer.cornerRadius = 8
        })
        repeatBlur.subviews.forEach({ (view) in
            view.layer.cornerRadius = 8
        })
        passwordBlur.subviews.forEach({ (view) in
            view.layer.cornerRadius = 8
        })
        signUpButton.layer.cornerRadius = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupStyle()
    }
    

    @IBAction func signUpPressed(_ sender: Any) {
        self.view.endEditing(true)
        if resetState {
            self.reset()
        } else {
            self.signUp()
        }
    }
    
    
    func setupStyle(){
        if resetState {
            Auth.auth().verifyPasswordResetCode(self.oobCode) { (email, error) in
                if let error = error {
                    SPAlert.present(title: error.localizedDescription, preset: .error)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.emailField.text = email
                    self.emailField.isEnabled = false
                    self.signUpText.text = "Reset your password"
                    self.signUpButton.setTitle("Reset password", for: .normal)
                }
            }
        } else {
            self.signUpText.text = "Become a member"
            self.signUpButton.setTitle("Sign Up", for: .normal)
        }
    }
    
    
    func reset(){
        if let password = passwordField.text, let duplicate = repeatField.text {
            if password == duplicate {
                Auth.auth().confirmPasswordReset(withCode: oobCode, newPassword: password) { (error) in
                    if let error = error {
                        SPAlert.present(title: error.localizedDescription, preset: .error)
                    } else {
                        SPAlert.present(title: "Successfully updated password", message: "Please login with new password", preset: .done)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                SPAlert.present(title: "Passwords not equal", preset: .done)
            }
        } else {
            SPAlert.present(title: "Please fill all the fields", preset: .done)
        }
    }
    
    
    func signUp(){
        if let email = emailField.text, let password = passwordField.text, let duplicate = repeatField.text {
            if password == duplicate {
                if email.suffix(10) == "@nu.edu.kz" {
                    self.present(self.loadingAlert, animated: true, completion: nil)
                    Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                        self.loadingAlert.dismiss(animated: true, completion: nil)
                        if let error = error {
                            SPAlert.present(title: "Login error", message: error.localizedDescription, preset: .error)
                        } else {
                            User.uploadImage { (_) in
                                self.resendButton.isHidden = false
                                self.loadingAlert.dismiss(animated: true){
                                    self.sendEmail()
                                }
                            }
                        }
                    }
                } else {
                    SPAlert.present(title: "Please login with University mail only", preset: .error)
                }
            } else {
               SPAlert.present(title: "Passwords not equal", preset: .done)
            }
        } else {
            SPAlert.present(title: "Login error", message: "Please, fill password and email", preset: .error)
        }
    }
    
    
    func sendEmail(){
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { (error) in
                if let error = error {
                    SPAlert.present(message: error.localizedDescription, haptic: .error)
                } else {
                    SPAlert.present(message: "Please, check your email", haptic: .error)
                }
            }
        }
    }
    
    
    @IBAction func resendPressed(_ sender: Any) {
        self.sendEmail()
    }
    
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension SignUpViewController: UITextFieldDelegate {
    
    func setupFields(){
        repeatField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            repeatField.becomeFirstResponder()
        } else {
            if resetState {
                self.reset()
            } else {
                self.signUp()
            }
        }
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == repeatField {
            self.backView.centerYConstraint?.constant -= 50
            UIViewPropertyAnimator(duration: TimeInterval(0.25), curve: UIView.AnimationCurve(rawValue: UIView.AnimationCurve.RawValue(7.0))!) {
                self.view.layoutIfNeeded()
            }.startAnimation()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == repeatField {
            self.backView.centerYConstraint?.constant += 50
            UIViewPropertyAnimator(duration: TimeInterval(0.25), curve: UIView.AnimationCurve(rawValue: UIView.AnimationCurve.RawValue(7.0))!) {
                self.view.layoutIfNeeded()
            }.startAnimation()
        }
    }
}
