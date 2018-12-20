//
//  UINavigationBar+Gradation.swift
//  BodyBank-Showcase
//
//  Created by Shunpei Kobayashi on 2018/11/18.
//  Copyright © 2018 Shunpei Kobayashi. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func setGradientBackground(colors: [UIColor]) {
        
        var updatedFrame = bounds
        updatedFrame.size.height += self.frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
        
        setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
}
