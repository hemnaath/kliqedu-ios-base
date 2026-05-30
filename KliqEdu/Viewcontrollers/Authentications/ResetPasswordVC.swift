//
//  ResetPasswordVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit
import SwiftyJSON
import Alamofire

class ResetPasswordVC: UIViewController ,UITextFieldDelegate{

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var passwordWarningLbl: UILabel!
    @IBOutlet weak var confirmPassWarningLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var passwordShowBtn: UIButton!
    @IBOutlet weak var passwordShowBtn1: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!

    var email = ""
    var token = ""
    var dictLocal = Dictionary<String, Any>()
    let defaults = UserDefaults.standard
    let maxLengths: [Int: Int] = [
        1: 25, // Password field
        2: 25  // Confirm password field
    ]
    var comingFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.descriptionLbl.addInterlineSpacing(spacingValue: 5, alignment: .center)

        self.newPasswordField.setLeftPaddingPoints(12)
        self.confirmPasswordField.setLeftPaddingPoints(12)
        newPasswordField.tag = 1
        confirmPasswordField.tag = 2
        self.passwordWarningLbl.hide()
        self.confirmPassWarningLbl.hide()

        if self.comingFrom == "login"{
            self.submitBtn.setTitle("Set Password", for: .normal)
            self.titleLbl.text = "Set Password"
            self.topImage.image = UIImage(named: "setPassword")
        }else{
            self.submitBtn.setTitle("Reset Password", for: .normal)
            self.titleLbl.text = "Reset Password"
            self.topImage.image = UIImage(named: "resetPass")
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if comingFrom == "resetlink"{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func passwordShowBtnTapped(_ sender: Any) {
        self.passwordShowBtn.isSelected = !self.passwordShowBtn.isSelected
        self.newPasswordField.isSecureTextEntry = self.passwordShowBtn.isSelected ? false : true
    }
    @IBAction func passwordShowBtnTapped1(_ sender: Any) {
        self.passwordShowBtn1.isSelected = !self.passwordShowBtn1.isSelected
        self.confirmPasswordField.isSecureTextEntry = self.passwordShowBtn1.isSelected ? false : true
    }
    @IBAction func resetPasswordBtnTapped(_ sender: Any) {
        var isValid = true
        
        if let error = ValidationClass.validatePassword(newPasswordField.text ?? "") {
            passwordWarningLbl.text = error
            passwordWarningLbl.unhide()
            isValid = false
        } else {
            passwordWarningLbl.hide()
        }
        
        // Confirm Password Validation
        if newPasswordField.text != confirmPasswordField.text {
            confirmPassWarningLbl.unhide()
            confirmPassWarningLbl.text = "Passwords do not match"
            isValid = false
        }else {
            confirmPassWarningLbl.hide()
        }
    
        // Proceed if all validations pass
        if isValid {
            self.submitBtn?.showButtonLoading()

            if self.comingFrom == "login"{
                self.setPasswordApi()
            }else{
                self.resetPasswordApi()
            }
        }
    }
    func resetPasswordApi(){
        
        let param = ["token" : token,
                     "password" : (newPasswordField.text ?? "").trimString()] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/reset-password",params: param,HTTPMethod: .post)
        
        self.callServiceMethod(service: Constants.Urls.resetPasswordUrl,method: .post, params: param, key: "resetPasswordUrl", headers: headers)
    }
    
    func setPasswordApi(){
        
        let param = ["email" : email,
                     "password" : (newPasswordField.text ?? "").trimString()] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/set-password",params: param,HTTPMethod: .post)
        
        self.callServiceMethod(service: Constants.Urls.setPasswordUrl,method: .post, params: param, key: "resetPasswordUrl", headers: headers)
    }

    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "resetPasswordUrl"{
                        self.submitBtn?.hideButtonLoading()

                        self.delay(bySeconds: 0.0) {
                            
                            let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
                            if let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                                
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                self.submitBtn?.hideButtonLoading()

                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                
               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }
            }
        }) { (error) in
            self.submitBtn?.hideButtonLoading()

            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            
            debugPrint(error)
        }
    }
}
extension ResetPasswordVC {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newPasswordField {
            confirmPasswordField.becomeFirstResponder()
            if let error = ValidationClass.validatePassword(newPasswordField.text ?? "") {
                passwordWarningLbl.text = error
                passwordWarningLbl.unhide()
            } else {
                passwordWarningLbl.hide()
            }
            return true
        } else if textField == confirmPasswordField {
            self.view.endEditing(true)
            // Compare updated password and confirm password
            let passwordText = newPasswordField.text ?? ""
            if passwordText == confirmPasswordField.text ?? "" {
                confirmPassWarningLbl.hide()
            } else {
                confirmPassWarningLbl.unhide()
                confirmPassWarningLbl.text = "Passwords do not match"
            }
            return true
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the updated text after the replacement
        guard let currentText = textField.text else { return true }
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == newPasswordField {
            
            if let error = ValidationClass.validatePassword(newPasswordField.text ?? "") {
                passwordWarningLbl.text = error
                passwordWarningLbl.unhide()
            } else {
                passwordWarningLbl.hide()
            }
        }else if textField == confirmPasswordField {
            // Compare updated password and confirm password
            let passwordText = newPasswordField.text ?? ""
            if passwordText == updatedText as String {
                confirmPassWarningLbl.hide()
                
            } else {
                confirmPassWarningLbl.unhide()
                confirmPassWarningLbl.text = "Passwords do not match"
            }
        }

        guard let currentText = textField.text else { return true }
           
           // Get the maximum length for the current text field
           let maxLength = maxLengths[textField.tag] ?? 0
           
           // Calculate the new length of the text
           let newLength = currentText.count + string.count - range.length
           
           // Return true if the new length is within the maximum limit
           return newLength <= maxLength
        
    }
}
