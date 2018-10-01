//
//  PostTableViewCell.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 9/30/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    //let cityLabel = UILabel(), stateLabel = UILabel()
    //let myImagePost = UIImageView(frame: CGRect(x: 10, y: 10, width: 300, height: 300))
    let myImagePost = UIImageView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: tableWidth))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initViews()
    }
    
    func initViews() {
        //        let (stateRect, cityRect) = frame.insetBy(dx: 10, dy: 10).divided(atDistance: 40, from:.maxXEdge)
        //        cityLabel.frame = cityRect
        //        stateLabel.frame = stateRect
        /*
        myImagePost.translatesAutoresizingMaskIntoConstraints = false
        let margins = myImagePost.layoutMarginsGuide
        print("margins: \(margins)")
        NSLayoutConstraint(item: myImagePost, attribute: .leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: margins, attribute: NSLayoutConstraint.Attribute.leadingMargin, multiplier: 1.0, constant: 20.0).isActive = true
        NSLayoutConstraint(item: myImagePost, attribute: .trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: margins, attribute: NSLayoutConstraint.Attribute.trailingMargin, multiplier: 1.0, constant: 20.0).isActive = true
        NSLayoutConstraint(item: myImagePost, attribute: .top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: margins, attribute: NSLayoutConstraint.Attribute.topMargin, multiplier: 1.0, constant: 20.0).isActive = true
        NSLayoutConstraint(item: myImagePost, attribute: .bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: margins, attribute: NSLayoutConstraint.Attribute.bottomMargin, multiplier: 1.0, constant: 20.0).isActive = true
        //myImagePost.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10).isActive = true
        //myImagePost.leadingAnchor.constraint(equalToSystemSpacingAfter: margins.leadingAnchor, multiplier: 10).isActive = true
        
        myImagePost.translatesAutoresizingMaskIntoConstraints = true
        myImagePost.autoresizingMask = [
            UIImageView.AutoresizingMask.flexibleWidth,
            UIImageView.AutoresizingMask.flexibleHeight,
            //UIImageView.AutoresizingMask.flexibleTopMargin,
            //UIImageView.AutoresizingMask.flexibleBottomMargin
        ]
        //myImagePost.addConstraints([leftSpaceConstraint, topSpaceConstraint])
        */
        self.addSubview(myImagePost)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
