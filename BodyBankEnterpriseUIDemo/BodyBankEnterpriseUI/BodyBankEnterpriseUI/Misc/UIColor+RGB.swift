//
//  UIColor+RGB.swift
//  MeasureBot
//
//  Created by Shunpei Kobayashi on 2018/04/22.
//  Copyright © 2018年 Original Stitch. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    /**
     Creates a UIColor object for the given rgb value which can be specified
     as HTML hex color value. For example:
     
     let color = UIColor(rgb: 0x8046A2)
     let colorWithAlpha = UIColor(rgb: 0x8046A2, alpha: 0.5)
     
     - parameter rgb: color value as Int. To be specified as hex literal like 0xff00ff
     - parameter alpha: alpha optional alpha value (default 1.0)
     */
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((rgb & 0xff0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00ff00) >>  8) / 255
        let b = CGFloat((rgb & 0x0000ff)      ) / 255
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
}
