//
//  BasePickerViewController.swift
//  BodyBank-Showcase
//
//  Created by Shunpei Kobayashi on 2018/11/19.
//  Copyright © 2018 Shunpei Kobayashi. All rights reserved.
//

import UIKit

class BasePickerViewController: UIViewController {
    @IBOutlet weak var saveButtonBackground: UIView!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    var gradientLayer: CALayer?
    open var unit: String!
    
    var initialValueString: String?
    
    var currentValue: Double{
        get{
            if let text = inputField.text{
                if let value = Double(text){
                    return value
                }else{
                    return defaultValue
                }
            }else{
                return defaultValue
            }
        }
    }
    
    open var defaultValue: Double = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        inputField.text = initialValueString
        if initialValueString == "-"{
           saveButton.isEnabled = false
        }
        unitLabel.text = unit
        let rec = UITapGestureRecognizer(target: self, action: #selector(self.backgroundDidTap(sender:)))
        view.addGestureRecognizer(rec)
        inputField.delegate = self
    }
    

    @objc func backgroundDidTap(sender: Any){
       inputField.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async{[unowned self] in
            self.buildGradientLayer()
        }
    }

    func buildGradientLayer(){
        if gradientLayer == nil{
            gradientLayer = CAGradientLayer(frame: saveButtonBackground.bounds, colors: [
                UIColor.BodyBank.Gradient.begin,
                UIColor.BodyBank.Gradient.end
                ], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
            if let gradientLayer = gradientLayer{
                saveButtonBackground.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
    }
    

    @IBAction func minusButtonDidTap(sender: Any){
        inflateDefaultValue()
        let value = Double(inputField.text!)!
        let nextValue = max(value - 1, 0)
        inputField.text = correctedValueString(forValue: nextValue)
    }
    
    open func correctedValueString(forValue value: Double) -> String{
        return String(format: "%.2f", value)
    }

    @IBAction func plusButtonDidTap(sender: Any){
        inflateDefaultValue()
        let value = Double(inputField.text!)!
        let nextValue = max(value + 1, 0)
        inputField.text = correctedValueString(forValue: nextValue)
    }
    
    @IBAction open func unitButtonDidTap(sender: Any){
       showUnitSelector()
    }
    
    open func showUnitSelector(){
        
    }
    
    
    func setInitialValue(valueString: String, unit: String){
        initialValueString = valueString
        self.unit = unit
   }
    
    func inflateDefaultValue(){
        if inputField.text == "-"{
            inputField.text = correctedValueString(forValue: currentValue)
            saveButton.isEnabled = true
        }
    }
    
}

extension BasePickerViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        inflateDefaultValue()
        return true
    }
    
}

