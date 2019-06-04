//
//  CustomCarouselModal.swift
//  BodyBank-Showcase
//
//  Created by 石戸朋哲 on 2019/05/24.
//  Copyright © 2019 Shunpei Kobayashi. All rights reserved.
//

import UIKit

enum CustomCarouselModalError: Error {
  case noContents
  case failedToInitModalPageVc
}

class CustomCarouselModal: UIViewController {
  // arguments
  var modalTitle: String?
  var images: [UIImage]?
  var descriptions: [String]?

  // ui elements
  var overlayView = UIView()
  var headerView = UIView()
  var headerLabel = UILabel()
  var closeButton = UIButton()
  var closeIconImage = UIImage(named: "close-icon")
  var modalPageVC: ModalPageViewController?
  
  // ui settings
  var modalPageViewWidth: CGFloat = 0.0
  var modalPageViewMaxWidth: CGFloat = 500.0
  var modalPageViewHeight: CGFloat = 0.0
  var modalPageViewMaxHeight: CGFloat = 600.0
  
  var headerViewHeight: CGFloat = 40.0
  
  var closeIconWidth: CGFloat = 0.0
  var closeIconHeight: CGFloat = 0.0
  
  // Initializer
  public convenience init(title: String, images: [UIImage], descriptions: [String]) throws {
    self.init(nibName: nil, bundle: nil)
    
    self.modalTitle = title
    self.images = images
    self.descriptions = descriptions
    
    do {
      self.modalPageVC = try ModalPageViewController(images: self.images, descriptions: self.descriptions)
    } catch {
      throw CustomCarouselModalError.failedToInitModalPageVc
    }
    
    self.modalPresentationStyle = .overFullScreen
    self.modalTransitionStyle = .crossDissolve
  }
  
  override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setIdentifiers()
    self.layoutView(self.presentingViewController)
  }
  
  private func setIdentifiers() {
    self.overlayView.accessibilityIdentifier = "overlayView"
    self.headerView.accessibilityIdentifier = "headerView"
  }
  
  private func layoutView(_ presenting: UIViewController?) {
    self.setUpUiComponents()
    self.addSubviews()
    self.setUpConstraints()
  }
  
  private func setUpUiComponents() {
    // Set OverlayView
    overlayView.frame = self.view.frame
    overlayView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.5)
    
    // Set ModalPageView
    let widthExceedsMax = overlayView.frame.width * 0.8 > modalPageViewMaxWidth
    modalPageViewWidth = widthExceedsMax ? modalPageViewMaxWidth : overlayView.frame.width * 0.8
    let heightExceedsMax = overlayView.frame.height * (modalPageViewWidth / overlayView.frame.width) > modalPageViewMaxHeight
    modalPageViewHeight = heightExceedsMax ? modalPageViewMaxHeight : overlayView.frame.height * (modalPageViewWidth / overlayView.frame.width)
    modalPageVC!.view.backgroundColor = UIColor(red:239/255, green:240/255, blue:242/255, alpha:1.0)
    
    // Set HeaderView
    headerView.backgroundColor = .white
    
    // Set HeaderLabel
    headerLabel.text = modalTitle
    headerLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    headerLabel.numberOfLines = 0
    headerLabel.textAlignment = .center
    headerLabel.textColor = .black
    headerLabel.sizeToFit()
    headerLabel.frame = CGRect(x: 0.0, y: (headerViewHeight - headerLabel.frame.height) / 2, width: modalPageViewWidth, height: headerLabel.frame.height)
    
    closeIconWidth = closeIconImage!.size.width * 0.7
    closeIconHeight = closeIconImage!.size.height * 0.7
    closeButton.setImage(closeIconImage, for: .normal)
    closeButton.backgroundColor = .clear
    closeButton.isEnabled = true
    closeButton.addTarget(self, action: #selector(self.closeButtonTapped(_:)), for: .touchUpInside)
  }
  
  private func addSubviews() {
    self.view.addSubview(overlayView)
    
    overlayView.addSubview(modalPageVC!.view)
    overlayView.addSubview(headerView)

    headerView.addSubview(headerLabel)
    headerView.addSubview(closeButton)
  }
  
  private func setUpConstraints() {
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    modalPageVC!.view.translatesAutoresizingMaskIntoConstraints = false
    headerView.translatesAutoresizingMaskIntoConstraints = false
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    
    // self.view
    let overlayViewTopSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
    let overlayViewRightSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
    let overlayViewLeftSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
    let overlayViewBottomSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
    self.view.addConstraints([overlayViewTopSpaceConstraint, overlayViewRightSpaceConstraint, overlayViewLeftSpaceConstraint, overlayViewBottomSpaceConstraint])
    
    // overlayView
    let modalPageViewCenterXConstraint = NSLayoutConstraint(item: modalPageVC!.view, attribute: .centerX, relatedBy: .equal, toItem: overlayView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    let modalPageViewCenterYConstraint = NSLayoutConstraint(item: modalPageVC!.view, attribute: .centerY, relatedBy: .equal, toItem: overlayView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    let headerViewTopSpaceConstraint = NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: modalPageVC!.view, attribute: .top, multiplier: 1.0, constant: 0.0)
    let headerViewCenterXConstraint = NSLayoutConstraint(item: headerView, attribute: .centerX, relatedBy: .equal, toItem: modalPageVC!.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    overlayView.addConstraints([modalPageViewCenterXConstraint, modalPageViewCenterYConstraint, headerViewTopSpaceConstraint, headerViewCenterXConstraint])
    
    // modalPageView
    let modalPageViewWidthConstraint = NSLayoutConstraint(item: modalPageVC!.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: modalPageViewWidth)
    let modalPageViewHeightConstraint = NSLayoutConstraint(item: modalPageVC!.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: modalPageViewHeight)
    modalPageVC!.view.addConstraints([modalPageViewWidthConstraint, modalPageViewHeightConstraint])
    
    // headerView
    let headerViewWidthConstraint = NSLayoutConstraint(item: headerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: modalPageViewWidth)
    let headerViewHeightConstraint = NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: headerViewHeight)
    headerView.addConstraints([headerViewWidthConstraint, headerViewHeightConstraint])
    
    closeButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10).isActive = true
    closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: closeIconWidth).isActive = true
    closeButton.heightAnchor.constraint(equalToConstant: closeIconHeight).isActive = true
  }
  
  @objc private func closeButtonTapped(_ sender: UIButton) {
    sender.isSelected = true

    self.dismiss(animated: true) {
      
    }
  }
}

