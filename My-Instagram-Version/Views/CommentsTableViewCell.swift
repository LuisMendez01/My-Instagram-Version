//
//  CommentsTableViewCell.swift
//  My-Instagram-Version
//
//  Created by Luis Mendez on 10/7/18.
//  Copyright © 2018 Luis Mendez. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
