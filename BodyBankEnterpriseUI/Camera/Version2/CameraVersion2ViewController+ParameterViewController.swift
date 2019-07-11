//
//  CameraVersion2ViewController+ParameterViewController.swift
//
//  Created by Masashi Horita on 2019/06/17.
//

public extension CameraVersion2ViewController{
    
    /// set Estimation Parameter
    /// [Gender,Age,Height,Weight]
    /// - Returns: false: error
    func setupEstimationParameter () -> Bool{

        // gender
        switch genderSegmented.selectedSegmentIndex {
        case 0:
            estimationParameter.gender = .male
        default:
            estimationParameter.gender = .female
        }
        
        // age
        let age = Int(ageTextField.text ?? "-1") ?? -1
        if age < 0 { return false }
        estimationParameter.age = age
        
        // height
        let height:Double = Double(heightTextField.text ?? "-1") ?? -1
        if height == -1 { return false }
        switch heightLabel.text {
        case "cm":
            estimationParameter.heightInCm = height
        case "ft":
            estimationParameter.heightInCm = getFt(cm: heightTextField.text ?? "0" )
        default:
            return false
        }
        
        // weight
        let weight:Double = Double(weightTextField.text ?? "-1") ?? -1
        if weight == -1 { return false }
        switch weightLabel.text {
        case "kg":
            estimationParameter.weightInKg = weight
        case "lbs":
            estimationParameter.weightInKg = getPound(kg: weightTextField.text ?? "0" )
        default:
            return false
        }
        
        //extraData
        var jsonDic = Dictionary<String, Any>()
        jsonDic["extraId"] = Int(numberTextField.text ?? "-1")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDic)
            let jsonStr = String(bytes: jsonData, encoding: .utf8)!
            estimationParameter.extra = jsonStr
        } catch (let e) {
            print(e)
        }
        
        
        return true
    }
}

// MARK: - UserDefaults
extension CameraVersion2ViewController {
    
    
    /// init user Default
    func statusInit(){
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: ["HistoryHeight": 160])
        userDefaults.register(defaults: ["HistoryHeightUnit": "cm"])
        userDefaults.register(defaults: ["HistoryWeight": 60])
        userDefaults.register(defaults: ["HistoryWeightUnit": "kg"])
        userDefaults.register(defaults: ["HistoryAge": 20])
        userDefaults.register(defaults: ["HistoryGender": 0])
    }
    
    func statusSave(){
        let userDefaults = UserDefaults.standard
        let heigth     = Double(heightTextField.text ?? "-1")
        let heigthUnit = heightLabel.text
        let weight     = Double(weightTextField.text ?? "-1")
        let weightUnit = weightLabel.text?.description
        let age        = Int(ageTextField.text ?? "-1")
        let gender     = genderSegmented.selectedSegmentIndex

        userDefaults.set( heigth     , forKey: "HistoryHeight")
        userDefaults.set( heigthUnit , forKey: "HistoryHeightUnit")
        userDefaults.set( weight     , forKey: "HistoryWeight")
        userDefaults.set( weightUnit , forKey: "HistoryWeightUnit")
        userDefaults.set( age        , forKey: "HistoryAge")
        userDefaults.set( gender     , forKey: "HistoryGender")

        userDefaults.synchronize()
        
    }
    
    func statusLoad(){
        let userDefaults = UserDefaults.standard
        
        let height     = userDefaults.object(forKey: "HistoryHeight") as! Double
        let heightUnit = userDefaults.object(forKey: "HistoryHeightUnit") as! String
        let weight     = userDefaults.object(forKey: "HistoryWeight") as! Double
        let weightUnit = userDefaults.object(forKey: "HistoryWeightUnit") as! String
        let age        = userDefaults.object(forKey: "HistoryAge") as! Int
        let gender     = userDefaults.object(forKey: "HistoryGender") as! Int
        
        heightLabel.text = heightUnit
        weightLabel.text = weightUnit
        
        if height != -1 {
            heightTextField.text = height.description
        }
        
        if weight != -1 {
            weightTextField.text = weight.description
        }
        if age != -1{
            ageTextField.text = age.description
        }
        
        switch gender {
        case 1:
            estimationParameter.gender = .female
        default:
            estimationParameter.gender = .male
        }
        
    }
    
}


// MARK: - UITextField's
extension CameraVersion2ViewController: UITextFieldDelegate{
    
