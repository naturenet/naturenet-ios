//
//  ActivityIconTableViewCell.swift
//  NatureNet
//
//  Created by Jinyue Xia on 5/13/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ActivityIconTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
