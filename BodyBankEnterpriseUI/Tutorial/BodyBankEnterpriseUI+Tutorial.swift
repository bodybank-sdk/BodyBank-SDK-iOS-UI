//
//  BodyBankEnterpriseUI+Tutorial.swift
//  BodyBankEnterpriseUI
//
//  Created by Shunpei Kobayashi on 2018/12/12.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import BodyBankEnterprise

public extension BodyBankEnterprise.UI{
    public class Tutorial{
        static var bundle: Bundle?{
            get{
                let podBundle = Bundle(for: self)
                return podBundle
            }
        }
        public static func show(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) -> TutorialViewController?{
            if let bundle = bundle{
                let storyboard = UIStoryboard(name: "Tutorial", bundle: bundle)
                if let nav = storyboard.instantiateInitialViewController() as? UINavigationController{
                    viewController.present(nav, animated: animated, completion: completion)
                    return nav.viewControllers.first as? TutorialViewController
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }
    }
}
