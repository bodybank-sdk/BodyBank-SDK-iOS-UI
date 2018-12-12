//
//  UITextField+BottomBorder.swift
//  Bodygram
//
//  Created by Shunpei Kobayashi on 2018/05/18.
//  Copyright © 2018年 Original Inc. All rights reserved.
//

import UIKit

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}
