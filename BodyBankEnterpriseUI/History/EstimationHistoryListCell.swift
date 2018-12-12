//
//  EstimationResultCell.swift
//  Bodygram
//
//  Created by Shunpei Kobayashi on 2018/05/19.
//  Copyright © 2018年 Original Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import BodyBankEnterprise
import AFDateHelper
import Kingfisher

open class EstimationHistoryListCell: UITableViewCell {
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!

    open var request: EstimationRequest? {
        didSet {
            self.dateLabel.text = request?.createdAt?.toString(format: .custom("yyyy-MM-dd HH:mm:ss"))
            if let image = request?.frontImageThumb?.cachedImage{
                self.resultImageView.image = image
            }else{
                loading = true
                DispatchQueue.main.async{
                    self.resultImageView.kf.setImage(with: self.request?.frontImageThumb?.downloadableURL, placeholder: nil, options: nil, progressBlock: nil) {[unowned self] (image, error, cacheType, url) in
                        self.request?.frontImageThumb?.cachedImage = image
                        self.loading = false
                    }
                }
            }
            self.statusLabel.text = request?.status?.rawValue
        }
    }


    var loading = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                if self?.loading == true {
                    self?.activityIndicatorView.startAnimating()
                } else {
                    self?.activityIndicatorView.stopAnimating()
                }
            }

        }
    }
}
