//
//  InitialViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/3/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SPAlert

class InitialViewController: UIViewController {

    //MARK: Variables and Constants
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var googleButton: UIButton!
    
    let loadingAlert = UIViewController.getAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        loginButton.layer.cornerRadius = 8
        googleButton.layer.cornerRadius = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupGoogleButton()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func setupGoogleButton(){
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }

}


//MARK:- SIGN IN WITH GOOGLE
extension InitialViewController: GIDSignInDelegate {
    
    //MARK: Sign In to the Database
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser?, withError error: Error!) {
        if error != nil {
            SPAlert.present(title: "Please login with University mail only", preset: .error)
        } else {
            if let user = user, let authentication = user.authentication {
                if user.profile.email.suffix(10) != "@nu.edu.kz" {
                    SPAlert.present(title: "Please login with University mail only", preset: .error)
                } else {
                    self.present(loadingAlert, animated: true, completion: nil)
                    
                    let credential = GoogleAuthProvider.credential(withIDToken: (authentication.idToken)!, accessToken: (authentication.accessToken)!)

                    Auth.auth().signIn(with: credential, completion: { (user, err) in
                        if err != nil {
                            self.loadingAlert.dismiss(animated: true) {
                                SPAlert.present(title: "Failed to log in", preset: .error)
                            }
                        } else {
                            self.loadingAlert.dismiss(animated: true) {
                                self.performSegue(withIdentifier: "showMain", sender: nil)
                            }
                        }
                    })
                }
            } else {
                SPAlert.present(title: "User not found", preset: .error)
            }
        }
    }
    
    // MARK: Show sign in with google viewcontroller
    func sign(_ signIn: GIDSignIn?, present viewController: UIViewController?) {
      if let aController = viewController {
        present(aController, animated: true) {() -> Void in }
      }
    }
    
    
    //MARK: Did sign in with google
    func sign(_ signIn: GIDSignIn?, dismiss viewController: UIViewController?) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Disconnect User
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
