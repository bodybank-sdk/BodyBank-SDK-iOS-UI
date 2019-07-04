//
//  TutorialViewController.swift
//  BodyBank
//
//  Created by Shunpei Kobayashi on 2018/12/11.
//  Copyright © 2018 Original Inc. All rights reserved.
//
//  ＜1.チュートリアル画面＞
//  アプリの使い方の説明を行う画面
//  このサンプルでは
//  1.身長、体重、年齢が必要である旨の説明
//  2.端末の傾きと回転がの調整が必要である旨の説明。
//  3.前画面と横画面が必要である旨の説明を行なっている。

import UIKit

public protocol TutorialViewControllerDelegate: class {
    func tutorialViewControllerDidEnd(viewController: TutorialViewController)
}

open class TutorialViewController: UIViewController{
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    open weak var delegate: TutorialViewControllerDelegate?
    
    var gradientLayer: CALayer?
    var pageViewController: UIPageViewController!

    //MARK: - LifeCycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buildGradientLayer()
    }

    //MARK: - IBAction
    
    @IBAction func nextButtonDidTap(sender: Any){
        guard let page = pageForViewController(viewController: pageViewController.viewControllers?.first) else { return }

        if page == 2{
            delegate?.tutorialViewControllerDidEnd(viewController: self)
        }else{
            let nextPage = page + 1
            if let viewController = viewControllerForPage(page: nextPage){
                pageViewController.setViewControllers([viewController],
                                                      direction: .forward,
                                                      animated: true,
                                                      completion: {[weak self] success -> Void in
                    self?.updatePageTo(page: nextPage)
                })
            }
        }
        
    }
    
    //MARK: - Other
    
    func buildGradientLayer(){
        if gradientLayer  == nil{
            gradientLayer = CAGradientLayer(frame: bottomBar.bounds,
                                            colors: [ UIColor.BodyBank.Gradient.begin,
                                                      UIColor.BodyBank.Gradient.end],
                                            startPoint: CGPoint(x: 0, y: 0.5),
                                            endPoint: CGPoint(x: 1, y: 0.5))
            if let gradientLayer = gradientLayer{
                bottomBar.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
    }
    
    
    func viewControllerForPage(page: Int) -> UIViewController?{
        if page >= 0 && page < 3{
            return storyboard?.instantiateViewController(withIdentifier: String(format: "tutorial%d", page+1))
        }else{
            return nil
        }
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed_pager"{
            pageViewController = segue.destination as? UIPageViewController
            pageViewController.dataSource = self
            pageViewController.delegate = self
            pageViewController.setViewControllers([viewControllerForPage(page: 0)!], direction: .forward, animated: false, completion: nil)
        }
    }
}

extension TutorialViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    open func pageViewController(_ pageViewController: UIPageViewController,
                                 viewControllerAfter viewController: UIViewController) -> UIViewController? {
        updatePageTo(page: pageControl.currentPage+1)
        guard let page = pageForViewController(viewController: viewController) else { return nil }
        guard let vc = viewControllerForPage(page: page+1) else { return nil }
        return vc
   }
    
    
    open func pageViewController(_ pageViewController: UIPageViewController,
                                 viewControllerBefore viewController: UIViewController) -> UIViewController? {
        updatePageTo(page: pageControl.currentPage-1)
        guard let page = pageForViewController(viewController: viewController) else { return nil }
        guard let vc = viewControllerForPage(page: page-1) else { return nil }
        guard let beforePage = pageForViewController(viewController: vc) else { return nil }
        return vc
    }
    
    func pageForViewController(viewController: UIViewController?) -> Int?{
        guard let id = viewController?.restorationIdentifier else { return nil }
        switch id {
        case "tutorial1":  return 0
        case "tutorial2":  return 1
        case "tutorial3":  return 2
        default: return nil
        }
    }

    func updatePageTo(page: Int){
        pageControl.currentPage = page
        nextButton.setTitle(NSLocalizedString(page == 2 ? "Start" : "Next", comment: ""), for: .normal)
    }

}
