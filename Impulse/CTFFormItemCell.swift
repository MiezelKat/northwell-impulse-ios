//
//  CTFFormItemCell.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/16/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

protocol CTFFormItemCellDelegate {
    func formItemCellAnswerChanged(_ cell: CTFFormItemCell, answer: Int)
}


class CTFFormItemCell: UITableViewCell {
    
    let kStackViewWidthDifference: CGFloat = 24
    let kValueLabelWidth: CGFloat = 24
    let kValueLabelHeight: CGFloat = 24
    let kStackViewSpacing: CGFloat = 20

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var minTextLabel: UILabel!
    @IBOutlet weak var midTextLabel: UILabel!
    @IBOutlet weak var maxTextLabel: UILabel!
    
    var delegate: CTFFormItemCellDelegate?
    var answer: AnyObject? {
        didSet {
            if let answer = self.answer as? Int {
                self.setValue(answer)
            }
        }
    }
    
    var formItem: ORKFormItem?
    
    override func awakeFromNib() {
        self.valueSlider.minimumTrackTintColor = UIColor(red: 0.0021, green: 0.5427, blue: 0.8975, alpha: 1.0)
        self.valueSlider.maximumTrackTintColor = UIColor.gray
        self.contentView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 8)
    }
    
    func configure(_ formItem: ORKFormItem, value: Int) {
        self.formItem = formItem
        self.titleLabel.text = formItem.text

        if let scaleAnswerFormat = formItem.answerFormat as? ORKScaleAnswerFormat {
            self.valueSlider.minimumValue = Float(scaleAnswerFormat.minimum)
            self.valueSlider.maximumValue = Float(scaleAnswerFormat.maximum)
            self.valueSlider.value = Float(scaleAnswerFormat.defaultValue)
            self.minTextLabel.text = scaleAnswerFormat.minimumValueDescription
            self.maxTextLabel.text = scaleAnswerFormat.maximumValueDescription
        }
        
        if let scaleAnswerFormat = formItem.answerFormat as? CTFScaleAnswerFormat {
            self.midTextLabel.text = scaleAnswerFormat.intermediateValueDescription
        }
        
        self.setValue(value)
        
    }

    func setValue(_ value: Int) {
        self.valueSlider.setValue(Float(value), animated: true)
        self.updateValueLabel(value)
    }
    
    @IBAction func sliderChanged(_ sender: AnyObject) {
        let sliderValue = self.valueSlider.value
        let intValue = lroundf(sliderValue)
        self.setValue(intValue)
        
        if let delegate = self.delegate {
            delegate.formItemCellAnswerChanged(self, answer: intValue)
        }
        
    }
    
    func updateValueLabel(_ value: Int) {
        if let scaleAnswerFormat = (self.formItem?.answerFormat as? CTFScaleAnswerFormat),
            let type = scaleAnswerFormat.scaleType,
            type == CTFScaleAnswerType.semanticDifferential
            {
            self.valueLabel.text = nil
        }
        else {
            self.valueLabel.text = "\(value)"
        }
        
    }
}
