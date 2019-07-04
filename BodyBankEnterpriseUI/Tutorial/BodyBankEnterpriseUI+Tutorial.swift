//
//  BodyBankEnterpriseUI+Tutorial.swift
//  BodyBankEnterpriseUI
//
//  Created by Shunpei Kobayashi on 2018/12/12.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import BodyBankEnterprise
import UIKit

public extension BodyBankEnterprise{
    public class TutorialUI{
        
        static var bundle: Bundle?{
            get{
                let podBundle = Bundle(for: self)
                if let path = podBundle.path(forResource: "BodyBankEnterpriseUI-Tutorial", ofType: "bundle"){
                    let bundle = Bundle(path: path)
                    return bundle
                }else{
                    return podBundle
                }
            }
        }
        
        
        /// viewController の上にNavigationControllerを読み込む
        ///
        /// - Parameters:
        ///   - viewController: <#viewController description#>
        ///   - animated: <#animated description#>
        ///   - completion: <#completion description#>
        /// - Returns: <#return value description#>
        public static func show(on viewController: UIViewController,
                                animated: Bool,
                                completion: (() -> Void)?) -> TutorialViewController?
        {
            guard let bundle = bundle else { return nil }

            let storyboard = UIStoryboard(name: "Tutorial", bundle: bundle)
            guard let nav = storyboard.instantiateInitialViewController() as? UINavigationController else { return nil }

            viewController.present(nav, animated: animated, completion: completion)
            return nav.viewControllers.first as? TutorialViewController
        }
        
    }
}
