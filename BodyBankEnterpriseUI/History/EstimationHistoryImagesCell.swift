//
//  Estima?tionResultImagesCell.swift
//  Bodygram
//
//  Created by Shunpei Kobayashi on 2018/05/19.
//  Copyright © 2018年 Original Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import BodyBankEnterprise
import Kingfisher
import SimpleImageViewerNew

public protocol EstimationHistoryImageCellDelegate: class {
    func estimationHistoryImageCell(cell: EstimationHistoryImagesCell,
                                    requiresShowingFullImageUsing imageView: UIImageView,
                                    isFrontImage: Bool)
}

open class EstimationHistoryImagesCell: UITableViewCell {
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var frontActivityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var sideActivityIndicatorView: NVActivityIndicatorView!
    
    open weak var delegate: EstimationHistoryImageCellDelegate?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        frontImageView.isUserInteractionEnabled = true
        sideImageView.isUserInteractionEnabled = true
        let rec1 = UITapGestureRecognizer(target: self, action: #selector(self.frontImageDidTap(sender:)))
        frontImageView.addGestureRecognizer(rec1)
        let rec2 = UITapGestureRecognizer(target: self, action: #selector(self.sideImageDidTap(sender:)))
        sideImageView.addGestureRecognizer(rec2)
        
    }
    
    var request: EstimationRequest? {
        didSet {
            if let image = request?.frontImage?.cachedImage{
                self.frontImageView.image = image
            }else{
                frontActivityIndicatorView.startAnimating()
                DispatchQueue.global().async{[weak self] in
                    guard let self = self else { return }
                    self.frontImageView.kf.setImage(with: self.request?.frontImage?.downloadableURL,
                                                    placeholder: nil,
                                                    options: nil,
                                                    progressBlock: nil) {[weak self] (image, error, cacheType, url) in
                                                        guard let self = self else { return }
                                                        self.request?.frontImage?.cachedImage = image
                                                        self.frontActivityIndicatorView.stopAnimating()
                    }
                }
            }
            
            if let image = request?.sideImage?.cachedImage{
                self.sideImageView.image = image
            }else{
                sideActivityIndicatorView.startAnimating()
                DispatchQueue.global().async{[weak self] in
                    guard let self = self else { return }
                    self.sideImageView.kf.setImage(with: self.request?.sideImage?.downloadableURL,
                                                   placeholder: nil,
                                                   options: nil,
                                                   progressBlock: nil){[weak self] (image, error, cacheType, url) in
                                                    guard let self = self else { return }
                                                    self.request?.sideImage?.cachedImage = image
                                                    self.sideActivityIndicatorView.stopAnimating()
                    }
                }
            }
        }
    }
    
    @IBAction func frontImageDidTap(sender: Any) {
        delegate?.estimationHistoryImageCell(cell: self, requiresShowingFullImageUsing: frontImageView, isFrontImage: true)
    }
    
    
    @IBAction func sideImageDidTap(sender: Any) {
        delegate?.estimationHistoryImageCell(cell: self, requiresShowingFullImageUsing: sideImageView, isFrontImage: false)
    }
    
}
