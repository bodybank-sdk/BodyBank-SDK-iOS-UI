//
//  BodyBankEnterpriseUI+History.swift
//  BodyBankEnterpriseUI
//
//  Created by Shunpei Kobayashi on 2018/12/12.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import BodyBankEnterprise
import UIKit

public extension BodyBankEnterprise {
    public class HistoryUI{
        public static var bundle: Bundle?{
            get{
                let podBundle = Bundle(for: self)
                if let path = podBundle.path(forResource: "BodyBankEnterpriseUI-History", ofType: "bundle"){
                    let bundle = Bundle(path: path)
                    return bundle
                }else{
                    return podBundle
                }
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
        
        public static func showListVersion2(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) -> EstimationHistoryListViewController?{
            guard let bundle = bundle else { return nil }
            
            let storyboard = UIStoryboard(name: "HistoryVersion2", bundle: bundle)
            guard let nav = storyboard.instantiateInitialViewController() as? UINavigationController else { return nil }
            
            viewController.present(nav, animated: animated, completion: completion)
            return nav.viewControllers.first as? EstimationHistoryListViewController

        }
        
        public static func showDetailVersion2(on viewController: UIViewController,
                                              request: EstimationRequest,
                                              animated: Bool,
                                              completion: (() -> Void)?) -> EstimationHistoryViewController? {

            guard let bundle = bundle else { return nil }
            
            let storyboard = UIStoryboard(name: "HistoryVersion2", bundle: bundle)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "HistoryDetail") as? EstimationHistoryViewController else { return nil }

            let nav = UINavigationController(rootViewController: vc)
            viewController.present(nav, animated: animated, completion: completion)
            vc.request = request
            return vc
        }

    }
}
