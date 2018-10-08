//
//  CommentsViewController.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 10/7/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit
import Parse

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var commentPost: PFObject? = nil//it's the post PFObject coming from HomeFeedVC
    
    var comments: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /*********set the comment*******/
        comment()
        
        /*********Title In Nav Bar*******/
        setTitleInNavBar()
        
        setupViewResizerOnKeyboardShown()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300//if all rows vary in size
        //estimatedHeightForRowAtIndexPath//to estimate height on different rows if they variate a lot in size

    }
    
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
    
    func comment(){
        
        if let commentCounts = commentPost!["commentsCount"]{
            let commentsCount = (commentCounts as? Int)! + 1
            commentPost!["commentsCount"] = commentsCount
            print("commentsCount: \(commentsCount)")
            
            commentPost!.setObject(commentsCount, forKey: "commentsCount")
            commentPost!.saveInBackground(block: {(success: Bool, error: Error?) -> Void in
                
            })
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath as IndexPath) as! CommentsTableViewCell
        
        cell.backgroundColor = #colorLiteral(red: 0.8153101802, green: 0.8805506825, blue: 0.8921775818, alpha: 0.92)
        cell.textLabel?.numberOfLines =  0
        
        cell.textLabel!.text = "loco"//comments[indexPath.row]
        
        return cell
    }

    @IBAction func commentAction(_ sender: Any) {
    }
}
