//
//  ConsentTableViewCell.swift
//  NatureNet
//
//  Created by Jinyue Xia on 2/27/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ConsentTableViewCell: UITableViewCell {

    @IBOutlet weak var consentTextLabel: UILabel!
    @IBOutlet weak var consentSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
