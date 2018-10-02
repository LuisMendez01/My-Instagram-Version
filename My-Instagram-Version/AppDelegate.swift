//
//  AppDelegate.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 9/27/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Initialize Parse
        // Set applicationId and server based on the values in the Heroku settings.
        // clientKey is not used on Parse open source unless explicitly configured
        Parse.initialize(
            with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "instagram-like-app-id"
                configuration.clientKey = "maitre-cle"  // set to nil assuming you have not set clientKey
                configuration.server = "https://instagram-like-app.herokuapp.com/parse"
            })
        )
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didLogout"), object: nil, queue: OperationQueue.main) { (Notification) in
            print("Logout notification received")
            // TODO: Logout the User
            // TODO: Load and show the login view controller
            self.mainVCisLoginVCNow()
        }
        
        print("User appDelegate: \(String(describing: PFUser.current()))")
        // check if user is logged in.
        if PFUser.current() != nil {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // view controller currently being set in Storyboard as default will be overridden
            let HomeFeedVC = storyboard.instantiateViewController(withIdentifier: "homeFeedVC") as! HomeFeedViewController//ProfileViewController -> "ProfileIDVC"
            //Only using this shows a white screen but below code makes it work, guess it's
            //the fact that this HomeFeedVC has a NavBar Controller
                //self.window?.rootViewController = HomeFeedVC
            
            //do this if you want a NavBarController on top of VC
            let navigationController = UINavigationController(rootViewController: HomeFeedVC)
            window!.rootViewController = navigationController
 
        }
        
        return true
    }
    
    func mainVCisLoginVCNow() {

        // Load and show the login view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "MainVC") as! LoginViewController
                
        UIView.transition(with: self.window!, duration: 0.4, options: .transitionCrossDissolve , animations: {
            self.window?.rootViewController = loginVC
            }, completion: { completed in
                    // maybe do something here
            })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

