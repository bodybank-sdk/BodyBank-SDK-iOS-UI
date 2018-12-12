//
//  WeightPickerViewController.swift
//  BodyBank-Showcase
//
//  Created by Shunpei Kobayashi on 2018/11/19.
//  Copyright © 2018 Shunpei Kobayashi. All rights reserved.
//

import UIKit
import Alertift

class WeightPickerViewController: BasePickerViewController{
    var isPound: Bool{
        get{
            return unit == "lbs"
        }
        
        set{
            if isPound{
                unit = "lbs"
            }else{
                unit = "kg"
            }
        }
    }
    
    let units = ["kg", "lbs"]
    
    var weightInKg: Double{
        get{
            if isPound{
                let stringRepresentation = inputField.text!
                let pound_oz = stringRepresentation.split(separator: ".")
                let pound = Double(pound_oz[0])!
                let oz = Double(pound_oz[1])!
                let kgPerPound = 0.4535924
                let ozPerPound = kgPerPound / 12.0
                let kg = pound * kgPerPound + oz * ozPerPound
                return kg
            }else{
                return Double(inputField.text!)!
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    override func showUnitSelector() {
        Alertift.actionSheet(title: NSLocalizedString("Select the weight unit.", comment: ""), message: "")
            .action(.default("kg")){[unowned self] _,_ in
               self.unit = "kg"
            }.action(.default("lbs")){[unowned self] _,_ in
               self.unit = "lbs"
        }.action(.cancel("Cancel")).show(on: self, completion: nil)
    }
    
    override func setInitialValue(valueString: String, unit: String) {
        if unit.isEmpty{
            super.setInitialValue(valueString: valueString, unit: "kg")
        }else{
            super.setInitialValue(valueString: valueString, unit: unit)
        }
    }
}
