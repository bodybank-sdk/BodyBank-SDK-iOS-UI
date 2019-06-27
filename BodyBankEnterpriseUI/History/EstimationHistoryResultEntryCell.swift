//
//  EstimationResultCell.swift
//  Bodygram
//
//  Created by Shunpei Kobayashi on 2018/05/19.
//  Copyright © 2018年 Original Inc. All rights reserved.
//

import UIKit

open class EstimationHistoryResultEntryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var templateLabel: UILabel!
    
    open var name: String!{
        didSet{
            titleLabel.text = name
        }
    }

    func setValueAndUnit(value: Double, unit: String?){
        templateLabel.isHidden = true
        valueLabel.text = String(format: "%.1f%@", value, unit ?? "")
    }
    
    
    func setValueAndUnit(value: Double, template: Double, unit: String?){
        templateLabel.isHidden = false
        valueLabel.text = String(format: "%.1f%@", value, unit ?? "")
        templateLabel.text = String(format: "[%.1f]", template)
        
        let abs = fabsl(template - value) 
        print("[ABS]:\(abs)")
        
        switch abs {
        case 0.0..<1.6:
            templateLabel.textColor = .blue
        case 1.5..<2.6:
            templateLabel.textColor = .green
        case 2.5..<4.1:
            templateLabel.textColor = .orange
        default:
            templateLabel.textColor = .red
        }
    }
    
    func setValueAndUnit(value: Int, unit: String?){
        templateLabel.isHidden = true
        valueLabel.text = String(format: "%d%@", value, unit ?? "")
    }
  
    func setValueAndUnit(value: String, unit: String?){
        templateLabel.isHidden = true
        valueLabel.text = "\(value)\(unit ?? "")"
    }
}
