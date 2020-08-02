//
//  LoginViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 2/26/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert

class LoginViewController: UIViewController {

    
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var passwordBlur: UIVisualEffectView!
    @IBOutlet weak var emailBlur: UIVisualEffectView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    let loadingAlert = UIViewController.getAlert()
    var isForgotState = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupFields()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailBlur.subviews.forEach({ (view) in
            view.layer.cornerRadius = 8
        })
        passwordBlur.subviews.forEach({ (view) in
            view.layer.cornerRadius = 8
        })
        loginButton.layer.cornerRadius = 8
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        self.view.endEditing(true)
        if isForgotState {
            self.reset()
        } else {
           self.login()
        }
    }
    
    
    func reset(){
        if let email = emailField.text, email.suffix(10) == "@nu.edu.kz" {
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let error = error {
                    SPAlert.present(title: "Reset error", message: error.localizedDescription, preset: .error)
                } else {
                    SPAlert.present(title: "Reset success", message: "Please check your email, code expires in 1 hour", preset: .done)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            SPAlert.present(title: "Login error", message: "Please, fill proper email", preset: .error)
        }
    }
    
    func login(){
        if let email = emailField.text, let password = passwordField.text {
            if email == "admin@nulife.kz" {
                self.present(self.loadingAlert, animated: true, completion: nil)
                Auth.auth().signIn(withEmail: "kuanysh.anarbay@nu.edu.kz", password: password) { (result, error) in
                    if let error = error {
                        self.loadingAlert.dismiss(animated: true, completion: nil)
                        SPAlert.present(title: "Login error", message: error.localizedDescription, preset: .error)
                    } else {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        if email == "kuanysh.anarbay@nu.edu.kz" {
                            changeRequest?.displayName = "Kuanysh Anarbay"
                            changeRequest?.commitChanges(completion: nil)
                        }
                        self.loadingAlert.dismiss(animated: true) {
                            self.performSegue(withIdentifier: "showMain", sender: nil)
                        }
                    }
                }
            } else {
                SPAlert.present(title: "Access for admin only", preset: .error)
            }
        } else {
            SPAlert.present(title: "Login error", message: "Please, fill password and email", preset: .error)
        }
    }
    
    @IBAction func forgotPressed(_ sender: Any) {
        isForgotState = !isForgotState
        self.changeState()
    }
    
    func changeState(){
        if isForgotState {
            passwordField.isEnabled = false
            passwordBlur.isHidden = true
            loginText.text = "Please enter your email"
            loginButton.setTitle("Reset password", for: .normal)
        } else {
            passwordField.isEnabled = true
            passwordBlur.isHidden = false
            loginText.text = "Login to get started"
            loginButton.setTitle("Login", for: .normal)
        }
    }
    
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension LoginViewController: UITextFieldDelegate {
    
    func setupFields(){
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            if isForgotState {
                self.reset()
            } else {
                passwordField.becomeFirstResponder()
            }
        } else {
            self.login()
        }
        return true
    }
}
