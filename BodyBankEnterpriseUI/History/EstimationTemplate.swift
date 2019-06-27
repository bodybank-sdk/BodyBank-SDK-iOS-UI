//
//  File.swift
//  AFDateHelper
//
//  Created by Masashi Horita on 2019/06/27.
//

import Foundation

///An estimation result representation
struct EstimationTemplate{
    var height:Double
    var weight:Double
    var age:Double

    var bicepCircumference: Double
    var calfCircumference: Double
    var chestCircumference: Double
    var hipCircumference: Double
    var highHipCircumference: Double
    var neckCircumference: Double
    var shoulderWidth: Double
    var sleeveLength: Double
    var thighCircumference: Double
    var midThichCircumference: Double
    var kneeCircumference: Double
    var outseamLength: Double
    var inseamLength: Double
    var totalLength: Double
    var waistCircumference: Double
    var wristCircumference: Double
    var underBust: Double
    var backLength: Double
}

// 独自イニシャライザをextensionに記載
extension EstimationTemplate {
    
    enum TemplateName {
        case BG_Mannequin_Man
    }
    
    init(type: TemplateName) {
        
        switch type{
        case .BG_Mannequin_Man:
            self.height = 176
            self.weight = 65
            self.age = 25

            self.bicepCircumference = 27.4
            self.calfCircumference = 35.5
            self.chestCircumference = 94.9
            self.hipCircumference = 86.9
            self.highHipCircumference = 78.5
            
            self.neckCircumference = 38.8
            self.shoulderWidth = 47.8
            self.sleeveLength = 76.7
            self.thighCircumference = 52.5
            self.midThichCircumference = 48.7
            
            self.kneeCircumference = 40.2
            self.outseamLength = 105.5
            self.inseamLength = 78.9
            self.totalLength = 155.0
            self.waistCircumference = 73.5
            
            self.wristCircumference = 16
            self.underBust = 0
            self.backLength = 44.7
        }
    }
}
