//
//  UIImage+drawText.swift
//  AFDateHelper
//
//  Created by Masashi Horita on 2019/07/09.
//

import Foundation

extension UIImage {
    
    func drawText(text :String ,drawRect: CGRect) ->UIImage?
    {
        let font = UIFont.boldSystemFont(ofSize: 32)
        let imageRect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContext(self.size)

        self.draw(in: imageRect)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.green.cgColor)
        context.fill(drawRect)
        
        let textRect  = CGRect(x: 5, y: 5, width: self.size.width, height: self.size.height)
        
        let textStyle = NSMutableParagraphStyle.default.mutableCopy()
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
