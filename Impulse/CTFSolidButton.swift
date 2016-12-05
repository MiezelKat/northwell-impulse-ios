//
//  CTFSolidButton.swift
//  Impulse
//
//  Created by James Kizer on 12/4/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit

class CTFSolidButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
    }
    
//    private func setTitleColor(_ color: UIColor?) {
//        self.setTitleColor(color, for: UIControlState.normal)
//        self.setTitleColor(UIColor.white, for: UIControlState.highlighted)
//        self.setTitleColor(UIColor.white, for: UIControlState.selected)
//        self.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: UIControlState.disabled)
//    }
    
    override var backgroundColor: UIColor? {
        didSet {
            
            self.setTitleColor(UIColor.white, for: UIControlState.normal)
            self.setTitleColor(self.backgroundColor, for: UIControlState.highlighted)
            self.setTitleColor(self.backgroundColor, for: UIControlState.selected)
            self.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: UIControlState.disabled)
        }
    }
    
    var configuredColor: UIColor? {
        didSet {
            if let color = self.configuredColor {
                self.backgroundColor = color
            }
            else {
                self.backgroundColor = self.tintColor
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let color = self.backgroundColor {
            self.layer.borderColor = color.cgColor
        }
        
        
    }
    
    override func tintColorDidChange() {
        //if we have not configured the color, set
        super.tintColorDidChange()
        if let _ = self.configuredColor {
            return
        }
        else {
            self.backgroundColor = self.tintColor
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width + 20.0, height: superSize.height)
    }

}
