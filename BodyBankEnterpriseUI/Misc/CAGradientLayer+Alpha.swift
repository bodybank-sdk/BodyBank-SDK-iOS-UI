//
//  CAGradientLayer+Alpha.swift
//  BodyBank-Showcase
//
//  Created by Shunpei Kobayashi on 2018/11/18.
//  Copyright © 2018 Shunpei Kobayashi. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor], startPoint: CGPoint = CGPoint.zero, endPoint: CGPoint = CGPoint(x: 0, y: 1)) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    func createGradientImage() -> UIImage? {
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}
