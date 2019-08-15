//
//  EstimationHistoryShowcaseDetailTemplate.swift
//  BodyBank-Showcase
//
//  Created by Masashi Horita on 2019/06/28.
//  Copyright © 2019 Shunpei Kobayashi. All rights reserved.
//
import Foundation

///An estimation result representation
struct EstimationHistoryShowcaseDetailTemplate{
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
extension EstimationHistoryShowcaseDetailTemplate {
    
    enum TemplateName {
        case BG_Mannequin_Man
        case BG_Mannequin_Woman
        
        case BG_Yayasushi
        case BG_Kyohei
        case BG_Jin
        
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
        case .BG_Mannequin_Woman:
            self.height = 176
            self.weight = 52
            self.age = 25
            
            
            self.bicepCircumference = 21
            self.calfCircumference = 30.6
            self.chestCircumference = 84
            self.hipCircumference = 87.6
            self.highHipCircumference = 70
            
            self.neckCircumference = 33.7
            self.shoulderWidth = 43.8
            self.sleeveLength = 75.5
            self.thighCircumference = 47
            self.midThichCircumference = 42
            
            self.kneeCircumference = 31.8
            self.outseamLength = 109
            self.inseamLength = 79.8
            self.totalLength = 152.5
            self.waistCircumference = 61.6
            
            self.wristCircumference = 17.8
            self.underBust = 72.8
            self.backLength = 40.5
            
        case .BG_Yayasushi:
            self.height = 178
            self.weight = 68
            self.age = 25
            
            self.neckCircumference = 37
            self.shoulderWidth = 48
            self.sleeveLength = 83
            self.bicepCircumference = 27
            self.wristCircumference = 16.6
            self.chestCircumference = 92
            self.underBust = 0
            self.waistCircumference = 86
            self.highHipCircumference = 86
            self.hipCircumference = 99
            self.thighCircumference = 61.3
            self.midThichCircumference = 54
            self.kneeCircumference = 40
            self.calfCircumference = 39.4
            self.inseamLength = 79.5
            self.outseamLength = 101
            self.totalLength = 152
            self.backLength = 41
            
        case .BG_Kyohei:
            self.height = 162
            self.weight = 70
            self.age = 33
            
            self.neckCircumference = 40
            self.shoulderWidth = 46
            self.sleeveLength = 72.5
            self.bicepCircumference = 28
            self.wristCircumference = 17
            self.chestCircumference = 94
            self.underBust = 0
            self.waistCircumference = 85.5
            self.highHipCircumference = 84.3
            self.hipCircumference = 99.7
            self.thighCircumference = 59.1
            self.midThichCircumference = 53
            self.kneeCircumference = 38.5
            self.calfCircumference = 38.3
            self.inseamLength = 69
            
            self.outseamLength = 91
            self.totalLength = 138.5
            self.backLength = 44
        case .BG_Jin:
            
            self.height = 178
            self.weight = 75
            self.age = 30
            
            self.neckCircumference = 38.7
            self.shoulderWidth = 39.5
            self.sleeveLength = 84
            self.bicepCircumference = 29.8
            self.wristCircumference = 16
            self.chestCircumference = 101.5
            self.underBust = 0
            self.waistCircumference = 87
            self.highHipCircumference = 94
            self.hipCircumference = 100.6
            self.thighCircumference = 59
            self.midThichCircumference = 49
            self.kneeCircumference = 40.7
            self.calfCircumference = 38.3
            self.inseamLength = 82
            self.outseamLength = 100
            self.totalLength = 153
            self.backLength = 40
            
        }
    }
}
