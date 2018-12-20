//
//  BlurFace.swift
//  BodyBank-Showcase
//
//  Created by Shunpei Kobayashi on 2018/11/20.
//  Copyright © 2018 Shunpei Kobayashi. All rights reserved.
//

import UIKit
import CoreImage

public class BlurFace {
    
    private let ciDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil ,options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])!
    
    private var ciImage: CIImage!
    private var orientation: UIImage.Orientation = .up
    
    private var context = CIContext(options: nil) 
    
    // MARK: Initializers
    
    public init(image: UIImage) {
        setImage(image: image)
    }
    
    public func setImage(image: UIImage) {
        if let ciImage = CIImage(image: image){
            self.ciImage = ciImage
            orientation = image.imageOrientation
        }
    }
    
    // MARK: Public
    
    public func blurFaces(centerOffset: CGPoint?) -> UIImage? {
        let pixelateFiler = CIFilter(name: "CIPixellate")
        pixelateFiler?.setValue(ciImage, forKey: kCIInputImageKey)
        pixelateFiler?.setValue(max(ciImage!.extent.width, ciImage.extent.height) / 60.0, forKey: kCIInputScaleKey)
        
        var maskImage: CIImage?
        for feature in ciDetector.features(in: self.ciImage) {
            let centerX = feature.bounds.origin.x + feature.bounds.size.width / 2.0
            let centerY = feature.bounds.origin.y + feature.bounds.size.height / 2.0
            let radius = min(feature.bounds.size.width, feature.bounds.size.height) / 2
            
            let radialGradient = CIFilter(name: "CIRadialGradient")
            radialGradient?.setValue(radius, forKey: "inputRadius0")
            radialGradient?.setValue(radius + 1, forKey: "inputRadius1")
            radialGradient?.setValue(CIColor(red: 0, green: 1, blue: 0, alpha: 1), forKey: "inputColor0")
            radialGradient?.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: 0), forKey: "inputColor1")
            radialGradient?.setValue(CIVector(x: centerX, y: centerY), forKey: kCIInputCenterKey)
            
            let croppedImage = radialGradient?.outputImage?.cropped(to: ciImage.extent)
            
            let circleImage = croppedImage
            if (maskImage == nil) {
                maskImage = circleImage
            }
            else {
                let filter =  CIFilter(name: "CISourceOverCompositing")
                filter?.setValue(circleImage, forKey: kCIInputImageKey)
                filter?.setValue(maskImage, forKey: kCIInputBackgroundImageKey)
                
                maskImage = filter?.outputImage
            }
        }
        
        let composite = CIFilter(name: "CIBlendWithMask")
        composite?.setValue(pixelateFiler?.outputImage, forKey: kCIInputImageKey)
        composite?.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
        composite?.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        if let image = composite?.outputImage{
            if let cgImage = context.createCGImage(image, from: image.extent){
                return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
}
