//
//  LoginViewController.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 9/27/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var defaultImageView: UIImageView!
    /*******************************************
     * UIVIEW CONTROLLER LIFECYCLES FUNCTIONS *
     *******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("User is: \(String(describing: PFUser.current()))")
        
        //make it first responder to start typing
        usernameField.becomeFirstResponder()
        
    }
    
    /************************
     * MY CREATED FUNCTIONS *
     ************************/
    

    /***********************
     * IBACTIONS FUNCTIONS *
     ***********************/
    @IBAction func onSignIn(_ sender: Any) {
        
        PFUser.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!){
            (user: PFUser?, error: Error?) -> Void in
            
            if user != nil {
                print("Logged in!")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error logging in")
                print(error?.localizedDescription as Any)
                self.messageField.text = error?.localizedDescription
            }
            
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        
        let newUser = PFUser()
        
        newUser.username = usernameField.text!
        newUser.password = passwordField.text
        
        newUser.signUpInBackground(block: {(success: Bool, error: Error?) -> Void in
            
            if success {
                print("User was created! Hurray!")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else if error?._code == 202 {
                print("Username already taken, try different name")
            } else {
                print("Error:")
                print(error?.localizedDescription as Any)
            }
            
            })
    }
}
