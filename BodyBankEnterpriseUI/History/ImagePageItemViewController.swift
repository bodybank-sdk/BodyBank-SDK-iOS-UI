//
//  ImagePageItemViewController.swift
//  BodyBankEnterpriseUI
//
//  Created by Shunpei Kobayashi on 2018/12/12.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import UIKit
import Kingfisher
import NVActivityIndicatorView
import BodyBankEnterprise


public protocol ImagePageItemViewControllerDelegate: class{
    func imagePageViewController(viewControlelr: ImagePageItemViewController,
                                 requiresShowingImageFullScreenWithImageView imageView: UIImageView)
}

open class ImagePageItemViewController :UIViewController{
    
    public enum ImageDir {
        case front
        case side
    }
    
    open weak var delegate: ImagePageItemViewControllerDelegate?
    var imageURL: URL?
    var requestId: String?
    var imageUserId: String?
    var imageUserIdDir: BodyBankEnterprise.EstimationImageType?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        let rec = UITapGestureRecognizer(target: self,
                                         action: #selector(self.imageViewDidTap(sender:)))
        imageView.addGestureRecognizer(rec)
        loadImage()
    }
    
    @objc func imageViewDidTap(sender: Any){
        delegate?.imagePageViewController(viewControlelr: self,
                                          requiresShowingImageFullScreenWithImageView: imageView)
    }
    
    
    open func setURL(url:URL?){
        resetImageUrl()
        imageURL = url
    }
    
    open func setUserId(id: String?, dir: BodyBankEnterprise.EstimationImageType){
        resetImageUrl()
        imageUserId = id
        imageUserIdDir = dir
    }
    
    
    private func resetImageUrl(){
        imageURL = nil
        requestId = nil
        imageUserId = nil
        imageUserIdDir = nil
    }
    
    /// if url changed. use this function
    open func loadImage(){
        activityIndicatorView.startAnimating()
        
        if let image = imageURL{
            print("[i]:\(image.absoluteString)")
            imageView.kf.setImage(
                with: imageURL,
                placeholder: nil,
                options: nil,
                progressBlock: nil) {[weak self] (_, _, _, _) in
                    if let aiv = self?.activityIndicatorView {
                        aiv.stopAnimating()
                    }
            }
        } else if
            let id = imageUserId,
            let dir = imageUserIdDir
        {
            do {
                let success = try! BodyBankEnterprise.getS3Image(requestId: id,
                                                                 dir: dir,
                                                                 completion: { url in
                                                                    self.imageView.kf.setImage(
                                                                        with: url,
                                                                        placeholder: nil,
                                                                        options: nil,
                                                                        progressBlock: nil) {[weak self] (_, _, _, _) in
                                                                            if let aiv = self?.activityIndicatorView {
                                                                                aiv.stopAnimating()
                                                                            }
                                                                    }
                })
                
                if !success {
                    activityIndicatorView.stopAnimating()
                    if let bundle = BodyBankEnterprise.HistoryUI.bundle{
                        imageView.image = UIImage(named: "250x250",
                                                  in: bundle,
                                                  compatibleWith: nil)
                    }
                }
            }
        } else {
            activityIndicatorView.stopAnimating()
            print("[i]:\noImage")
        }
        
    }
}
