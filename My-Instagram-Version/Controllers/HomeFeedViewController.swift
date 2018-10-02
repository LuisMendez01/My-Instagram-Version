//
//  HomeFeedViewController.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 9/28/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit
import Parse

var tableWidth: CGFloat = 0

class HomeFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var posts: [PFObject] = []
    var checked: [Bool]!//for checkmark on row clicked, hide/show footer on row click
    var myTableView: UITableView!
    
    //set image from Parse-Server
    let PFPhotoView = PFImageView()
    
    //Initialize a UIRefreshControl
    let refreshControl = UIRefreshControl()
    
    var isMoreDataLoading = false//to make sure data has already been loaded
    
    var loadingMoreView:InfiniteScrollActivityView?
    
    var limit: Int = 1

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
        
        /********* On refresh call fetch data ********/
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        
        // add refresh control to table view
        myTableView.insertSubview(refreshControl, at: 0)
        
        /*********Load more infinite scrolling refresh*******/
        loadingMoreView = InfiniteScrollActivityView()//instantiate the object
        loadingMoreView!.isHidden = true
        myTableView.addSubview(loadingMoreView!)

        
        print("User is homeFeed: \(String(describing: PFUser.current()))")
        
    }
    
    /************************
     * MY CREATED FUNCTIONS *
     ************************/
    
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
            // Your code with delay
            
            //this will just refresh but won't get new posts as it is just pulling from top table
            self.limit = self.limit-1
            self.fetchData()//get morerecent posts
        }
    }
    
    func setTableView(){

        //let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width//self is this VC width
        let displayHeight: CGFloat = self.view.frame.height//self is this VC height
        
        //to be used in PostTableViewCell
        tableWidth = displayWidth

        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight), style: .grouped)
        myTableView.register(PostTableViewCell.self, forCellReuseIdentifier: "cell")
        myTableView.dataSource = self
        myTableView.delegate = self
        
        myTableView.rowHeight = tableWidth//UITableView.automaticDimension
        myTableView.estimatedRowHeight = 300//if all rows vary in size
        //estimatedHeightForRowAtIndexPath//to estimate height on different rows if they variate a lot in size
        
        self.view.addSubview(myTableView)
    }
    
    func fetchData(){
        
        let post = Post()
        //Get the current user and assign it to "author" field. "author" field is now of Pointer type
        post.author = PFUser.current()!
        
        // construct query
        //let query : PFQuery = PFQuery(className: "_User")
        //var userQuery = new Parse.Query(Parse.User);
        let query = Post.query()
        query?.order(byDescending: "createdAt")
        //query?.addDescendingOrder("createdAt")
        //query?.whereKey("likesCount", lessThan: 100)
        query?.includeKey("author")
        query?.limit = self.limit

        self.limit = self.limit+1
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
                
                //populate this array to false as we need all footers to show to start at
                self.checked = [Bool](repeating: false, count: self.posts.count+1)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    //allow to fetch again once this is false from DidScroll function
                    self.isMoreDataLoading = false
                }
                
                // Reload the tableView now that there is new data
                self.myTableView.reloadData()
                self.refreshControl.endRefreshing()//stop refresh when data has been acquired
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
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
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! PostTableViewCell
        
        // No color when the user selects cell
        cell.selectionStyle = .none
