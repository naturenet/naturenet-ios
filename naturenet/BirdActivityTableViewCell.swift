//
//  BirdActivityTableViewCell.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/22/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class BirdActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var numberPickerView: UIPickerView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var birdNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