extension CustomCarouselModal {
  public func show(_ presenting: UIViewController) {
    presenting.present(self, animated: true)
  }
}

class ContentViewController: UIViewController {
  // arguments
  var image: UIImage?
  var imageDescription: String?
  
  var verticalMargin: CGFloat = 10

  // Initializer
  public convenience init(image: UIImage, message: String) {
    self.init(nibName: nil, bundle: nil)
    
    self.image = image
    self.imageDescription = message
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.view.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
    
    let imageView = UIImageView()
    let descriptionLabel = UILabel()
    
    imageView.image = self.image
    imageView.backgroundColor = .clear
    imageView.contentMode = .scaleAspectFit
    
    descriptionLabel.text = self.imageDescription
    descriptionLabel.numberOfLines = 2
//    descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    descriptionLabel.adjustsFontSizeToFitWidth = true
    descriptionLabel.textAlignment = .center
    descriptionLabel.sizeToFit()
    
    self.view.addSubview(imageView)
    self.view.addSubview(descriptionLabel)

    imageView.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    
    let imageViewBottomConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: descriptionLabel, attribute: .top, multiplier: 1.0, constant: -verticalMargin)
    self.view.addConstraint(imageViewBottomConstraint)

    imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40 + verticalMargin).isActive = true
    imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true

    descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabel.frame.height).isActive = true
    descriptionLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50 - verticalMargin).isActive = true
    descriptionLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    descriptionLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
    descriptionLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
}

enum ModalPageVCError: Error {
  case noContents
  case unmatchedContentsCount
}

class ModalPageViewController: UIPageViewController, UIPageViewControllerDataSource {
  var pages = [UIViewController]()
  let pageControl = UIPageControl()
  
  let pageControlHeight: CGFloat = 50.0
  
  var images: [UIImage]?
  var descriptions: [String]?

  init(images: [UIImage]?, descriptions: [String]?) throws {
    super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    guard let images = images else { throw ModalPageVCError.noContents }
    guard let descriptions = descriptions else { throw ModalPageVCError.noContents }
    
    if images.count == 0 || descriptions.count == 0 {
      throw ModalPageVCError.noContents
    }
    
    if images.count != descriptions.count {
      throw ModalPageVCError.unmatchedContentsCount
    }
    
    self.images = images
    self.descriptions = descriptions
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.dataSource = self
    self.delegate = self

    let initialPage = 0

    self.pages = createPages(images: self.images!, descriptions: self.descriptions!)

    setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)

    // pageControl
    self.pageControl.frame = CGRect()
    self.pageControl.backgroundColor = .white
    self.pageControl.currentPageIndicatorTintColor = .black
    self.pageControl.pageIndicatorTintColor = .lightGray
    self.pageControl.numberOfPages = self.pages.count
    self.pageControl.currentPage = initialPage
    self.view.addSubview(self.pageControl)

    self.pageControl.translatesAutoresizingMaskIntoConstraints = false
    self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
    self.pageControl.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
    self.pageControl.heightAnchor.constraint(equalToConstant: pageControlHeight).isActive = true
    self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
  }
  
  func createPages(images: [UIImage], descriptions: [String]) -> [ContentViewController] {
    var pages: [ContentViewController] = []

    for (idx, image) in images.enumerated() {
      pages.append(ContentViewController(image: image, message: descriptions[idx]))
    }
    
    return pages
  }
}

extension ModalPageViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let viewControllerIndex = self.pages.index(of: viewController) {
      if viewControllerIndex < self.pages.count - 1 {
        // go to next page in array
        return self.pages[viewControllerIndex + 1]
      } else {
        // wrap to first page in array
        return self.pages.first
      }
    }

    return nil
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let viewControllerIndex = self.pages.index(of: viewController) {
      if viewControllerIndex == 0 {
        // wrap to last page in array
        return self.pages.last
      } else {
        // go to previous page in array
        return self.pages[viewControllerIndex - 1]
      }
    }

    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    // set the pageControl.currentPage to the index of the current viewController in pages
    if let viewControllers = pageViewController.viewControllers {
      if let viewControllerIndex = self.pages.index(of: viewControllers[0]) {
        self.pageControl.currentPage = viewControllerIndex
      }
    }
  }
}

