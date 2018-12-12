//
//  BodyBankEnterpriseUI+History.swift
//  BodyBankEnterpriseUI
//
//  Created by Shunpei Kobayashi on 2018/12/12.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import BodyBankEnterprise

public extension BodyBankEnterprise.UI{
    public class History{
        static var bundle: Bundle?{
            get{
                let podBundle = Bundle(for: self)
                return podBundle
            }
        }
        public static func showList(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) -> EstimationHistoryListViewController?{
            if let bundle = bundle{
                let storyboard = UIStoryboard(name: "History", bundle: bundle)
                if let nav = storyboard.instantiateInitialViewController() as? UINavigationController{
                    viewController.present(nav, animated: animated, completion: completion)
                    return nav.viewControllers.first as? EstimationHistoryListViewController
                }else{
                    return nil
                }
            }else{
                return nil
            }
            
        }
        
        public static func showDetail(on viewController: UIViewController, request: EstimationRequest, animated: Bool, completion: (() -> Void)?) -> EstimationHistoryViewController?{
            if let bundle = bundle{
                let storyboard = UIStoryboard(name: "History", bundle: bundle)
                if let vc = storyboard.instantiateViewController(withIdentifier: "HistoryDetail") as? EstimationHistoryViewController{
                    let nav = UINavigationController(rootViewController: vc)
                    viewController.present(nav, animated: animated, completion: completion)
                    vc.request = request
                    return vc
                }else{
                    return nil
                }
            }else{
                return nil
            }
            
        }
    }
}
