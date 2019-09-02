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
    class CameraUI{
        static var bundle: Bundle?{
            get{
                let podBundle = Bundle(for: self)
                if let path = podBundle.path(forResource: "BodyBankEnterpriseUI-Camera", ofType: "bundle"){
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

            let storyboard = UIStoryboard(name: "Camera", bundle: bundle)
            
            guard let nav = storyboard.instantiateInitialViewController() as? UINavigationController else { fatalError("NoUINavigationController") }
            viewController.present(nav, animated: animated, completion: completion)
            return nav.viewControllers.first as? CameraViewController

        }
        
        public static func showVersion2(on viewController: UIViewController,
                                        animated: Bool,
                                        completion: (() -> Void)?) -> CameraVersion2ViewController?{
            guard let bundle = bundle else { fatalError("NoSBundle") }
            
                let storyboard = UIStoryboard(name: "CameraVersion2", bundle: bundle)
                if let nav = storyboard.instantiateInitialViewController() as? UINavigationController{
                    viewController.present(nav, animated: animated, completion: completion)
                    return nav.viewControllers.first as? CameraVersion2ViewController
                }else{
                    return nil
                }
        }
    }
}
