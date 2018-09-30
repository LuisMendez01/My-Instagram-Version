//
//  HomeFeedViewController.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 9/28/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit
import Parse

class HomeFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
     var posts: [PFObject] = []
     private var myTableView: UITableView!

    /*******************************************
     * UIVIEW CONTROLLER LIFECYCLES FUNCTIONS *
     *******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*********Title In Nav Bar*******/
        setTitleInNavBar()
        
        /*******Logout btn to LoginVC & Compose btn to ComposeVC in Nav Bar*****/
        setNavBarSidesBtns()
        
        /*********Set TableView*******/
        setTableView()
        
        /********* Fetch data from Parse-server ********/
        fetchData()
        
        print("User is homeFeed: \(String(describing: PFUser.current()))")
        
    }
    
    /************************
     * MY CREATED FUNCTIONS *
     ************************/
    
    func setTableView(){
        
        //let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width//self is this VC width
        let displayHeight: CGFloat = self.view.frame.height//self is this VC height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
    }
    
    func fetchData(){
        
        // construct query
        //let query : PFQuery = PFQuery(className: "_User")
        let query = Post.query()
        query?.whereKey("likesCount", lessThan: 100)
        query?.limit = 20

        // fetch data asynchronously
        query?.findObjectsInBackground(block: { (incomingPosts, error) in
            if let incomingPosts = incomingPosts {

//                for post in incomingPosts {
//                    // access the object as a dictionary and cast type
////                    let likeCount = post.dictionaryWithValues(forKeys: ["caption"])
////                    print(likeCount["caption"]!)
//
//                    let caption = post["caption"]
//                    print(caption ?? "")
//                }

                // do something with the array of object returned by the call
                self.posts = incomingPosts
                print(incomingPosts)

                // Reload the tableView now that there is new data
                self.myTableView.reloadData()
            } else {
                print(error?.localizedDescription as Any)
            }
            })
        
//        // construct query
//        let predicate = NSPredicate(format: "likesCount > 100")
//        var query = Post.query(with: predicate)
//
//        // fetch data asynchronously
//        query!.findObjectsInBackground(block: { (incomingPosts, error) in
//            if let posts = incomingPosts {
//                // do something with the array of object returned by the call
//                for post in posts {
//                    // access the object as a dictionary and cast type
//                    let likeCount = post.likesCount
//                }
//            } else {
//                print(error?.localizedDescription as Any)
//            }
//        })

    }
    
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
    
    /***********************
     * TABLEVIEW FUNCTIONS *
     ***********************/
    func numberOfSections(in tableView: UITableView) -> Int {
        print("posts.count: \(posts.count)")
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
        cell.textLabel!.text = "Que!"//"\(posts[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        //headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        headerView.backgroundColor = #colorLiteral(red: 0.6156862745, green: 0.6745098039, blue: 0.7490196078, alpha: 1)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        profileView.image = UIImage(named: "vegeta.png")
        //profileView.af_setImage(withURL: URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        /*
         let post = posts[section]
         let stringDate = post["date"] as? String
         
         let dateFormatter = DateFormatter()//dateFormat has to look same as string data coming in
         dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"//data extracted looks like this -> 2018-09-03 22:49:17 GMT
         dateFormatter.locale = Locale(identifier: "en_US_POSIX")
         dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
         dateFormatter.isLenient = true
         //print(type(of: stringDate))
         
         let date = dateFormatter.date(from: stringDate!)
         //print(date!)
         
         //this will make date coming like this 2018-09-03 22:49:17 GMT turn like this //MMM d, yyyy, HH:mm a
         dateFormatter.dateStyle = .medium
         dateFormatter.timeStyle = .short
         
         // Add a UILabel for the date here
         // Use the section number to get the right URL
         // let label = ...
         */
        let labelDate = UILabel(frame: CGRect(x: 55, y: 10, width: 250, height: 30))
        labelDate.textAlignment = .left
//        let author = posts[section]["author"] as? [String:Any]
//        print("author \(author)")
        do {
            if let json = try JSONSerialization.jsonObject(with: posts[section]["author"]!?, options:.allowFragments) as? [String:Any] {
                print(json)
            }
        } catch let err{
            print(err.localizedDescription)
        }
//        if let a = author!["objectId"] {
//        labelDate.text = a as? String//dateFormatter.string(from: date ?? Date())
//        }
        
        headerView.addSubview(labelDate)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.section)")
        print("Value: \(posts[indexPath.section])")
    }
}

/*
 let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
 let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: nil)
 
 navigationItem.rightBarButtonItems = [add, play]
 */
