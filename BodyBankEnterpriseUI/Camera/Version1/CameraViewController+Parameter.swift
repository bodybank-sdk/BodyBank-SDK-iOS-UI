//
//  CameraViewController+ParameterViewController.swift
//  AFDateHelper
//
//  Created by Masashi Horita on 2019/06/17.
//

import UIKit
import AVFoundation

public extension CameraViewController{
    
    @IBAction func didFinishPickingParameter(segue: UIStoryboardSegue){
        if let vc = segue.source as? AgePickerViewController{
            estimationParameter.age = vc.age
            ageValueLabel.text = String(estimationParameter.age)
        }else if let vc = segue.source as? HeightPickerViewController{
            estimationParameter.heightInCm = vc.heightInCm
            heightValueLabel.text = String(format:"%.2f", vc.currentValue)
            heightUnitLabel.text = vc.unit
        }else if let vc = segue.source as? WeightPickerViewController{
            estimationParameter.weightInKg = vc.weightInKg
            weightValueLabel.text = String(format:"%.2f", vc.currentValue)
            weightUnitLabel.text = vc.unit
        }
    }
}
