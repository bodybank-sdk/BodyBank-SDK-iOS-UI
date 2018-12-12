//
//  HeightPickerViewController.swift
//  Bodygram
//
//  Created by Shunpei Kobayashi on 2018/05/13.
//  Copyright © 2018年 Original Inc. All rights reserved.
//

import UIKit
import Alertift
class HeightPickerViewController: BasePickerViewController{
    var isFeet: Bool{
        get{
            return unit == "ft"
        }
        
        set{
            if isFeet{
                unit = "ft"
            }else{
                unit = "cm"
            }
        }
    }
    
    var heightInCm: Double{
        get{
            
            if isFeet{
                let cmPerFeet = 30.48
                let cmPerInch = cmPerFeet / 12.0
                let feet_inch = inputField.text!.split(separator: ".")
                let feet = Double(feet_inch[0])!
                let inch = Double(feet_inch[1])!
                let feetsInCm = feet * cmPerFeet
                let inchesInCm = inch * cmPerInch
                return feetsInCm + inchesInCm
            }else{
                return Double(inputField.text!)!
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        defaultValue = 150
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func showUnitSelector() {
        Alertift.actionSheet(title: NSLocalizedString("Select the height unit.", comment: ""), message: "")
            .action(.default("ft")){[unowned self] _,_ in
                self.unit = "ft"
            }.action(.default("cm")){[unowned self] _,_ in
                self.unit = "cm"
            }.action(.cancel("Cancel")).show(on: self, completion: nil)
    }
    
    override func setInitialValue(valueString: String, unit: String) {
        if unit.isEmpty{
            super.setInitialValue(valueString: valueString, unit: "cm")
        }else{
            super.setInitialValue(valueString: valueString, unit: unit)
        }
    }
    
}
