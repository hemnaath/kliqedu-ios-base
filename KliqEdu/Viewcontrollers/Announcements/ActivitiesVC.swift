//
//  ActivitiesVC.swift
//  KliqEdu
//
//  Created by codegama on 27/03/26.
//

import UIKit
import SkeletonView
import CRRefresh
import Alamofire
import SwiftyJSON
import SDWebImage

class ActivitiesVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var createAnnouncementBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var announcementArray = [AnnouncementModel]()
    var timer = Timer()
    
    var allItemsLoaded = false
    var page = 1
    var isLoadingData = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        self.view.applyVerticalLigtGradient()
        createAnnouncementBtn.dropShadow()

        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "NotificationsTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NotificationsTCell")
        
        /// Pull to refresh
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            // start refresh
            
            print("refresh")
            self?.getAnnouncementsData()
            
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
        getAnnouncementsData()
        if roleKey == "parent"{
            self.addBtn.hide()
        }else{
            self.addBtn.unhide()
        }
        self.emptyView.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func createAnnouncementBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "CreateAnnouncementVC") as? CreateAnnouncementVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func getAnnouncementsData() {
        
        allItemsLoaded = false
        
        page = 1
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        let param = ["page":page] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param, HTTPMethod: .post)
        
        if roleKey == "teacher"{
            
            self.callServiceMethod(service: Constants.Urls.teacherAnnouncementListUrl, method: .post, params: param, key: "announcementListUrl", headers: headers)
        }else{
            self.callServiceMethod(service: Constants.Urls.parentAnnouncementListUrl, method: .post, params: param, key: "announcementListUrl", headers: headers)

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
                    
                    if key == "announcementListUrl"{
                        self.isLoadingData = false
                                                
                        let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = resDataDic?["announcements"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        if self.page == 1 {
                            self.announcementArray.removeAll()
                        }
                        for item in listArray {
                            if let model = AnnouncementModel(dictionary: item as NSDictionary) {
                                self.announcementArray.append(model)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if self.announcementArray.count > 0 {
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
        
        return  announcementArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataModel = announcementArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTCell", for: indexPath as IndexPath) as? NotificationsTCell {

            cell.titleLbl.text = dataModel.title
            cell.descriptionLbl.text = dataModel.descriptionValue
            cell.dateLbl.text = "  \(dataModel.created_at ?? "")  "
            cell.descriptionLbl.addInterlineSpacing(spacingValue: 5, alignment: .left)

            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let dataModel = announcementArray[indexPath.row]

        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "AnnouncementDetailsVC") as? AnnouncementDetailsVC {
            
            vc.announcementDetails = dataModel
//            vc.accStatus = dataModel.status_formatted ?? ""
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
                    let param = ["page":page] as [String : Any]
                    
                    let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param, HTTPMethod: .post)
                    
                    self.callServiceMethod(service: Constants.Urls.studentsUrl, method: .post, params: param, key: "studentsUrl", headers: headers)
                }
            }
        }
}
// MARK: - UITableViewDataSource
extension ActivitiesVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
            return "NotificationsTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
