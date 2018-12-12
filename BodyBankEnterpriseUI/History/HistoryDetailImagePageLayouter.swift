//
//  HistoryDetailImagePageLayouter.swift
//  BodyBankEnterpriseUI
//
//  Created by Shunpei Kobayashi on 2018/12/12.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import SCPageViewController
import UIKit

class HistoryDetailImagePageLayouter: SCCardsPageLayouter{
    override func contentInset(for pageViewController: SCPageViewController!) -> UIEdgeInsets {
        let frame = pageViewController.view.bounds;
        let horizontalInset = floor(frame.width - frame.width * self.pagePercentage);
        
        return UIEdgeInsets(top: 0, left: horizontalInset/2.0, bottom: 0, right: horizontalInset/2.0);
    }
    
    override func finalFrameForPage(at index: UInt, pageViewController: SCPageViewController!) -> CGRect {
        var frame = pageViewController.view.bounds;
        frame.size.height = frame.size.height * self.pagePercentage;
        frame.size.width = frame.size.width * self.pagePercentage;
        frame.origin.x = CGFloat(index) * (frame.width + self.interItemSpacing);
        frame.origin.y = 20

        return frame;
    }
}