/*
        if let img = self.posts[indexPath.row]["media"]{
            let img = (img as! PFFile).name

            print("esto es el file name: \(img)")
        }
*/
        PFPhotoView.file = (self.posts[indexPath.section]["media"] as! PFFile)
        print("imagen file: \(String(describing: self.PFPhotoView.file))")

        print("section #: \(indexPath.section)")
        PFPhotoView.load(inBackground: {(imagen, error) in
                cell.myImagePost.image = imagen
            //cell.stateLabel.text = cityState.last
        })
        
        //cell.textLabel!.text = "Que!"//"\(posts[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        //headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        headerView.backgroundColor = #colorLiteral(red: 0.6156862745, green: 0.6745098039, blue: 0.7490196078, alpha: 1)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        //profileView.Cl  = PFImageView
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
//        if let img = self.posts[section]["media"]{
//            let img = (img as! PFFile).name
//
//            print("esto es el file name: \(img)")
//        }
//
//        //set image from Parse-Server
//        let PFPhotoView = PFImageView()
//
//        PFPhotoView.file = (self.posts[section]["media"] as! PFFile)
//        print("imagen file: \(String(describing: self.imagen.file))")
//
//        print("section #: \(section)")
//        PFPhotoView.load(inBackground: {(imagen, error) in
//            profileView.image = imagen
//        })
    
        // Set the avatar
        profileView.image = UIImage(named: "vegeta.png")
        headerView.addSubview(profileView)
        
        let labelUsername = UILabel(frame: CGRect(x: 55, y: 10, width: 250, height: 30))
        labelUsername.textAlignment = .left
    
        //unwraps the whole object first
        if let author = posts[section]["author"] as? PFObject{
            //then unwraps the key and value
            if let username = author.value(forKey: "username") {
                print("Username: \(username)")
                labelUsername.text = username as? String 
            }
        }
        
        //Getting username from current user for profile VC
        if let author2 = PFUser.current() {
            let author2 = (author2 as PFObject)
            
            //labelUsername.text = author2.value(forKeyPath: "username") as? String
            print("author2 id: \(author2)")
        }
        
        //dateFormatter.string(from: date ?? Date())
        headerView.addSubview(labelUsername)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        //headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        footerView.backgroundColor = #colorLiteral(red: 0.8153101802, green: 0.8805506825, blue: 0.8921775818, alpha: 0.92)
        
        /**************show the captions*******************/
        let labelCaption = UILabel(frame: CGRect(x: 10, y: 10, width: 250, height: 30))
        labelCaption.textAlignment = .left
        
        //to worked on
        if let caption = posts[section]["caption"]{
            let caption = caption
            
            print("Caption : \(caption)")
            labelCaption.text = caption as? String
        }
        
        footerView.addSubview(labelCaption)
        
        /**************show the Comments count*******************/
        let labelCommentsCount = UILabel(frame: CGRect(x: 10, y: 40, width: 200, height: 30))
        labelCommentsCount.textAlignment = .left
        labelCommentsCount.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        //to worked on
        if let commentsCount = posts[section]["likesCount"]{
            let commentsCount = commentsCount
            
            print("commentsCount : \(commentsCount)")
            labelCommentsCount.text = "View all \(commentsCount) comments"
        }
        
        footerView.addSubview(labelCommentsCount)
        
        /**************show the likes count*******************/
        let labelLikesCount = UILabel(frame: CGRect(x: self.view.frame.width-60, y: 40, width: 50, height: 30))
        labelLikesCount.textAlignment = .left
        labelLikesCount.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        //to worked on
        if let likesCount = posts[section]["likesCount"]{
            let likesCount = likesCount
            
            print("LikesCount : \(likesCount)")
            labelLikesCount.text = "\(likesCount) likes"
        }
        
        footerView.addSubview(labelLikesCount)
        
        /**************show the label createdAt*******************/
        let labelCreatedAt = UILabel(frame: CGRect(x: 10, y: 70, width: 300, height: 30))
        labelCreatedAt.textAlignment = .left
        labelCreatedAt.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        //to worked on
        if let createdAt = posts[section].createdAt {
            let createdAt = createdAt
             
            let dateFormatter = DateFormatter()//dateFormat has to look same as string data coming in
            
            //let stringDate = dateFormatter.string(from: createdAt)
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"//data extracted looks like this -> 2018-09-30 18:58:05 +0000
            //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            dateFormatter.isLenient = true
            //print(type(of: stringDate))
             
            //let date = dateFormatter.date(from: stringDate)
            //print(date!)
             
            //this will make date coming like this 2018-09-30 18:58:05 +0000 turn like this //yyyy-MM-dd HH:mm:ssZ
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            print("createdAt : \(createdAt)")
            let timeCreatedAt = dateFormatter.string(from: createdAt)
            labelCreatedAt.text = "Posted on \(timeCreatedAt)"
        }
        
        footerView.addSubview(labelCreatedAt)
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        //check for section clicked on
        if checked[section] {
            return 0
        }
        
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.section)")
        print("Value: \(posts[indexPath.section])")
        
        //change value of checked section to hide/show
        checked[indexPath.section] = !checked[indexPath.section]
        /*
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [.repeat, .curveEaseOut, .autoreverse], animations: {
            
            self.myTableView.reloadData()
        }, completion: nil)
 */
        //self.myTableView.beginUpdates()
        self.myTableView.reloadRows(at: [indexPath], with: .none)
        //self.myTableView.endUpdates()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = myTableView.contentSize.height//size of content of whole table, all data requested
            let phoneFrame = myTableView.frame.height//height of the phone
            let scrollOffsetThreshold = scrollViewContentHeight - phoneFrame//when reached end of
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > (scrollOffsetThreshold + 60) && myTableView.isTracking) {
                
                var insets = myTableView.contentInset
                insets.bottom += 45//InfiniteScrollActivityView.defaultHeight -> 60
                myTableView.contentInset = insets
                
                print("beginBatchFetch")
                
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                //width same as table width, height same as default indicator
                //position x start from the very most left and y start right after the table end
                let frame = CGRect(x: 0, y: myTableView.contentSize.height-8, width: myTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                
                loadingMoreView?.frame = frame//this is how big indicator will be and positioned
                loadingMoreView!.startAnimating()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // Code to load more results
                    self.fetchData()
                }
            }
        }
    }
}

/*
 let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
 let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: nil)
 
 navigationItem.rightBarButtonItems = [add, play]
 */
