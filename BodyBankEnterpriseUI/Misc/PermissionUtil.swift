//
//  PermissionUtil.swift
//  Bodybank
//
//  Created by skonb on 2017/05/12.
//  Copyright © 2017年 Original Inc.. All rights reserved.
//

import Foundation
import Photos
import AVFoundation

class PermissionUtil {
    
    static func isPhotoLibraryEnabled()->Bool{
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    static func isCameraEnabled() -> Bool{
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }
    
    static func checkPhotoLibraryPermission(_ viewController: UIViewController?, callback: ((Bool)->Void)?){
        
        switch(PHPhotoLibrary.authorizationStatus()){
        case .denied, .restricted:
            DispatchQueue.main.async{
                let ac = UIAlertController(title:  NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("Access to photo library is necessary for normal operation. Please allow access in device settings.", comment: ""), preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (action) in
                    if(UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)){
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                        callback?(true)
                    }else{
                        callback?(false)
                    }
                }))
                ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    callback?(false)
                }))
                viewController?.present(ac, animated: true, completion: nil)
            }
            break
        case .authorized:
            DispatchQueue.main.async{
                callback?(false)
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch(status){
                case .denied, .restricted, .notDetermined:
                    DispatchQueue.main.async{
                        let ac = UIAlertController(title: NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("Access to photo library is necessary for normal operation. Please allow access in device settings.", comment: ""), preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (action) in
                            if(UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)){
                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                                callback?(true)
                            }else{
                                callback?(false)
                            }
                        }))
                        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            callback?(false)
                        }))
                        viewController?.present(ac, animated: true, completion: nil)
                    }
                    break
                case .authorized:
                    DispatchQueue.main.async{
                        callback?(false)
                    }
                }
            })
            //Do nothing
            break
        }
    }
    
    static func checkCameraPermission(_ viewController: UIViewController?,callback: ((Bool) -> Void)?){
        switch(AVCaptureDevice.authorizationStatus(for: .video)){
        case .denied, .restricted:
            let ac = UIAlertController(title:  NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("Permission to access camera has not been given. This is necessary for normal operation. Please allow access in device settings.", comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (action) in
                if(UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)){
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    callback?(true)
                }else{
                    callback?(false)
                }
            }))
            ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                callback?(false)
            }))
            DispatchQueue.main.async{
                viewController?.present(ac, animated: true, completion: nil)
            }
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (authorized) in
                DispatchQueue.main.async{
                    if authorized{
                        callback?(false)
                    }else{
                        let ac = UIAlertController(title:  NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("Permission to access camera has not been given. This is necessary for normal operation. Please allow access in device settings.", comment: ""), preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (action) in
                            if(UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)){
                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                            callback?(true)
                        }else{
                            callback?(false)
                            }
                        }))
                        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                            callback?(false)
                        }))
                        viewController?.present(ac, animated: true, completion: nil)
                    }
                }
            })
        case .authorized:
            DispatchQueue.main.async{
                callback?(false)
            }
            //Do nothing
            break
        }
    }
}
