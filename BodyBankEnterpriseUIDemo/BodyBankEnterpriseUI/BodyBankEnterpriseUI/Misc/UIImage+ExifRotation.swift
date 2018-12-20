//
//  UIImage+ExifRotation.swift
//  MeasureBot
//
//  Created by Shunpei Kobayashi on 2018/05/05.
//  Copyright © 2018年 Original Stitch. All rights reserved.
//

import UIKit
import AVFoundation


extension UIImage{
    func normalized(videoOrientation: AVCaptureVideoOrientation) -> UIImage
    {
        var rotatedImage: UIImage!
        if videoOrientation == .landscapeRight{
            rotatedImage = self
        } else if videoOrientation == .landscapeLeft{
            rotatedImage = UIImage(cgImage: cgImage!, scale: scale, orientation: .down)
        }else{
            switch imageOrientation
            {
            case .right:
                rotatedImage = UIImage(cgImage: cgImage!, scale: scale, orientation: .down)
                
            case .down:
                rotatedImage = UIImage(cgImage: cgImage!, scale: scale, orientation: .left)
                
            case .left:
                rotatedImage = UIImage(cgImage: cgImage!, scale: scale, orientation: .up)
                
            default:
                rotatedImage = UIImage(cgImage: cgImage!, scale: scale, orientation: .right)
            }
        }
        
        return rotatedImage
    }
    
}
