//
//  ComposeViewController.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 9/29/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    /*******************************************
     * UIVIEW CONTROLLER LIFECYCLES FUNCTIONS *
     *******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /********* Title In Nav Bar *******/
        setTitleInNavBar()

        /******* Cancel and Share btns to HomeFeedVC in Nav Bar *****/
        setNavBarSidesBtns()
        
        /******** Instantiate a UIImagePickerController *******/
        setImagePicker()
        
        //*** For image profile to be used ***//
        let imageTap =  UITapGestureRecognizer(target: self, action: #selector(setImagePicker))
        
        //to be able to use it by just tapping on image
        imageToPost.isUserInteractionEnabled = true
        imageToPost.addGestureRecognizer(imageTap)
        
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
        let titleText = NSAttributedString(string: "Compose", attributes: strokeTextAttributes)
        
        //adding the titleText
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
    
    func setNavBarSidesBtns(){
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBtn))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareBtn))
        
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(LogOut))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(LogOut))
        /*
         let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
         let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: nil)
         
         navigationItem.rightBarButtonItems = [add, play]
         */
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
    
    /*******************
     * @OBJC FUNCTIONS *
     *******************/
    @objc func cancelBtn(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func shareBtn(){
        
        Post.postUserImage(image: imageToPost.image, withCaption: captionField.text, withCompletion: nil)
        
        dismiss(animated: true, completion: nil)
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
            imageToPost.image = imageEdited
            
        } else if let image = info[.originalImage] as? UIImage {
            print("Original Image was taken")
            
            //set the image size in terms of width and height, will be equal to almost 1MB, what I want
            let size = CGSize(width: 1000, height: 1000)
            
            //resize image to be less than 1MB
            let img = resize(image: image, newSize: size)
            
            //put it in the image view
            imageToPost.image = img
            
        } else {
            //Error Message
            print("There was an error uploading image to VC")
        }
        
        // Do something with the images (based on your use case)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }

}
