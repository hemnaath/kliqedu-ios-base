//
//  OTPVC.swift
//  Indcrypt
//
//  Created by codegama on 28/11/25.
//

import UIKit
import SwiftyJSON
import Alamofire

class OTPVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var resendOTPBtn: UIButton!
    @IBOutlet weak var secondsLbl: UILabel!
    @IBOutlet weak var txtDPOTPView: DPOTPView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var wrongEmailBtn: UIButton!
    
    var dictLocal = Dictionary<String, Any>()
    let defaults = UserDefaults.standard
    var emailId = String()
    var dict : [String : AnyObject]!
    var secondsRemaining = 15
    var comingFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtDPOTPView.dpOTPViewDelegate = self
        self.descriptionLbl.addInterlineSpacing(spacingValue: 5, alignment: .center)
        
        self.descriptionLbl.text = "Enter the OTP code sent to your email address \(emailId)"

        self.submitBtn.isEnabled = false

        self.submitBtn.setTitleColor(.white, for: .normal)
        bottomView.roundTopCorners(radius: 25)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if self.secondsRemaining > 0 {
                self.secondsLbl.unhide()
                self.resendOTPBtn.hide()
                self.secondsLbl.text = "\(self.secondsRemaining)s"
                self.secondsRemaining -= 1
            } else {
                self.secondsRemaining = 15
                self.secondsLbl.hide()
                self.resendOTPBtn.unhide()
                Timer.invalidate()
            }
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.submitBtn.isEnabled = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // if you already applied gradient before, make sure it matches final size
      //  submitBtn.updateButtonGradientFrame()
    }
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func resendOTPTapped(_ sender: Any) {
        
        let param = ["email": emailId] as [String : Any]
        self.callServiceMethod(service: Constants.Urls.verifyEmailResendUrl,method: .post, params: param, key: "verifyEmailResendUrl", headers: [:])
        
    }
    @IBAction func submitBtnTapped(_ sender: Any) {
        
        if txtDPOTPView.text ?? "" == "" {
            self.showAnimatedToast(message: "Fields can't be empty")
            self.submitBtn.isEnabled = false
            self.submitBtn.backgroundColor = .gray
            
        }else{
            self.submitBtn?.showButtonLoading()
            
            self.submitBtn.isEnabled = true

            let param =
            ["email" : emailId,
             "otp" : txtDPOTPView.text ?? ""] as [String : Any]
            
            self.callServiceMethod(service: Constants.Urls.verifyEmailUrl,method: .post, params: param, key: "verifyEmailUrl", headers: [:])
            
        }
    }

    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck){
                if key == "verifyEmailResendUrl" {
                                        
                    let msg = result!["message"] as? String ?? ""
                    self.showAnimatedToast(message: msg)

                    self.txtDPOTPView.text = ""
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
                        if self.secondsRemaining > 0 {
                            self.secondsLbl.unhide()
                            self.resendOTPBtn.hide()
                            self.secondsLbl.text = "\(self.secondsRemaining)s"
                            self.secondsRemaining -= 1
                        } else {
                            self.secondsRemaining = 15
                            self.secondsLbl.hide()
                            self.resendOTPBtn.unhide()
                            Timer.invalidate()
                        }
                    }
                } else if key == "verifyEmailUrl" {
                    
                    let data = result?["data"] as? [String: Any] ?? [:]

                    self.submitBtn?.hideButtonLoading()
                    
                    let msg = result!["message"] as? String ?? ""
                    self.showAnimatedToast(message: msg)
                    
                    let defaults = UserDefaults.standard

                    // MARK: - Main User Data

                    var token = data["access_token"] as? String ?? ""
                    let apiKey = data["api_key"] as? String ?? ""
                    let saltKey = data["salt_key"] as? String ?? ""
                    let privateKey = data["private_key"] as? String ?? ""

                    let email = data["email"] as? String ?? ""
                    let role = data["role"] as? String ?? ""
                    let emailStatus = data["email_status"] as? Int ?? 0

                    // MARK: - Permissions

                    let permissions = data["permissions"] as? [String: Any] ?? [:]
                    let dashboardPermission = permissions["dashboard"] as? Bool ?? false
                    let teacherPermission = permissions["teacher"] as? Bool ?? false
                    let feesPermission = permissions["fees"] as? Bool ?? false
                    let homeworkPermission = permissions["homework"] as? Bool ?? false
                    let leavePermission = permissions["leave"] as? Bool ?? false
                    let announcementsPermission = permissions["announcements"] as? Bool ?? false
                    let holidayPermission = permissions["holiday"] as? Bool ?? false
                    let settingsPermission = permissions["settings"] as? Bool ?? false

                    // MARK: - Children Data

                    let children = data["children"] as? [[String: Any]] ?? []
                    // Store complete children array
                    if let childrenData = try? JSONSerialization.data(withJSONObject: children, options: []) {
                        defaults.set(childrenData, forKey: Constants.Keys.childrenArrayKey)
                    }
                    let firstChild = children.first ?? [:]
                    let firstName = firstChild["firstname"] as? String ?? ""
                    let lastName = firstChild["lastname"] as? String ?? ""
                    let joinDate = firstChild["join_date"] as? String ?? ""
                    let dob = firstChild["dob"] as? String ?? ""
                    let gender = firstChild["gender"] as? Int ?? 0
                    let parentId = firstChild["parent_id"] as? String ?? ""
                    let gradeId = firstChild["grade_id"] as? String ?? ""
                    let sectionId = firstChild["section_id"] as? String ?? ""
                    let groupId = firstChild["group_id"] as? String ?? ""
                    let bloodGroup = firstChild["blood_group"] as? String ?? ""
                    let status = firstChild["status"] as? Int ?? 0
                    let age = firstChild["age"] as? Int ?? 0
                    let picture = firstChild["picture"] as? String ?? ""
                    let orgId = firstChild["org_id"] as? String ?? ""
                    let religion = firstChild["religion"] as? String ?? ""
                    let caste = firstChild["caste"] as? String ?? ""
                    let createdAt = firstChild["createdAt"] as? String ?? ""
                    let updatedAt = firstChild["updatedAt"] as? String ?? ""
                    let uniqueId = firstChild["unique_id"] as? String ?? ""
                    let rollNumber = firstChild["roll_number"] as? String ?? ""

                    // MARK: - Save to UserDefaults

                    defaults.set(token, forKey: Constants.Keys.accessTokenKey)
                    defaults.set(apiKey, forKey: Constants.Keys.apiKey)
                    defaults.set(saltKey, forKey: Constants.Keys.saltKey)
                    defaults.set(privateKey, forKey: Constants.Keys.private_key)

                    defaults.set(email, forKey: Constants.Keys.emailIdKey)
                    defaults.set(role, forKey: Constants.Keys.roleKey)
                    defaults.set(emailStatus, forKey: Constants.Keys.email_statusKey)

                    defaults.set(firstName, forKey: Constants.Keys.firstNameKey)
                    defaults.set(lastName, forKey: Constants.Keys.lastNameKey)
                    defaults.set(joinDate, forKey: Constants.Keys.joinDateKey)
                    defaults.set(dob, forKey: Constants.Keys.dobKey)
                    defaults.set(gender, forKey: Constants.Keys.gender)
                    defaults.set(parentId, forKey: Constants.Keys.parentIdKey)
                    defaults.set(gradeId, forKey: Constants.Keys.gradeIdKey)
                    defaults.set(sectionId, forKey: Constants.Keys.sectionIdKey)
                    defaults.set(groupId, forKey: Constants.Keys.groupIdKey)
                    defaults.set(bloodGroup, forKey: Constants.Keys.bloodGroupKey)
                    defaults.set(status, forKey: Constants.Keys.statusKey)
                    defaults.set(age, forKey: Constants.Keys.ageKey)
                    defaults.set(picture, forKey: Constants.Keys.userPicKey)
                    defaults.set(orgId, forKey: Constants.Keys.orgIdKey)
                    defaults.set(religion, forKey: Constants.Keys.religionKey)
                    defaults.set(caste, forKey: Constants.Keys.casteKey)
                    defaults.set(createdAt, forKey: Constants.Keys.createdAtKey)
                    defaults.set(updatedAt, forKey: Constants.Keys.updatedAtKey)
                    defaults.set(uniqueId, forKey: Constants.Keys.userUniqueIdKey)
                    defaults.set(rollNumber, forKey: Constants.Keys.rollNumberKey)

                    defaults.set(dashboardPermission, forKey: Constants.Keys.dashboardPermissionKey)
                    defaults.set(teacherPermission, forKey: Constants.Keys.teacherPermissionKey)
                    defaults.set(feesPermission, forKey: Constants.Keys.feesPermissionKey)
                    defaults.set(homeworkPermission, forKey: Constants.Keys.homeworkPermissionKey)
                    defaults.set(leavePermission, forKey: Constants.Keys.leavePermissionKey)
                    defaults.set(announcementsPermission, forKey: Constants.Keys.announcementsPermissionKey)
                    defaults.set(holidayPermission, forKey: Constants.Keys.holidayPermissionKey)
                    defaults.set(settingsPermission, forKey: Constants.Keys.settingsPermissionKey)

                    print("RJemail: \(defaults.string(forKey: Constants.Keys.emailIdKey) ?? ""),role: \(defaults.string(forKey: Constants.Keys.roleKey) ?? ""),userId: \(defaults.string(forKey: Constants.Keys.userIdKey) ?? "")")
                    
                    // Save children count
                    defaults.set(children.count, forKey: Constants.Keys.childrenCountKey)
                    defaults.synchronize()
                    
                    userID = defaults.value(forKey: Constants.Keys.userIdKey) as? Int ?? 0
                    api_Key = defaults.value(forKey: Constants.Keys.apiKey) as? String ?? ""
                    salt_Key = defaults.value(forKey: Constants.Keys.saltKey) as? String ?? ""
                    token = defaults.value(forKey: Constants.Keys.accessTokenKey) as? String ?? ""
                    roleKey = defaults.value(forKey: Constants.Keys.roleKey) as? String ?? ""
                    
                    //self.navigationController?.popViewController(animated: true)
                    let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
                    if let vc = sb.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                        self.defaults.set(true, forKey: Constants.Keys.isLoggedIn)

                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            else{
                self.submitBtn?.hideButtonLoading()
                
                let msg = result!["message"] as? String ?? ""
                if result!["status_code"] as? Int ?? 0 == 101 {
                    self.showAnimatedToast(message: msg)
                    
                }else{
                    DispatchQueue.main.async {
                        self.showAnimatedToast(message: msg)
                    }
                }
            }
        }) { (error) in
            self.submitBtn?.hideButtonLoading()
            
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain)
            
            print(error)
        }
    }
}

extension OTPVC : DPOTPViewDelegate {
    
    func dpOTPViewAddText(_ text: String, at position: Int) {
        print("addText:- " + text + " at:- \(position)" )
        
        let fullOTP = txtDPOTPView.text ?? ""
        if fullOTP.count == txtDPOTPView.count {
            self.submitBtn.isEnabled = true
            self.submitBtn.setTitleColor(.white, for: .normal)

        } else {
            self.submitBtn.isEnabled = false

            self.submitBtn.setTitleColor(.white, for: .normal)

        }
    }
    func dpOTPViewRemoveText(_ text: String, at position: Int) {
        print("removeText:- " + text + " at:- \(position)" )
        
    }
    
    func dpOTPViewChangePositionAt(_ position: Int) {
        print("at:-\(position)")
        
    }
    
    func dpOTPViewBecomeFirstResponder() {
    }
    
    func dpOTPViewResignFirstResponder() {
    }
}

