//
//  EstimationHistoryViewController.swift
//  Bodygram
//
//  Created by Shunpei Kobayashi on 2018/05/19.
//  Copyright © 2018年 Original Inc. All rights reserved.
//

import UIKit
import SimpleImageViewerNew
import BodyBankEnterprise
import AFDateHelper
import SCPageViewController

public protocol EstimationHistoryViewControllerDelegate: class{
    func estimationzHistoryViewControllerDidFinish(viewController: EstimationHistoryViewController)
    func estimationzHistoryViewControllerDidCancel(viewController: EstimationHistoryViewController)
}

public struct ResultEntry {
    let name: String
    let template: Any
    let value: Any
    let unit: String?
}


open class EstimationHistoryViewController: UITableViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    var pageViewController: SCPageViewController!
    var navigationBarBackgroundImage: UIImage?
    var entries = [ResultEntry]()
    
    private let bundle = BodyBankEnterprise.HistoryUI.bundle
    
    open weak var delegate: EstimationHistoryViewControllerDelegate?
    open var lengthUnit = "cm"
    open var massUnit = "kg"
    open var request: EstimationRequest!{
        didSet{
            updateAppearances()
        }
    }
    
    var estimationTemplate = EstimationTemplate.init(type: .BG_Mannequin_Man)
    open var isDoneButtonShown = false{
        didSet{
            updateDoneButtonAppearance()
        }
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
        if let index = navigationController?.viewControllers.index(of: self), index > 0{
            //pushed from list
            navigationItem.leftBarButtonItem = nil
        }
        isDoneButtonShown = false
        
        buildGradientLayer()
    }
    
    // MARK: - UIAction
    
    @IBAction func doneButtonDoidTap(_ sender: UIBarButtonItem) {
        delegate?.estimationzHistoryViewControllerDidFinish(viewController: self)
    }
    
    @IBAction func cancelButtonDidTap(sender: Any){
        delegate?.estimationzHistoryViewControllerDidCancel(viewController: self)
    }
    
    @IBAction func pageControlValueDidChange(sender: UIPageControl){
        let currentPage = pageViewController.currentPage
        let nextPage = pageControl.currentPage
        pageViewController.movePage(at: currentPage,
                                    to: UInt(nextPage),
                                    animated: true,
                                    completion: {[weak self] in
                                        guard let self = self else { return }
                                        self.pageControl.currentPage = nextPage
        })
    }
    
    // MARK: - Other
    
    func updateDoneButtonAppearance(){
        if isDoneButtonShown{
            navigationItem.rightBarButtonItem = doneButton
        }else{
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func updateAppearances(){
        guard let request = request else { return }
        entries.removeAll()
        entries.append(contentsOf: [
            ResultEntry(name: "Height", template: estimationTemplate.height, value: request.height ?? 0, unit: lengthUnit),
            ResultEntry(name: "Weight", template: estimationTemplate.weight, value: request.weight ?? 0, unit: massUnit),
            ResultEntry(name: "Age"    , template: 0, value: request.age ?? 0, unit: nil),
            ResultEntry(name: "Gender", template: 0, value: request.gender! , unit: nil)
            ])
        
        if let result = request.result{
            entries.append(contentsOf: [
                ResultEntry(name: "Neck", template: estimationTemplate.neckCircumference, value: result.neckCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Shoulder", template: estimationTemplate.shoulderWidth, value: result.shoulderWidth ?? 0, unit: lengthUnit),
                ResultEntry(name: "Sleeve", template: estimationTemplate.sleeveLength, value: result.sleeveLength ?? 0, unit: lengthUnit),
                ResultEntry(name: "Bicep", template: estimationTemplate.bicepCircumference, value: result.bicepCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Wrist", template: estimationTemplate.wristCircumference, value: result.wristCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Chest", template: estimationTemplate.chestCircumference, value: result.chestCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Under Bust", template: estimationTemplate.underBust, value: result.underBust ?? 0, unit: lengthUnit),
                ResultEntry(name: "Waist", template: estimationTemplate.waistCircumference, value: result.waistCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "High Hip", template: estimationTemplate.highHipCircumference, value: result.highHipCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Hip", template: estimationTemplate.hipCircumference, value: result.hipCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Thigh", template: estimationTemplate.thighCircumference, value: result.thighCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Mid Thigh", template: estimationTemplate.midThichCircumference, value: result.midThichCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Knee", template: estimationTemplate.kneeCircumference, value: result.kneeCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Calf", template: estimationTemplate.calfCircumference, value: result.calfCircumference ?? 0, unit: lengthUnit),
                ResultEntry(name: "Inseam", template: estimationTemplate.inseamLength, value: result.inseamLength ?? 0, unit: lengthUnit),
                ResultEntry(name: "Out seam", template: estimationTemplate.outseamLength, value: result.outseamLength ?? 0, unit: lengthUnit),
                ResultEntry(name: "Total Length", template: estimationTemplate.totalLength, value: result.totalLength ?? 0, unit: lengthUnit),
                ResultEntry(name: "Back Length", template: estimationTemplate.backLength, value: result.backLength ?? 0, unit: lengthUnit),
                ])
            
            let debugPassword = UserDefaults.standard.value(forKey: "debug_password") as? String
            if debugPassword  == "samplepassword" {
                entries.append(contentsOf: [
                    ResultEntry(name:request.id ?? "", template: 0, value: "" , unit: nil),
                ])
            }
            

        } else {
            if request.status == .failed {
                // For case status is 'failed' but there's no errorCode.
                let errorStr = request.errorCode != nil ? request.errorCode! : "UNEXPECTED_ERROR"
                entries.append(ResultEntry(name: "Error",
                                           template: 0,
                                           value: NSLocalizedString(errorStr, comment: "Error returned from server."),
                                           unit: nil))
            }
        }
        
//        DispatchQueue.main.async{[unowned self] in
            self.tableView.reloadData()
            self.pageViewController.reloadData()
            if let createdAt = request.createdAt{
                self.title = createdAt.toString(format: .custom("yyyy-MM-dd HH:mm"))
            }
//        }
    }
    
    func buildGradientLayer(){
        if navigationBarBackgroundImage == nil{
            navigationBarBackgroundImage =  navigationController?.navigationBar.setUpBodyBankGradient()
        }
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed_pager"{
            pageViewController = segue.destination as? SCPageViewController
            let layouter = HistoryDetailImagePageLayouter()
            layouter.pagePercentage = 0.6
            pageViewController.setLayouter(layouter, animated: false, completion: nil)
            pageViewController.delegate = self
            pageViewController.dataSource = self
        }
    }
    
    
    func pageForViewController(viewController: UIViewController?) -> Int?{
        guard let vc = viewController as? ImagePageItemViewController else { return nil }
        switch vc.restorationIdentifier{
        case "image1":
            return 0
        case "image2":
            return 1
        case "front":
            return 2
        case "side":
            return 3
            
        default:
            return nil
        }
    }
    
}

// MARK: - Tableview Delegate and Tableview Datasources
extension EstimationHistoryViewController {
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell",
                                                 for: indexPath) as! EstimationHistoryResultEntryCell
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? EstimationHistoryResultEntryCell else { return }
        
        let entry = entries[indexPath.row]
        cell.name = entry.name
        if let doubleValue = entry.value as? Double{
            cell.setValueAndUnit(value: doubleValue, unit: entry.unit)
        } else if let intValue = entry.value as? Int{
            cell.setValueAndUnit(value: intValue, unit: entry.unit)
        } else if let strValue = entry.value as? String {
            cell.setValueAndUnit(value: strValue, unit: entry.unit)
        } else if let genValue = entry.value as? Gender {
            let genStr = genValue.rawValue
            cell.setValueAndUnit(value: genStr, unit: entry.unit)
        }
    }
}


extension EstimationHistoryViewController: ImagePageItemViewControllerDelegate{
    
    public func imagePageViewController(viewControlelr: ImagePageItemViewController,
                                        requiresShowingImageFullScreenWithImageView imageView: UIImageView) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = imageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        self.present(imageViewerController, animated: true)
    }
}


