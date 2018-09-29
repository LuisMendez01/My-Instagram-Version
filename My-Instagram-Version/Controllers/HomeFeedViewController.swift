//
//  HomeFeedViewController.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 9/28/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit
import Parse

class HomeFeedViewController: UIViewController {

    /*******************************************
     * UIVIEW CONTROLLER LIFECYCLES FUNCTIONS *
     *******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*********Title In Nav Bar*******/
        setTitleInNavBar()
        
        /*******Logout btn to LoginVC & Compose btn to ComposeVC in Nav Bar*****/
        setNavBarSidesBtns()
        
        print("User is homeFeed: \(String(describing: PFUser.current()))")
        
    }
    
    /************************
     * MY CREATED FUNCTIONS *
     ************************/
    func setTitleInNavBar(){
        
        let titleLabel = UILabel()//for the title of the page
        
        //set some attributes for the title of this controller
        let strokeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor : UIColor.white,
            .foregroundColor : UIColor(cgColor: #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)),  /*UIColor(red: 0.5, green: 0.25, blue: 0.15, alpha: 0.8)*/
            .strokeWidth : -1,
            .font : UIFont.boldSystemFont(ofSize: 23)
        ]
        
        //NSMutableAttributedString(string: "0", attributes: strokeTextAttributes)
        //set the name and put in the attributes for it
        let titleText = NSAttributedString(string: "Home Feed", attributes: strokeTextAttributes)
        
        //adding the titleText
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
    
    func setNavBarSidesBtns(){
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(LogOut))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "insta_camera_btn.png"), style: .plain, target: self, action: #selector(goToCompose))
        
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(LogOut))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(LogOut))
        /*
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [add, play]
         */
    }
    
    @objc func LogOut(){
        
        // Logout the current user
        PFUser.logOutInBackground(block: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                
                print("Successful loggout")
            }})
        
        //Grab a reference to the presenting VC
        let thePresenter = self.presentingViewController
        //if NavBar presented it
        //let thePresenter = self.navigationController.viewControllers.objectAtIndex:self.navigationController.viewControllers.count - 2
        
        if thePresenter is LoginViewController {
            print("Dismiss performed segue from LoginVC logout right here and then dismiss")
            
            //dismiss if coming from segue from LoginVC,
            //if coming from rootVC in delegate for persisted user then this won't do anything
            dismiss(animated: true, completion: nil)
        } else {
            print("Loggin out from NotificationCenter in Delegate to return to main controller")
            
            // Notify user was logged out and changed main VC to LoginVC 
            NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
        }
        
    }
    
    @objc func goToCompose(){
        performSegue(withIdentifier: "composeSegue", sender: nil)
    }
}
