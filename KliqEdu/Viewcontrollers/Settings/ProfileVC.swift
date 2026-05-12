//
//  ProfileVC.swift
//  KliqEdu
//
//  Created by codegama on 27/03/26.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON

class ProfileVC: UIViewController {

    @IBOutlet weak var empIdLbl: UILabel!
    @IBOutlet weak var deptLbl: UILabel!
    @IBOutlet weak var joinedDateLbl: UILabel!
    @IBOutlet weak var totalExpLbl: UILabel!
    @IBOutlet weak var qualificationLbl: UILabel!
    
    @IBOutlet weak var dobLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var bgLbl: UILabel!
    @IBOutlet weak var religionLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var emgNumLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var fatherNameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    
    @IBOutlet weak var positionLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!

    @IBOutlet weak var personalView: UIView!
    @IBOutlet weak var empView: UIView!
    @IBOutlet weak var empDetailsBtn: UIButton!
    @IBOutlet weak var personalDetailsBtn: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var profileDetails: ProfileModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        self.positionLbl.layer.cornerRadius = 17.5
        self.positionLbl.layer.masksToBounds = true
        
        empDetailsBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        personalDetailsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.personalView.isHidden = true
        self.empView.isHidden = false
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startViewAnimation()
        profileApi()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func empDetailsBtnTapped(_ sender: Any) {
        empDetailsBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        personalDetailsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.personalView.isHidden = true
        self.empView.isHidden = false
    }
    @IBAction func personalDetailsBtnTapped(_ sender: Any) {
        empDetailsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        personalDetailsBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        self.personalView.isHidden = false
        self.empView.isHidden = true
    }
    func startViewAnimation()  {
        profilePicture.showSkeleton(cornerRadius: 25)
        positionLbl.showSkeleton(cornerRadius: 17.5)
        empIdLbl.showSkeleton(cornerRadius: 0)
        deptLbl.showSkeleton(cornerRadius: 0)
        joinedDateLbl.showSkeleton(cornerRadius: 0)
        totalExpLbl.showSkeleton(cornerRadius: 0)
        qualificationLbl.showSkeleton(cornerRadius: 0)

    }
    func stopViewAnimation()  {
        profilePicture.hideSkeleton()
        positionLbl.hideSkeleton()
        empIdLbl.hideSkeleton()
        deptLbl.hideSkeleton()
        joinedDateLbl.hideSkeleton()
        totalExpLbl.hideSkeleton()
        qualificationLbl.hideSkeleton()

    }

    func profileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/profile",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.profileUrl,method: .get, params: param, key: "profileUrl", headers: headers)
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "profileUrl"{
                        self.stopViewAnimation()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            
                            self.profileDetails = ProfileModel(dictionary: dataList)
                            
                            let firstName = self.profileDetails?.firstname ?? ""
                            let lastName = self.profileDetails?.lastname ?? ""
                            
                            self.nameLbl.text = "\(firstName) \(lastName)"
                            self.positionLbl.text = self.profileDetails?.position
                            
                            self.qualificationLbl.text = self.profileDetails?.qualification ?? "-"
                            self.totalExpLbl.text = "\(self.profileDetails?.total_experience ?? 0) Years"
                            
                            self.dobLbl.text = self.profileDetails?.dob ?? "-"
                            self.genderLbl.text = self.profileDetails?.gender ?? "-"
                            self.bgLbl.text = self.profileDetails?.blood_group ?? "-"
                            self.religionLbl.text = self.profileDetails?.religion ?? "-"
                            self.mobileLbl.text = self.profileDetails?.mobile ?? "-"
                            self.emgNumLbl.text = self.profileDetails?.emergency_contact ?? "-"
                            self.emailLbl.text = self.profileDetails?.email ?? "-"
                            self.fatherNameLbl.text = self.profileDetails?.father_name ?? "-"
                            self.addressLbl.text = self.profileDetails?.address ?? "-"
                            
                            if let imageStr = self.profileDetails?.picture {
                                self.profilePicture.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: "profile_placeholder"))
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
