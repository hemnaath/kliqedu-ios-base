//
//  LoginVC.swift
//  KliqEdu
//
//  Created by codegama on 25/03/26.
//

import UIKit
import Foundation
import SwiftyJSON

class LoginVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailWarningLbl: UILabel!
    @IBOutlet weak var passwordWarningLbl: UILabel!
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var passwordShowBtn: UIButton!
    
    var dict : [String : AnyObject]!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        defaults.set(true, forKey: "isLaunched")

        self.emailField.setLeftPaddingPoints(12)
        self.passwordField.setLeftPaddingPoints(12)
        loginView.roundTopCorners(radius: 50)

        self.emailWarningLbl.hide()
        self.passwordWarningLbl.hide()
        
        self.emailField.text = "iosdev2306+2@gmail.com"
        self.passwordField.text = "Kar@1234567890"
       // signinBtn.setButtonLeftRightGradientBackground(cornerRadius: 10,leftColor: .themeColor,rightColor: .themeLiteColor)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // if you already applied gradient before, make sure it matches final size
        signinBtn.updateButtonGradientFrame()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarBackgroundColor(UIColor(hex: "#5343B0"))
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeStatusBarBackground()
    }
    @IBAction func passwordEyeBtnTapped(_ sender: Any) {
        self.passwordShowBtn.isSelected = !self.passwordShowBtn.isSelected
        self.passwordField.isSecureTextEntry = self.passwordShowBtn.isSelected ? false : true
    }
    @IBAction func forgotPassswordTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ForgotPasswordVC") as? ForgotPasswordVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func loginBtnTapped(_ sender: Any) {
        var isValid = true
        if emailField.text ?? "" == "" {
            emailWarningLbl.unhide()
            emailWarningLbl.text = StringConstants.pleaseGiveAValidEmailAddress
            isValid = false
        } else if !ValidationClass.isValidEmailID(email: (emailField.text ?? "").trimString()) {
            emailWarningLbl.unhide()
            emailWarningLbl.text = StringConstants.pleaseGiveAValidEmailAddress
            isValid = false
        } else {
            emailWarningLbl.hide()
        }
        
        // Check for empty password
        if passwordField.text ?? "" == "" {
            passwordWarningLbl.unhide()
            passwordWarningLbl.text = StringConstants.pleaseEnterAValidPassword
            isValid = false
        } else if !ValidationClass.isValidPassword1(password: (passwordField.text ?? "").trimString()) {
            passwordWarningLbl.unhide()
            passwordWarningLbl.text = StringConstants.pleaseEnterAValidPassword
            isValid = false
        } else {
            passwordWarningLbl.hide()
        }
        
        // Proceed if all validations pass
        if isValid {
            signinBtn?.showButtonLoading()
            
            validation()
        }

    }
    func validation() {
        self.view.endEditing(true)

        var timeZone = TimeZone.current.identifier
    
        let paramDic: [String: Any] = [
            "email": (emailField.text ?? "").trimString(),
            "password": (passwordField.text ?? "").trimString()]

        print("ParamDic====\(paramDic)")
       
        AlamofireHC.requestPOST(Constants.Urls.manualLoginUrl, params: paramDic, headers: Constants.mobile_headers, success: { response in

            guard let result = response.dictionaryObject,
                  let isSuccess = result["success"] as? Bool else {
                self.showAnimatedToast(message: "Unexpected server response.",type: .warning)
                return
            }

            if isSuccess {
                guard let data = result["data"] as? [String: Any] else {

                    self.showAnimatedToast(message: "Missing user data.")

                    return

                }

                let defaults = UserDefaults.standard

                // MARK: - Main User Data

                let token = data["access_token"] as? String ?? ""
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

                defaults.synchronize()

                let message = result["message"] as? String ?? ""
                self.signinBtn?.hideButtonLoading()

                DispatchQueue.main.async {
                    let sb = UIStoryboard(name: Constants.StoryboardIds.loginSB, bundle: nil)

                    if emailStatus == 0 {
                        if let vc = sb.instantiateViewController(withIdentifier: "OTPVC") as? OTPVC {
                            vc.emailId = email
                            vc.comingFrom = "login"

                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else{
                        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
                        if let vc = sb.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                            self.defaults.set(true, forKey: Constants.Keys.isLoggedIn)

                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }

//                    case 3057: // 149
//                        if let vc = sb.instantiateViewController(withIdentifier: "RegisterTfaVC") as? RegisterTfaVC {
//                            vc.qrCode = qrCode
//                            vc.password = self.passwordField.text ?? ""
//                            vc.secretKeyData = google2fa_secret
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//
//                    case 3056: // 150
//                        if let vc = sb.instantiateViewController(withIdentifier: "LoginTwoStepVC") as? LoginTwoStepVC {
//                            vc.emailId = emailId
//                            vc.password = self.passwordField.text ?? ""
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    case 3017: // 11012
//
//                        if let vc = sb.instantiateViewController(withIdentifier: "NewOTPVC") as? NewOTPVC {
//                            vc.emailId = emailId
//                            vc.otptoken = tokenOtp
//                            vc.qrCode = qrCode1
//                            vc.secretKeyData = google2fa_secret1
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    default:
//                        let mainSB = UIStoryboard(name: Constants.StoryboardIds.mainSb, bundle: nil)
//                        if let vc = mainSB.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
//                            self.defaults.set(true, forKey: Constants.Keys.isLoggedIn)
//
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    }

                    self.showAnimatedToast(message: message)
                }

            } else {
                let errorCode = result["status_code"] as? Int ?? 0
                let message = result["message"] as? String ?? "Login failed. Please try again."
                self.signinBtn?.hideButtonLoading()
                
                self.showAnimatedToast(message: message,type: .warning)
            }

        }) { error in
            self.signinBtn?.hideButtonLoading()

            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)

            print(error)
        }
    }
}
extension LoginVC {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        guard let currentText = textField.text,
              let stringRange = Range(range, in: currentText) else {
            return true
        }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if textField == emailField {
            
            if let error = ValidationClass.validateEmail(updatedText) {
                emailWarningLbl.text = error
                emailWarningLbl.unhide()
            } else {
                emailWarningLbl.hide()
            }
            
        } else if textField == passwordField {
            
            if !ValidationClass.isValidPassword1(password: updatedText) {
                passwordWarningLbl.unhide()
                passwordWarningLbl.text = StringConstants.pleaseEnterAValidPassword
            } else {
                passwordWarningLbl.hide()
            }
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            
            passwordField.becomeFirstResponder()
            
            if let error = ValidationClass.validateEmail(emailField.text ?? "") {
                emailWarningLbl.text = error
                emailWarningLbl.unhide()
            } else {
                emailWarningLbl.hide()
            }
            
            return true
            
        } else if textField == passwordField {
            
            view.endEditing(true)
            
            if !ValidationClass.isValidPassword1(password: passwordField.text ?? "") {
                passwordWarningLbl.unhide()
                passwordWarningLbl.text = StringConstants.pleaseEnterAValidPassword
            } else {
                passwordWarningLbl.hide()
            }
            return true
        }
        return true
    }
}
