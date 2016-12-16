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
    
    let defaultTrackHeight: CGFloat = 4

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var minTextLabel: UILabel!
    @IBOutlet weak var midTextLabel: UILabel!
    @IBOutlet weak var maxTextLabel: UILabel!
    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var trackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var trackContainerView: UIView!
    
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
            
            self.trackHeightConstraint.constant = scaleAnswerFormat.trackHeight ?? defaultTrackHeight
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:)))
        self.trackContainerView.addGestureRecognizer(tapGestureRecognizer)
        
        self.setValue(value)
    }
    
    func configureTrack() {
        self.trackView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        if let scaleAnswerFormat = self.formItem?.answerFormat as? CTFScaleAnswerFormat,
            let gradientColors = scaleAnswerFormat.gradientColors {
            self.valueSlider.minimumTrackTintColor = UIColor.clear
            self.valueSlider.maximumTrackTintColor = UIColor.clear
            
            
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = self.trackView.bounds
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.colors = gradientColors.map({$0.cgColor})
            self.trackView.layer.insertSublayer(gradient, at: 0)
            
            self.trackView.layer.cornerRadius = self.trackHeightConstraint.constant / 2.0
        }
        else {
            self.valueSlider.minimumTrackTintColor = UIColor(red: 0.0021, green: 0.5427, blue: 0.8975, alpha: 1.0)
            self.valueSlider.maximumTrackTintColor = UIColor.gray
            self.trackView.backgroundColor = UIColor.clear
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.trackView.layoutIfNeeded()
        self.configureTrack()
    }

    func setValue(_ value: Int) {
        self.valueSlider.setValue(Float(value), animated: true)
        self.updateValueLabel(value)
    }
    
    func sliderSet(_ floatValue: Float) {
        let intValue = lroundf(floatValue)
        self.setValue(intValue)
        
        if let delegate = self.delegate {
            delegate.formItemCellAnswerChanged(self, answer: intValue)
        }
    }
    
    @IBAction func sliderChanged(_ sender: AnyObject) {
        let sliderValue = self.valueSlider.value
        self.sliderSet(sliderValue)
    }
    
    func sliderTapped(_ tapRecognizer: UITapGestureRecognizer) {
        let touchPoint = tapRecognizer.location(in: tapRecognizer.view)
        let sliderPercentage = Float(touchPoint.x) / Float(tapRecognizer.view!.bounds.size.width)
        let sliderValue: Float = self.valueSlider.minimumValue + (self.valueSlider.maximumValue - self.valueSlider.minimumValue)*sliderPercentage
        self.sliderSet(sliderValue)
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
