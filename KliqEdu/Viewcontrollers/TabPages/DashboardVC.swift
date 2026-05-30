//
//  DashboardVC.swift
//  KliqEdu
//
//  Created by codegama on 26/03/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkeletonView

class DashboardVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var goodMorningLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var quoteLbl: UILabel!
    @IBOutlet weak var quoteAuthorLbl: UILabel!
    
    @IBOutlet weak var studentsCard: UIView!
    @IBOutlet weak var noticesCard: UIView!
    @IBOutlet weak var holidaysCard: UIView!
    @IBOutlet weak var feesCard: UIView!
    @IBOutlet weak var teachersCard: UIView!
    @IBOutlet weak var studentInfoCard: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    var profileDetails: ProfileModel?
    var announcementArray = [AnnouncementModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        
        userID = defaults.value(forKey: Constants.Keys.userIdKey) as? Int ?? 0
        api_Key = defaults.value(forKey: Constants.Keys.apiKey) as? String ?? ""
        salt_Key = defaults.value(forKey: Constants.Keys.saltKey) as? String ?? ""
        token = defaults.value(forKey: Constants.Keys.accessTokenKey) as? String ?? ""
        roleKey = defaults.value(forKey: Constants.Keys.roleKey) as? String ?? ""
        self.emptyView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "NotificationsTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NotificationsTCell")
        startViewAnimation()
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        self.dashboardApi()
        
        if roleKey == "parent"{
            self.studentsCard.isHidden = true
            self.feesCard.isHidden = false
            self.teachersCard.isHidden = false
            self.bottomStackView.unhide()
        }else{
            self.studentsCard.isHidden = false
            self.feesCard.isHidden = true
            self.teachersCard.isHidden = true
            self.bottomStackView.hide()
            
            self.profileApi()
            
        }
        
        updateGreetingText()
    }
    func updateGreetingText() {
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            goodMorningLbl.text = "Good Morning"
            
        case 12..<17:
            goodMorningLbl.text = "Good Afternoon"
            
        case 17..<21:
            goodMorningLbl.text = "Good Evening"
            
        default:
            goodMorningLbl.text = "Good Night"
        }
    }
    func startViewAnimation()  {
        nameLbl.showSkeleton(cornerRadius: 0)
        goodMorningLbl.showSkeleton(cornerRadius: 0)
        quoteLbl.showSkeleton(cornerRadius: 0)
        quoteAuthorLbl.showSkeleton(cornerRadius: 0)
    }
    func stopViewAnimation()  {
        nameLbl.hideSkeleton()
        goodMorningLbl.hideSkeleton()
        quoteLbl.hideSkeleton()
        quoteAuthorLbl.hideSkeleton()
    }
    func dashboardApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/get",params: param,HTTPMethod: .get)
        
        if roleKey == "teacher"{
            self.callServiceMethod(service: Constants.Urls.teacherDashboardUrl,method: .get, params: param, key: "dashboardUrl", headers: headers)

        }else{
            self.callServiceMethod(service: Constants.Urls.parentDashboardUrl,method: .get, params: param, key: "dashboardUrl", headers: headers)
        }
    }
    func profileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/profile",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.profileUrl,method: .get, params: param, key: "profileUrl", headers: headers)
    }
    @IBAction func profileBtnTapped(_ sender: Any) {
        if roleKey == "teacher"{
            
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ParentProfileVC") as? ParentProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func studentsBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.studentPermissionKey) as? Bool ?? false
        
        if permission {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "StudentsVC") as? StudentsVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func noticesBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.announcementsPermissionKey) as? Bool ?? false

        if permission {
            
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ActivitiesVC") as? ActivitiesVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func holidaysBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.holidayPermissionKey) as? Bool ?? false
        
        if permission {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "HolidaysVC") as? HolidaysVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func feesBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.feesPermissionKey) as? Bool ?? false
        
        if permission {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "FeesListVC") as? FeesListVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func teachersBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.teacherPermissionKey) as? Bool ?? false
        
        if permission {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "TeachersListVC") as? TeachersListVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func studentInfoBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "StudentInfoVC") as? StudentInfoVC {
            vc.comingFrom = "home"
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func viewAllAnnouncementTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ActivitiesVC") as? ActivitiesVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "dashboardUrl"{
                        self.stopViewAnimation()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            self.quoteLbl.text = dataList.value(forKey: "quote") as? String
                            self.quoteAuthorLbl.text = "- \(dataList.value(forKey: "author") as? String ?? "")"
                            self.nameLbl.text = (dataList.value(forKey: "full_name") as? String)?.firstUppercased
                            
                            self.tableView.hideSkeleton()
                            
                            let listArray = dataList["announcementData"] as? Array<Dictionary<String,Any>> ?? []
                            
                            // Only clear the array if `skip` is 0, otherwise append
                                self.announcementArray.removeAll()
                            
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
                        }
                    }else if key == "profileUrl"{
                        self.stopViewAnimation()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            
                            self.profileDetails = ProfileModel(dictionary: dataList)
                            
                        }
                        }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                
               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }

            }
        }) { (error) in
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
}
// MARK: - UITableViewDataSource
extension DashboardVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
            return "NotificationsTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
