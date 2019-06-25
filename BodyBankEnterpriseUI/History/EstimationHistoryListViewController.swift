//
//  EstimationHistoryListViewController.swift
//  Bodygram
//
//  Created by Shunpei Kobayashi on 2018/05/19.
//  Copyright © 2018年 Original Inc. All rights reserved.
//

import UIKit
import BodyBankEnterprise
import Alertift

public protocol EstimationHistoryListViewControllerDelegate: class{
    func estimationHistoryListViewController(viewController: EstimationHistoryListViewController,
                                             didSelectEstimationRequest estimationRequest: EstimationRequest,
                                             toShowDetailViewController detailViewController: EstimationHistoryViewController)
    
    func estimationHistoryListViewControllerDidFinish(viewController: EstimationHistoryListViewController)
}

open class EstimationHistoryListViewController: UITableViewController {
    open weak var delegate: EstimationHistoryListViewControllerDelegate?
    var requests = [EstimationRequest]()
    var nextToken: String?
    var shouldRefresh = false
    var loadingFinished = false
    var loading = false
    var navigationBarBackgroundImage: UIImage?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        let refresh = UIRefreshControl()
        tableView.refreshControl = refresh
        
        refresh.addTarget(self, action: #selector(self.refreshRequired(sender:)), for: .valueChanged)
        loadNext()
        
        buildGradientLayer()
    }
    
    @objc func refreshRequired(sender: Any){
        refresh()
    }
    
    func buildGradientLayer(){
        if navigationBarBackgroundImage == nil{
            navigationBarBackgroundImage =  navigationController?.navigationBar.setUpBodyBankGradient()
        }
    }
    
    func refresh(){
        shouldRefresh = true
        loadingFinished = false
        loadNext()
    }
    
    func loadNext() {
        if loading{ return }
        loading = true
        
        guard let _ = BodyBankEnterprise.defaultTokenProvider() else { return }
        
        let token = self.shouldRefresh ? nil : self.nextToken
        let limit = 20
        BodyBankEnterprise
            .listEstimationRequests(limit: limit,
                                    nextToken: token,
                                    callback: {[unowned self] (requests, nextToken, errors) in
                                        
                                        if let errors = errors{
                                            self.loading = false
                                            Alertift
                                                .alert(title: nil,
                                                       message: errors
                                                        .map({ (error) -> String in
                                                            error.localizedDescription
                                                        })
                                                        .joined(separator: "\n")
                                                )
                                                .action(.default("OK"))
                                                .show(on: self, completion: nil)
                                            return
                                        }
                                        
                                        self.nextToken = nextToken
                                        self.loadingFinished = requests?.count == 0
                                        DispatchQueue.main.async {
                                            self.tableView.beginUpdates()
                                            
                                            if self.shouldRefresh{
                                                self.tableView.deleteRows(at: self.requests.enumerated().map({ (offset, _) -> IndexPath in
                                                    IndexPath(row: offset, section: 0)
                                                }), with: .automatic)
                                                self.requests.removeAll()
                                                self.shouldRefresh = false
                                                self.refreshControl?.endRefreshing()
                                            }
                                            
                                            self.tableView.insertRows(at: requests!.enumerated().map({ (offset, _) -> IndexPath in
                                                IndexPath(row: self.requests.count + offset, section: 0)
                                            }), with: .automatic)
                                            self.requests.insert(contentsOf: requests!, at: self.requests.count)
                                            self.tableView.endUpdates()
                                            self.loading = false
                                        }
            })
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EstimationHistoryListCell
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? EstimationHistoryListCell{
            cell.request = requests[indexPath.row]
        }
        
        if indexPath.row == requests.count - 1{
            if !loadingFinished && nextToken != nil{
                loadNext()
            }
        }
    }
    
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            var id = ""
            if let cell = sender as? EstimationHistoryListCell {
                if let request = cell.request {
                    id = request.id!
                    self.delegate?.estimationHistoryListViewController(viewController: self,
                                                                       didSelectEstimationRequest: request,
                                                                       toShowDetailViewController: segue.destination as! EstimationHistoryViewController)
                }
            }
            if !id.isEmpty{
                if let vc = segue.destination as? EstimationHistoryViewController {
                    BodyBankEnterprise.getEstimationRequest(id: id, callback: {[unowned self] (detailedRequest, errors) in
                        if let errors = errors{
                            Alertift.alert(title: nil, message: errors.map({ (error) -> String in
                                error.localizedDescription
                            }).joined(separator: "\n")).action(.default("OK")).show(on: self, completion: nil)
                        }else{
                            vc.request = detailedRequest
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func closeButtonDidTap(sender: Any){
        delegate?.estimationHistoryListViewControllerDidFinish(viewController: self)
    }
}
