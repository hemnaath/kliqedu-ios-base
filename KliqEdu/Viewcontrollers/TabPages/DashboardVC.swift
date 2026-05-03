//
//  DashboardVC.swift
//  KliqEdu
//
//  Created by codegama on 26/03/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class DashboardVC: UIViewController {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var quoteLbl: UILabel!
    @IBOutlet weak var quoteAuthorLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        userID = defaults.value(forKey: Constants.Keys.userIdKey) as? Int ?? 0
        token = defaults.value(forKey: Constants.Keys.accessTokenKey) as? String ?? ""
        api_Key = defaults.value(forKey: Constants.Keys.apiKey) as? String ?? ""
        salt_Key = defaults.value(forKey: Constants.Keys.saltKey) as? String ?? ""
        token = defaults.value(forKey: Constants.Keys.accessTokenKey) as? String ?? ""
        roleKey = defaults.value(forKey: Constants.Keys.roleKey) as? String ?? ""

        startViewAnimation()
        dashboardApi()
    }
    func startViewAnimation()  {
        quoteLbl.showSkeleton(cornerRadius: 10)
        quoteAuthorLbl.showSkeleton(cornerRadius: 10)

    }
    func stopViewAnimation()  {
        quoteLbl.hideSkeleton()
        quoteAuthorLbl.hideSkeleton()
    }
    func dashboardApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _, _) = APIHelper.createHeadersAndSignature(endpoint: "/get",params: param)
        if roleKey == "teacher"{
            self.callServiceMethod(service: Constants.Urls.teacherDashboardUrl,method: .get, params: param, key: "dashboardUrl", headers: headers)

        }else{
            self.callServiceMethod(service: Constants.Urls.parentDashboardUrl,method: .get, params: param, key: "dashboardUrl", headers: headers)
        }
    }
    @IBAction func profileBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func studentsBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "StudentsVC") as? StudentsVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    @IBAction func noticesBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ActivitiesVC") as? ActivitiesVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func holidaysBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "HolidaysVC") as? HolidaysVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func feesBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "FeesListVC") as? FeesListVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func teachersBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "TeachersListVC") as? TeachersListVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
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
                            self.nameLbl.text = dataList.value(forKey: "full_name") as? String

                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                
                let errorCode: Int = result!["error_code"] as? Int ?? 0
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
}
