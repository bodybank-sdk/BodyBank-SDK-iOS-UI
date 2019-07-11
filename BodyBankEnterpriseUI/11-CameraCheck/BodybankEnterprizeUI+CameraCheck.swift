//
//  BodybankEnterprizeUI+CameraCheck.swift
//  AFDateHelper
//
//  Created by Masashi Horita on 2019/07/11.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import BodyBankEnterprise
import UIKit

public extension BodyBankEnterprise{
    
    public class CameraCheckUI{
        static var bundle: Bundle?{
            get{
                let podBundle = Bundle(for: self)
                if let path = podBundle.path(forResource: "BodyBankEnterpriseUI-CameraCheck", ofType: "bundle"){
                    let bundle = Bundle(path: path)
                    return bundle
                }else{
                    return podBundle
                }
            }
        }
        
        public static func show(on viewController: UIViewController,
                                animated: Bool,
                                completion: (() -> Void)?) -> CameraViewController?{
            guard let bundle = bundle else { fatalError("NoBundle") }
            
            let storyboard = UIStoryboard(name: "CameraCheck", bundle: bundle)
           
            let view = storyboard.instantiateInitialViewController()
            viewController.navigationController?.present(nav, animated: animated, completion: completion)
            return nav.viewControllers.first as? CameraCheckViewController
            
        }
        
    }
}