extension EstimationHistoryViewController: SCPageViewControllerDataSource{
    public func numberOfPages(in pageViewController: SCPageViewController!) -> UInt {
        guard let _ = request else {
            pageControl.numberOfPages = 0
            return 0
        }
        
        pageControl.numberOfPages = 4
        return 4
    }
    
    public func pageViewController(_ pageViewController: SCPageViewController!,
                                   viewControllerForPageAt pageIndex: UInt) -> UIViewController! {
        return viewControllerForPage(page: Int(pageIndex))!
    }
    
    private func viewControllerForPage(page: Int) -> ImagePageItemViewController?{
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ImagePageItem") as? ImagePageItemViewController else { return nil }
        
        switch page {
        case 0:
            vc.imageURL = request.frontImage?.downloadableURL
            vc.restorationIdentifier = "image1"
        case 1:
            vc.imageURL = request.sideImage?.downloadableURL
            vc.restorationIdentifier = "image2"
        case 2:
            vc.setUserId(id: request.id, dir: .annotated_front)
            vc.restorationIdentifier = "front"
        case 3:
            vc.setUserId(id: request.id, dir: .annotated_side)
            vc.restorationIdentifier = "side"
        default:
            return nil
        }
        
        vc.delegate = self
        return vc
    }
    
    public func initialPage(in pageViewController: SCPageViewController!) -> UInt {
        return 0
    }
    
}

extension EstimationHistoryViewController: SCPageViewControllerDelegate{
    public func pageViewController(_ pageViewController: SCPageViewController!,
                                   didNavigateToPageAt pageIndex: UInt) {
        pageControl.currentPage = Int(pageIndex)
    }
}

