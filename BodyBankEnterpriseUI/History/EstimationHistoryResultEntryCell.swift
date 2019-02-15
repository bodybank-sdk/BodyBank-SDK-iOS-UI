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

    open var name: String!{
        didSet{
            titleLabel.text = name
        }
    }
    func setValueAndUnit(value: Double, unit: String?){
        valueLabel.text = String(format: "%.1f%@", value, unit ?? "")
    }
    
    func setValueAndUnit(value: Int, unit: String?){
        valueLabel.text = String(format: "%d%@", value, unit ?? "")
    }
  
    func setValueAndUnit(value: String, unit: String?){
        valueLabel.text = "\(value)\(unit ?? "")"
    }
}
