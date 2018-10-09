//
//  CommentsViewController.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 10/7/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit
import Parse
import RSKPlaceholderTextView

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postBtn: UIButton!
    
    var commentPost: PFObject? = nil//it's the post PFObject coming from HomeFeedVC
    
    var comments: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //start with button disabled as textfield starts empty
        postBtn.isEnabled = false
        
        //delegate to start editing on it
        textView.delegate = self
        
        //set placdeholder from Storyboard by giving this class of RSKPlaceholderTextView
        //textView.placeholder = "Add a comment..."
        
        /*********Title In Nav Bar*******/
        setTitleInNavBar()
        
        /********* Fetch data from Parse-server ********/
        fetchData()
        
        /********** Resizing the scroll view on keyboard appearance **********/
        setupViewResizerOnKeyboardShown()//see extension at the bottom
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300//if all rows vary in size
        //estimatedHeightForRowAtIndexPath//to estimate height on different rows if they variate a lot in size
        
//        //********** For image profile to be used ********//
//        let textViewOnEditing =  UITapGestureRecognizer(target: self, action: #selector(disableBtnPost))
//
//        //to be able to use it by just tapping on image
//        textView.isUserInteractionEnabled = true
//        textView.addGestureRecognizer(textViewOnEditing)
        
       // textView.addTarget(self, action: #selector(disableBtnPost), for: .editingChanged)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //it has to wait for the setupViewResizerOnKeyboardShown() to kick in before
        //can becomeFirstResponder() otherwise textView will not show
        //100 milliseconds 0.1 seconds can make a big deal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Your code with delay
            self.textView.becomeFirstResponder()
        }
        
    }
    
    //incase user types but does not post and returns to homeFeed
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        textView.text = ""
    }
    
    @objc func disableBtnPost(){
        
        
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
        let titleText = NSAttributedString(string: "Comments", attributes: strokeTextAttributes)
        
        //adding the titleText
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if (textView.text?.isEmpty)! {
            postBtn.isEnabled = false
        }else {
            postBtn.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath as IndexPath) as! CommentsTableViewCell
        
        cell.backgroundColor = #colorLiteral(red: 0.8153101802, green: 0.8805506825, blue: 0.8921775818, alpha: 0.92)
        cell.textLabel?.numberOfLines =  0
        
        cell.textLabel!.text = comments[indexPath.row]
        
        return cell
    }

    @IBAction func commentAction(_ sender: Any) {
        
        if let commentCounts = commentPost!["commentsCount"]{
            let commentsCount = (commentCounts as? Int)! + 1
            commentPost!["commentsCount"] = commentsCount
            print("commentsCount: \(commentsCount)")
            
            commentPost!.setObject(commentsCount, forKey: "commentsCount")
            commentPost!.saveInBackground(block: {(success: Bool, error: Error?) -> Void in
                
            })
        }//if
        
        comments.append(textView.text!)
        
        commentPost!.setObject(comments, forKey: "comments")
        commentPost!.saveInBackground(block: {(success: Bool, error: Error?) -> Void in
            
        })
        
        self.tableView.reloadData()
        textView.text = ""
        postBtn.isEnabled = false
    }
    
    func fetchData(){
        
        let postId = commentPost!.objectId
        print("xxxxcommentPosts: \(String(describing: postId))")
        
        let query = Post.query()
        query?.whereKey("objectId", equalTo: postId!)
        
        query?.findObjectsInBackground(block: { (incomingPost, error) in
            if let post = incomingPost {
                
                //1. post/incomingPost is an array of post, but it's only one post in that array
                print("incomingPosts: \(post)")
                
                //2. So we use post[0] to get that post from the network call
                //3. Posts may not have comments yet so make sure they do to assign otherwise first one will be assigned in the IBoulet action to post comments
                if let commentsExists = post[0]["comments"] {
                    self.comments = commentsExists as! [String]
                }
                
                // Reload the tableView now that there is new data
                self.tableView.reloadData()
                
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
}

private extension UIViewController{
    
    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShowForResizing),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHideForResizing),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShowForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }
    
    @objc func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }
}
