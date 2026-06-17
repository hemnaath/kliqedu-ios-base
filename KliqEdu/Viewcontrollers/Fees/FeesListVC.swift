//
//  FeesListVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit
import SkeletonView
import CRRefresh
import Alamofire
import SwiftyJSON
import SDWebImage

class FeesListVC: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!

    var feesArray = [FeesModel]()
    var filters: [String: Any] = [:]

    var allItemsLoaded = false
    var page = 1
    var isLoadingData = false
    
    // 🟠 Pending, 🟢 Approved, 🔴 Rejected
    var statusTitleColor = [
        UIColor.systemGreen, UIColor.systemRed.withAlphaComponent(0.7),
        UIColor.systemGreen, UIColor.systemRed.withAlphaComponent(0.7),
        UIColor.systemGreen]

    // Light background versions
    var statusBgcolor = [
        UIColor.systemGreen.withAlphaComponent(0.1),
        UIColor.systemRed.withAlphaComponent(0.1),
        
        UIColor.systemGreen.withAlphaComponent(0.1),
        UIColor.systemRed.withAlphaComponent(0.1),
        
        UIColor.systemGreen.withAlphaComponent(0.1),
        ]
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false

        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "FeesTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FeesTCell")
        
        /// Pull to refresh
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            // start refresh
            
            print("refresh")
            self?.allItemsLoaded = false
            
            self?.page = 1
            self?.getFeesData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                
                self?.tableView.cr.endHeaderRefresh()
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        getFeesData()

        self.emptyView.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
    func getFeesData() {
        
        allItemsLoaded = false
        
        page = 1
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        var param: [String: Any] = [
            "page": page
        ]
        if let status = filters["status"] {
            param["status"] = Int("\(status)") ?? 0
        }
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param, HTTPMethod: .post)
        
        self.callServiceMethod(service: Constants.Urls.feesListUrl, method: .post, params: param, key: "feesListUrl", headers: headers)

    }

    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func filterBtnTapped(_ sender: Any) {
        
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "FilterVC") as? FilterVC {
            
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical   // animation
            vc.comingFor = "Fees"
            vc.appliedFilters = self.filters
            
            vc.onApplyFilter = { filters in
                
                print(filters)
        
                self.filters = filters
                
                self.getFeesData()

            }
            present(vc, animated: true)
        }
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        guard !self.isLoadingData && !self.allItemsLoaded else { return } // Prevent duplicate requests or requests when all data is loaded
        self.isLoadingData = true
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "feesListUrl"{
                        self.isLoadingData = false
                                                
                        let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = resDataDic?["fees"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        if self.page == 1 {
                            self.feesArray.removeAll()
                        }
                        for item in listArray {
                            if let model = FeesModel(dictionary: item as NSDictionary) {
                                self.feesArray.append(model)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if self.feesArray.count > 0 {
                                self.tableView.isHidden = false
                                self.emptyView.isHidden = true

                            } else {
                                
                                self.tableView.isHidden = true
                                self.emptyView.isHidden = false
                                
                            }
                            self.tableView.reloadData()
                              
                        }
                        // Increment skip value for the next batch of data
                        if listArray.count == 0 {
                            self.allItemsLoaded = true
                            print("All items loaded. No more API calls will be made.")
                        } else {
                            self.page += 1   // go to next page
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                if errorCode == 217{
                    self.tableView.isHidden = true
                    self.emptyView.isHidden = false
                }
               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }

            }
        }) { (error) in
            self.isLoadingData = false
            
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            debugPrint(error)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  feesArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataModel = feesArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeesTCell", for: indexPath as IndexPath) as? FeesTCell {

            cell.titleLbl.text = dataModel.fee_type
            cell.statusLbl.text = "   \(dataModel.status ?? "")   "
            cell.dateLbl.text = dataModel.due_date
            cell.amtLbl.text = dataModel.remaining_amount

            let customYellow = UIColor(red: 255/255, green: 179/255, blue: 0/255, alpha: 1.0) // #FFB300

            if dataModel.status == "Pending" {

                cell.statusImage.image = UIImage(systemName: "clock.fill")
                cell.statusImage.tintColor = customYellow
                cell.dueLbl.text = "Due on:"
                cell.statusLbl.backgroundColor = customYellow.withAlphaComponent(0.15)
                cell.statusLbl.textColor = customYellow
                cell.statusView.backgroundColor = customYellow.withAlphaComponent(0.15)
                cell.amtLbl.text = dataModel.remaining_amount
            }else if dataModel.status == "Paid" {
                
                cell.statusImage.image = UIImage(systemName: "checkmark.circle.fill")
                cell.statusImage.tintColor = .systemGreen
                cell.dueLbl.text = "Paid on:"
                cell.statusLbl.backgroundColor = .systemGreen.withAlphaComponent(0.1)
                cell.statusLbl.textColor = .systemGreen
                cell.statusView.backgroundColor = .systemGreen.withAlphaComponent(0.1)
                cell.amtLbl.text = dataModel.paid_amount

            } else if dataModel.status == "Failed" {
                
                cell.statusImage.image = UIImage(systemName: "xmark.circle.fill")
                cell.statusImage.tintColor = .systemRed
                cell.dueLbl.text = "Due on:"
                cell.statusLbl.backgroundColor = .systemRed.withAlphaComponent(0.1)
                cell.statusLbl.textColor = .systemRed
                cell.statusView.backgroundColor = .systemRed.withAlphaComponent(0.1)
                cell.amtLbl.text = dataModel.remaining_amount

            } else if dataModel.status == "Overdue" {
                
                cell.statusImage.image = UIImage(systemName: "exclamationmark.triangle.fill")
                cell.statusImage.tintColor = .systemOrange
                cell.dueLbl.text = "Overdue:"
                cell.statusLbl.backgroundColor = .systemOrange.withAlphaComponent(0.1)
                cell.statusLbl.textColor = .systemOrange
                cell.statusView.backgroundColor = .systemOrange.withAlphaComponent(0.1)
                cell.amtLbl.text = dataModel.remaining_amount

            } else if dataModel.status == "Processing" {
                
                cell.statusImage.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")
                cell.statusImage.tintColor = .theme
                cell.dueLbl.text = "Paid on:"
                cell.statusLbl.backgroundColor = .theme.withAlphaComponent(0.1)
                cell.statusLbl.textColor = .theme
                cell.statusView.backgroundColor = .theme.withAlphaComponent(0.1)
                cell.amtLbl.text = dataModel.remaining_amount

            } else if dataModel.status == "Partial" {
                
                cell.statusImage.image = UIImage(systemName: "circle.lefthalf.filled")
                cell.statusImage.tintColor = .systemBlue
                cell.dueLbl.text = "Partially Paid:"
                cell.statusLbl.backgroundColor = .systemBlue.withAlphaComponent(0.1)
                cell.statusLbl.textColor = .systemBlue
                cell.statusView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
                cell.amtLbl.text = dataModel.remaining_amount
            }
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataModel = feesArray[indexPath.row]
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "FeesDetailsVC") as? FeesDetailsVC {
            
            vc.feeDetails = dataModel
            vc.uniqueId  = dataModel.unique_id ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height
            
            // Check if we should load more data
            if offsetY > contentHeight - height * 2 {
                
                if !isLoadingData && !allItemsLoaded {
                    var param: [String: Any] = [
                        "page": page
                    ]
                    if let status = filters["status"] {
                        param["status"] = Int("\(status)") ?? 0
                    }
                    let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param, HTTPMethod: .post)
                    
                    self.callServiceMethod(service: Constants.Urls.feesListUrl, method: .post, params: param, key: "feesListUrl", headers: headers)
                }
            }
        }

}
// MARK: - UITableViewDataSource
extension FeesListVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
        return "FeesTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
