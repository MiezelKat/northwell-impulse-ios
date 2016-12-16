//
//  CTFPulsusFormStepViewController.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/16/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

struct CTFPulsusFormItemAnswerStruct {
    var identifier: NSCoding & NSCopying & NSObjectProtocol
    var value: Int
}

class CTFPulsusFormStepViewController: ORKStepViewController, UITableViewDataSource, UITableViewDelegate, CTFFormItemCellDelegate {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var titleTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nextButton: CTFBorderedButton!
    @IBOutlet weak var formItemTableView: UITableView!
    
    override convenience init(step: ORKStep?) {
        self.init(step: step, result: nil)
    }
    
    override convenience init(step: ORKStep?, result: ORKResult?) {
        
        let framework = Bundle(for: CTFPulsusFormStepViewController.self)
        self.init(nibName: "CTFPulsusFormStepViewController", bundle: framework)
        self.step = step
        self.initializeResults(result)
        self.restorationIdentifier = step!.identifier

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell
        let nib = UINib(nibName: "CTFFormItemCell", bundle: nil)
        self.formItemTableView.register(nib, forCellReuseIdentifier: "ctf_form_item_cell")
        self.formItemTableView.rowHeight = UITableViewAutomaticDimension
        self.formItemTableView.estimatedRowHeight = 150
        self.formItemTableView.separatorInset = UIEdgeInsets.zero
        self.formItemTableView.allowsSelection = false
        
        
        self.titleTextView.text = self.step?.title
        self.nextButton.setTitle("Next", for: UIControlState())
        self.nextButton.configuredColor = self.view.tintColor
        
    }
    
    fileprivate var formItems: [ORKFormItem]? {
        guard let formStep = self.step as? CTFPulsusFormStep,
            let formItems = formStep.formItems else {
                return nil
        }
        
        return formItems
    }
    
    func initializeResults(_ result: ORKResult?) {
        
        guard let stepResult = result as? ORKStepResult,
             let itemResults = stepResult.results,
            var _ = self.answerDictionary else {
                return
        }
        
        itemResults.forEach { itemResult in
            guard let scaleResult = itemResult as? ORKScaleQuestionResult,
                let scaleValue = scaleResult.scaleAnswer as? Int else {
                    return
            }
            
            self.answerDictionary![scaleResult.identifier] = scaleValue
        }
        
    }
    
    var answerDictionary: [String: Int]?
    
    //whenver step is set, initialize the answerArray
    override var step: ORKStep? {
        didSet {
            guard let step = step as? CTFPulsusFormStep
                else { return }
            
            self.answerDictionary = [String: Int]()
            
            step.formItems?.forEach { formItem in
                if let answerFormat = formItem.answerFormat as? ORKScaleAnswerFormat {
                    self.answerDictionary![formItem.identifier] = answerFormat.defaultValue
                }
                else {
                    self.answerDictionary![formItem.identifier] = Int.max
                }
            }
        }
    }
    
    override var result: ORKStepResult? {
        guard let parentResult = super.result
            else {
            return nil
        }
        
        guard let step = self.step as? CTFPulsusFormStep,
            let formItems = step.formItems,
            let answerDictionary = self.answerDictionary else {
                return parentResult
        }
        
        let now = parentResult.endDate
        
        let formItemResults:[ORKScaleQuestionResult] = formItems.map { formItem in
            
            let scaleResult = ORKScaleQuestionResult(identifier: formItem.identifier)
            scaleResult.scaleAnswer = answerDictionary[formItem.identifier] as NSNumber?
            scaleResult.startDate = now
            scaleResult.endDate = now
            return scaleResult
        }
        
        parentResult.results = formItemResults
        
        return parentResult
    }
    
    override func viewWillLayoutSubviews() {
        
        let sizeThatFits = self.titleTextView.sizeThatFits(CGSize(width: self.titleTextView.frame.size.width, height: CGFloat(MAXFLOAT)))
        self.titleTextViewHeight.constant = sizeThatFits.height
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.formItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ctf_form_item_cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        
        guard let pulsusCell = cell as? CTFFormItemCell,
            let formItem = self.formItems?[indexPath.row] else {
                return cell
        }

        pulsusCell.configure(formItem, value: self.answerDictionary![formItem.identifier]!)
        
        pulsusCell.delegate = self
        
        pulsusCell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.white : UIColor(hexString: "#f2f2f2")
        
        return pulsusCell
    }
    
    func formItemCellAnswerChanged(_ cell: CTFFormItemCell, answer: Int) {
        if let formItem = cell.formItem {
            self.answerDictionary![formItem.identifier] = answer
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        self.goForward()
    }
}