    func createToolber() {
        createHeightToolber()
        createWeightToolber()
        createOkToolber(textField: ageTextField)
        createOkToolber(textField: numberTextField)
    }
    
    func createHeightToolber() {
        let toolBar = UIToolbar()
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                           target: nil,
                                           action: nil)
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                    target: nil,
                                    action: nil)
        space.width = 10
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60 , height: 20))
        label.text = "Select. Unit"
        let labelItem = UIBarButtonItem(customView: label)
        
        let okButton = UIBarButtonItem(barButtonSystemItem: .done,
                                       target: self,
                                       action: #selector(tapOkButton(_:)))
        
        let lbsButton = UIBarButtonItem(title: "ft",
                                        style: .plain,
                                        target: self,
                                        action: #selector(tapFtButton(_:)))
        
        let kgButton = UIBarButtonItem(title: "cm",
                                       style: .plain,
                                       target: self,
                                       action: #selector(tapCmButton(_:)))
        
        toolBar.setItems([labelItem,space,
                          kgButton,lbsButton,
                          flexibleItem,
                          okButton],animated: true)
        
        toolBar.sizeToFit()
        heightTextField.delegate = self
        heightTextField.inputAccessoryView = toolBar
    }
    
    // ボタンを押したときのメソッド
    @objc func tapOkButton(_ sender: UIButton){
        self.view.endEditing(true)
    }
    @objc func tapCmButton(_ sender: UIButton){
        heightLabel.text = "cm"
    }
    @objc func tapFtButton(_ sender: UIButton){
        heightLabel.text = "ft"
    }
    
    func createWeightToolber() {
        let toolBar = UIToolbar()
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                           target: nil,
                                           action: nil)
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                    target: nil,
                                    action: nil)
        space.width = 10
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60 , height: 20))
        label.text = "Select. Unit"
        let labelItem = UIBarButtonItem(customView: label)
        
        let okButton = UIBarButtonItem(barButtonSystemItem: .done,
                                       target: self,
                                       action: #selector(tapOkButton(_:)))
        
        let lbsButton = UIBarButtonItem(title: "kg",
                                        style: .plain,
                                        target: self,
                                        action: #selector(tapKgButton(_:)))
        
        let kgButton = UIBarButtonItem(title: "lbs",
                                       style: .plain,
                                       target: self,
                                       action: #selector(tapLbsButton(_:)))
        
        toolBar.setItems([labelItem,space,
                          kgButton,lbsButton,
                          flexibleItem,
                          okButton],animated: true)
        
        toolBar.sizeToFit()
        weightTextField.delegate = self
        weightTextField.inputAccessoryView = toolBar
    }
    
    // ボタンを押したときのメソッド
    @objc func tapKgButton(_ sender: UIButton){
        weightLabel.text = "kg"
    }
    @objc func tapLbsButton(_ sender: UIButton){
        weightLabel.text = "lbs"
    }
    
    func createOkToolber(textField: UITextField) {
        let toolBar = UIToolbar()
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                           target: nil,
                                           action: nil)
        
        let okButton = UIBarButtonItem(barButtonSystemItem: .done,
                                       target: self,
                                       action: #selector(tapOkButton(_:)))
        
        toolBar.setItems([flexibleItem,okButton],animated: true)
        
        toolBar.sizeToFit()
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
}

// MARK: - Change Unit
extension CameraVersion2ViewController {
    
    // input Parameter
    private func getFt(cm: String) -> Double{
        let cmPerFeet = 30.48
        let cmPerInch = cmPerFeet / 12.0
        let feet_inch = cm.split(separator: ".")
        let feet = Double(feet_inch[0])!
        let inch: Double = {
            if feet_inch.count <= 1 {
                return 0
            }
            else {
                return Double( feet_inch[1] )!
            }
        }()
        
        let feetsInCm = feet * cmPerFeet
        let inchesInCm = inch * cmPerInch
        return feetsInCm + inchesInCm
    }
    
    private func getPound(kg: String) -> Double{
        let pound_oz = kg.split(separator: ".")
        let pound = Double(pound_oz[0])!
        let oz: Double = {
            if pound_oz.count <= 1 {
                return 0
            }
            else {
                return Double( pound_oz[1] )!
            }
        }()
        
        let kgPerPound = 0.4535924
        let ozPerPound = kgPerPound / 12.0
        let kg = pound * kgPerPound + oz * ozPerPound
        return kg
    }
}
