//
//  TutorialViewController.swift
//  BodyBank
//
//  Created by Shunpei Kobayashi on 2018/12/11.
//  Copyright © 2018 Original Inc. All rights reserved.
//

import UIKit

public protocol TutorialViewControllerDelegate: class {
    func tutorialViewControllerDidEnd(viewController: TutorialViewController)
}

open class TutorialViewController: UIViewController{
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    var gradientLayer: CALayer?
    open weak var delegate: TutorialViewControllerDelegate?
    var pageViewController: UIPageViewController!

    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buildGradientLayer()
    }

    func buildGradientLayer(){
        if gradientLayer  == nil{
            gradientLayer = CAGradientLayer(frame: bottomBar.bounds, colors: [
                UIColor.BodyBank.Gradient.begin,
                UIColor.BodyBank.Gradient.end
                ], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
            if let gradientLayer = gradientLayer{
                bottomBar.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
    }
    
    @IBAction func nextButtonDidTap(sender: Any){
        if let page = pageForViewController(viewController: pageViewController.viewControllers?.first){
            if page == 2{
                delegate?.tutorialViewControllerDidEnd(viewController: self)
            }else{
                let nextPage = page + 1
                if let viewController = viewControllerForPage(page: nextPage){
                    pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: {[unowned self] success -> Void in
                        self.updatePageTo(page: nextPage)
                    })
                }
            }
        }
    }
    
    @IBAction func pageControlDidChange(sender: Any){
        if let vc = viewControllerForPage(page: pageControl.currentPage){
            if let previousPage = pageForViewController(viewController: pageViewController.viewControllers?.first){
                pageViewController.setViewControllers([vc], direction: previousPage > pageControl.currentPage ? .reverse : .forward, animated: true, completion: nil)
            }
        }
    }
    
    func pageForViewController(viewController: UIViewController?) -> Int?{
        if let id = viewController?.restorationIdentifier{
            switch id{
            case "tutorial1":
                return 0
            case "tutorial2":
                return 1
            case "tutorial3":
                return 2
            default:
                 return nil
            }
        }else{
            return nil
        }
    }
    
    func viewControllerForPage(page: Int) -> UIViewController?{
        if page >= 0 && page < 3{
            return   storyboard?.instantiateViewController(withIdentifier: String(format: "tutorial%d", page + 1))
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
    
    func updatePageTo(page: Int){
        pageControl.currentPage = page
        nextButton.setTitle(NSLocalizedString(page == 2 ? "Start" : "Next", comment: ""), for: .normal)
    }

}

extension TutorialViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first{
            if let page = pageForViewController(viewController: currentViewController){
                updatePageTo(page: page)
            }
        }
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let page = pageForViewController(viewController: viewController){
            let nextPage = page + 1
            if let vc = viewControllerForPage(page: nextPage){
               pageControl.currentPage = nextPage
                return vc
            }else{
                return nil
            }
        }else{
            return nil
        }
   }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let page = pageForViewController(viewController: viewController){
            let nextpage = page - 1
            if let vc = viewControllerForPage(page: nextpage){
                pageControl.currentPage = nextpage
                return vc
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    
}
