//
//  WeightPickerViewController.swift
//  BodyBank-Showcase
//
//  Created by Shunpei Kobayashi on 2018/11/19.
//  Copyright © 2018 Shunpei Kobayashi. All rights reserved.
//

import UIKit

class AgePickerViewController: BasePickerViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        defaultValue = 25
    }
    
    
    var age: Int{
        get{
            return Int(inputField.text!)!
        }
    }
    
    override func correctedValueString(forValue value: Double) -> String {
        return String(format: "%.0f", value)
    }
    
    override func showUnitSelector() {
        //Do nothing
    }
    
}
