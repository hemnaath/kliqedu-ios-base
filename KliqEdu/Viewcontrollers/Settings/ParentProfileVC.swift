//
//  ParentProfileVC.swift
//  KliqEdu
//
//  Created by codegama on 12/05/26.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON

class ParentProfileVC: UIViewController {

    // Parent
    @IBOutlet weak var fathernameLbl: UILabel!
    @IBOutlet weak var mothernameLbl: UILabel!
    @IBOutlet weak var fatheroccupationLbl: UILabel!
    @IBOutlet weak var motheroccupationLbl: UILabel!
    @IBOutlet weak var fatherMobileLbl: UILabel!
    @IBOutlet weak var motherMobileLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!

    // Student
    @IBOutlet weak var dobLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var bgLbl: UILabel!
    @IBOutlet weak var religionLbl: UILabel!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var casteLbl: UILabel!
    
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!

    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var studentBtn: UIButton!
    @IBOutlet weak var parentBtn: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    
    var profileDetails: ParentProfileModel?
    var selectedTab = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        self.gradeLbl.layer.cornerRadius = 17.5
        self.gradeLbl.layer.masksToBounds = true
        
        studentBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        parentBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.parentView.isHidden = true
        self.studentView.isHidden = false
        
        self.selectedTab = "student"
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startViewAnimation()
        studentprofileApi()
        parentprofileApi()

    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func studentBtnTapped(_ sender: Any) {
        self.selectedTab = "student"

        studentBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        parentBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.parentView.isHidden = true
        self.studentView.isHidden = false
        self.nameLbl.unhide()
        self.gradeLbl.unhide()
    }
    @IBAction func parentBtnTapped(_ sender: Any) {
        self.selectedTab = "parent"

        studentBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        parentBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        self.parentView.isHidden = false
        self.studentView.isHidden = true
        
        self.nameLbl.hide()
        self.gradeLbl.hide()
    }
    @IBAction func editProfileTapped(_ sender: Any) {
        if selectedTab == "student"{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "EditStudentProfileVC") as? EditStudentProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "EditParentProfileVc") as? EditParentProfileVc {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    func startViewAnimation()  {
        profilePicture.showSkeleton(cornerRadius: 25)
        gradeLbl.showSkeleton(cornerRadius: 17.5)
        nameLbl.showSkeleton(cornerRadius: 0)
    }
    func stopViewAnimation()  {
        profilePicture.hideSkeleton()
        gradeLbl.hideSkeleton()
        nameLbl.hideSkeleton()
    }

    func studentprofileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/student-profile",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.studentProfileUrl,method: .get, params: param, key: "studentProfileUrl", headers: headers)
    }
    func parentprofileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/parent-profile",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.parentProfileUrl,method: .get, params: param, key: "parentProfileUrl", headers: headers)
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "studentProfileUrl"{
                        self.stopViewAnimation()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            
                            self.profileDetails = ParentProfileModel(dictionary: dataList)
                            
                            let firstName = self.profileDetails?.firstname ?? ""
                            let lastName = self.profileDetails?.lastname ?? ""
                            
                            self.nameLbl.text = "\(firstName) \(lastName)"
                            self.gradeLbl.text = "Grade \(self.profileDetails?.grade ?? "")"
                            
                            
                            self.dobLbl.text = self.profileDetails?.dob ?? "-"
                            self.genderLbl.text = self.profileDetails?.gender ?? "-"
                            self.bgLbl.text = self.profileDetails?.blood_group ?? "-"
                            self.religionLbl.text = self.profileDetails?.religion ?? "-"
                            self.casteLbl.text = self.profileDetails?.caste ?? "-"
                            self.rollNoLbl.text = self.profileDetails?.roll_number ?? "-"

                            
                            if let imageStr = self.profileDetails?.picture {
                                self.profilePicture.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: "profile_placeholder"))
                            }
                        }
                    }else if key == "parentProfileUrl" {
                        
                        self.stopViewAnimation()

                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {

                            self.profileDetails = ParentProfileModel(dictionary: dataList)

                            self.fathernameLbl.text = self.profileDetails?.father_name ?? "N/A"
                            self.mothernameLbl.text = self.profileDetails?.mother_name ?? "N/A"

                            self.fatheroccupationLbl.text = self.profileDetails?.father_occupation ?? "N/A"
                            self.motheroccupationLbl.text = self.profileDetails?.mother_occupation ?? "N/A"

                            self.fatherMobileLbl.text = self.profileDetails?.father_mobile ?? "N/A"
                            self.motherMobileLbl.text = self.profileDetails?.mother_mobile ?? "N/A"

                            self.emailLbl.text = self.profileDetails?.email ?? "N/A"
                            self.addressLbl.text = self.profileDetails?.address ?? "N/A"

                            if let imageStr = self.profileDetails?.picture {
                                self.profilePicture.sd_setImage(
                                    with: URL(string: imageStr),
                                    placeholderImage: UIImage(named: "profile_placeholder")
                                )
                            }
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
