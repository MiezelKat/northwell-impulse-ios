//
//  CTFActivityTableViewCell.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit

class CTFActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var uncheckedView: UIView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel?
    
    var complete: Bool = false {
        didSet {
            self.uncheckedView.isHidden = complete
            self.checkmarkImageView.isHidden = !complete
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.uncheckedView.layer.borderColor = UIColor.lightGray.cgColor
        self.uncheckedView.layer.borderWidth = 1
        self.uncheckedView.layer.cornerRadius = self.uncheckedView.bounds.size.height / 2
        
        self.timeLabel?.textColor = self.tintColor
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.timeLabel?.textColor = self.tintColor
    }
}
