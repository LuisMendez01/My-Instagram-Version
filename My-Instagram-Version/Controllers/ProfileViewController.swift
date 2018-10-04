//
//  ProfileViewController.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 10/1/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class ProfileViewController: UIViewController, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var postCountLabel: UILabel!
    
    var posts: [PFObject] = []
    let PFPhotoView = PFImageView()//set image from Parse-Server to collectionView
    
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
        
        //********** For image profile to be used ********//
        let imageTap =  UITapGestureRecognizer(target: self, action: #selector(setImagePicker))
        
        //to be able to use it by just tapping on image
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTap)
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
      
        print("post.author.username: \(String(describing: post.author.username))")
        
        let query = Post.query()
        query?.cachePolicy = .cacheElseNetwork
        query?.order(byDescending: "createdAt")
        query?.whereKey("author", equalTo: post.author)
        query?.limit = 15
                
        // fetch data asynchronously
        query?.findObjectsInBackground(block: { (incomingPosts, error) in
                if let incomingPosts = incomingPosts {
                        
                    for post in incomingPosts {
                        let post = post
                        print("post: \(post)")
                    }
                        
                // do something with the array of object returned by the call
                self.posts = incomingPosts
                print("incoming posts")
                print(incomingPosts)
                    
                // 1. unwrap username value to be used
                if let username = post.author.username {
                    print("Username: \(username)")
                    self.usernameLabel.text = username
                    
                    /*********** Set Title of Bar Controller to username **************/
                    let titleLabel = UILabel()//for the title of the page
                    
                    //set some attributes for the title of this controller
                    let strokeTextAttributes: [NSAttributedString.Key: Any] = [
                        .strokeColor : UIColor.white,
                        .foregroundColor : UIColor(cgColor: #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)),  /*UIColor(red: 0.5, green: 0.25, blue: 0.15, alpha: 0.8)*/
                        .strokeWidth : -1,
                        .font : UIFont.boldSystemFont(ofSize: 21)
                    ]
                    
                    //set the name and put in the attributes for it
                    let titleText = NSAttributedString(string: username, attributes: strokeTextAttributes)
                    titleLabel.attributedText = titleText
                    titleLabel.sizeToFit()
                    self.navigationItem.titleView = titleLabel
                }
                    
                // 2. Get post # How many posts have user posted
                self.postCountLabel.text = "\(self.posts.count)"
                    
                // 3. get img profile pic
                if let userPicture = PFUser.current()?["image"] as? PFFile {
                        
                    self.PFPhotoView.file = userPicture
                    print("imagen file xxxuuu: \(String(describing: self.PFPhotoView.file))")
                        
                    self.PFPhotoView.load(inBackground: {(imagen, error) in
                        //print("pngDATA: \(String(describing: imagen)))")
                        self.profileImage.image = imagen
                    })
                }
                
                //reload collection after all movies are input in movies array
                self.collectionView.reloadData()
                        
                } else {
                        print(error?.localizedDescription as Any)
                    }
            })
    }
    
    private func resize(image: UIImage, newSize: CGSize) -> UIImage {
        
        let resizeImageView = UIImageView(frame: CGRect(x:0, y:0, width: newSize.width, height: newSize.height))
        resizeImageView.contentMode = UIView.ContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func updateCurrentUserProfilePicture(image: UIImage) {
        let avatar = PFFile(name: PFUser.current()!.username, data: image.pngData()!)
        PFUser.current()!.setObject(avatar!, forKey: "image")
        PFUser.current()!.saveInBackground(block: {(success: Bool, error: Error?) -> Void in
            
        })
    }
    
    @objc func setImagePicker(){
        
        let PickerVC = UIImagePickerController()
        PickerVC.delegate = self
        PickerVC.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            PickerVC.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            //image will be dragged from photoLibrary
            PickerVC.sourceType = .photoLibrary
        }
        
        self.present(PickerVC, animated: true, completion: nil)
    }
    
    /****************************
     * PICKERDELEGATE FUNCTIONS *
     ****************************/
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Get the image captured by the UIImagePickerController
        //Set image as UIImage if all good then set it to our image variable
        if let editedImage = info[.editedImage] as? UIImage {
            print("editedImage was taken")
            //set the image size in terms of width and height, will be equal to almost 5MB, what I want
            let size = CGSize(width: 1000, height: 1000)
            
            //resize image to be less than 1MB
            let imageEdited = resize(image: editedImage, newSize: size)
            profileImage.image = imageEdited
            
            //Making network posting image to Parse-Server
            self.updateCurrentUserProfilePicture(image: self.profileImage.image!)
            
        } else if let image = info[.originalImage] as? UIImage {
            print("Original Image was taken")
            
            //set the image size in terms of width and height, will be equal to almost 1MB, what I want
            let size = CGSize(width: 1000, height: 1000)
            
            //resize image to be less than 1MB
            let img = resize(image: image, newSize: size)
            
            //put it in the image view
            profileImage.image = img
            
            //Making network posting image to Parse-Server
            self.updateCurrentUserProfilePicture(image: self.profileImage.image!)
            
        } else {
            //Error Message
            print("There was an error uploading image to VC")
        }
        
        // Do something with the images (based on your use case)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
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



//        // construct query with predicates
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
