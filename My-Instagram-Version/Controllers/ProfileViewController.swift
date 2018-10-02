//
//  ProfileViewController.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 10/1/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [PFObject] = []
    let PFPhotoView = PFImageView()//set image from Parse-Server
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        
        //Calling to set grid layout
        changeGridLayout()
        
        print("KKKKKKKKKKKKKKKKKKKK")
        
        /********* Fetch data from Parse-server ********/
        fetchData()
        
        /**********Prepare Image profile ********************/
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.width / 2;
        profileImage.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileImage.layer.borderWidth = 1;
    }
    
    /*******************
     * @OBJC FUNCTIONS *
     *******************/
    @objc func changeGridLayout(){
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        //number of cells for collections in a row
        let cellsPerLine: CGFloat = 3
        
        //spaces between cells are always 1 less than the number of cells
        let interItemSpaces = cellsPerLine - 1
        
        //minimumInteritemSpacing it's space between width of posters
        layout.minimumInteritemSpacing = 1// Icould be taken it from storyboard
        layout.minimumLineSpacing = 1// Icould be taken it from storyboard
        
        //the width of each poster, whole collection width minus the product
        //of the minimum space between cells times the # of cells, divided by cells per row
        let width = (collectionView.frame.size.width - layout.minimumInteritemSpacing*interItemSpaces) / cellsPerLine
        
        //the size of each poster item is width and height 1:1 ratio
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    /************************
     * MY CREATED FUNCTIONS *
     ************************/
    func fetchData(){
        
        let post = Post()
        //Get the current user and assign it to "author" field. "author" field is now of Pointer type
        post.author = PFUser.current()!
        
        
                let query = Post.query()
                query?.order(byDescending: "createdAt")
                //query?.addDescendingOrder("createdAt")
                //query?.whereKey("objectId", equalTo: userID)
                query?.includeKey("author")
                query?.whereKey("username", equalTo: "DVtYsCBnAL")
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
                        print("incoming posts")
                        print(incomingPosts)
                        
                        //unwraps the whole object first
                        if let author = self.posts[0]["author"] as? PFObject{
                            //then unwraps the key and value
                            if let username = author.value(forKey: "username") {
                                print("Username: \(username)")
                                self.usernameLabel.text = username as? String
                            }
                        }
                        
                        
                        //reload collection after all movies are input in movies array
                        self.collectionView.reloadData()
                        
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
    
    /****************************
     * CollectionView functions *
     ****************************/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCollectionCell", for: indexPath) as! ProfileImagesCollectionViewCell
        
        PFPhotoView.file = (self.posts[indexPath.item]["media"] as! PFFile)
        print("YYYYimagen file: \(String(describing: self.PFPhotoView.file))")
        
        print("YYYYsection #: \(indexPath.item)")
        PFPhotoView.load(inBackground: {(imagen, error) in
            cell.myPostedPhotos.image = imagen
        })
        
        return cell
    }

}
