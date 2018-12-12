//
//  BodyBankEnterpriseUI+Camera.swift
//  BodyBankEnterpriseUI
//
//  Created by Shunpei Kobayashi on 2018/12/12.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import BodyBankEnterprise
import UIKit

public extension BodyBankEnterprise{
    public class CameraUI{
        static var bundle: Bundle?{
            get{
                let podBundle = Bundle(for: self)
                if let path = podBundle.path(forResource: "BodyBankEnterpriseUI-Camera", ofType: "bundle"){
                    let bundle = Bundle(path: path)
                    return bundle
                }else{
                    return nil
                }
            }
        }
        public static func show(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) -> CameraViewController?{
            if let bundle = bundle{
                let storyboard = UIStoryboard(name: "Camera", bundle: bundle)
                if let nav = storyboard.instantiateInitialViewController() as? UINavigationController{
                    viewController.present(nav, animated: animated, completion: completion)
                    return nav.viewControllers.first as? CameraViewController
                }else{
                    return nil
                }
            }else{
                return nil
            }
            
        }
    }
}
