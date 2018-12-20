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


public protocol ImagePageItemViewControllerDelegate: class{
    func imagePageViewController(viewControlelr: ImagePageItemViewController, requiresShowingImageFullScreenWithImageView imageView: UIImageView)
}
open class ImagePageItemViewController :UIViewController{
    open weak var delegate: ImagePageItemViewControllerDelegate?
    open var imageURL: URL?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        let rec = UITapGestureRecognizer(target: self, action: #selector(self.imageViewDidTap(sender:)))
        imageView.addGestureRecognizer(rec)
        activityIndicatorView.startAnimating()
        imageView.kf.setImage(with: imageURL, placeholder: nil, options: nil, progressBlock: nil) {[unowned self] (_, _, _, _) in
           self.activityIndicatorView.stopAnimating()
        }
    }
    
    @objc func imageViewDidTap(sender: Any){
       delegate?.imagePageViewController(viewControlelr: self, requiresShowingImageFullScreenWithImageView: imageView)
    }
}
