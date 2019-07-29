//
//  UINavigationBar+BodyBank.swift
//  BodyBankEnterpriseUI
//
//  Created by Shunpei Kobayashi on 2018/12/12.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import UIKit

extension UINavigationBar{
    func setUpBodyBankGradient() -> UIImage?{
        let rect = CGRect(x: 0, y: -UIApplication.shared.statusBarFrame.height, width: UIApplication.shared.statusBarFrame.width, height: UIApplication.shared.statusBarFrame.height + frame.height)
        let layer = CAGradientLayer(frame: rect, colors: [
            UIColor.BodyBank.Gradient.blue,
            UIColor.BodyBank.Gradient.blue,
//            UIColor.BodyBank.Gradient.begin,
            UIColor.BodyBank.Gradient.end
            ], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
        if let image = layer.createGradientImage(){
            setBackgroundImage(image, for: .default)
            return image
        }else{
            return nil
        }
    }
}
