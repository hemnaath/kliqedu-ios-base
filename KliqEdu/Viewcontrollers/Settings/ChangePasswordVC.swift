//
//  ChangePasswordVC.swift
//  KliqEdu
//
//  Created by codegama on 16/04/26.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var oldpasswordField: UITextField!
    @IBOutlet weak var newpasswordField: UITextField!
    @IBOutlet weak var confirmpasswordField: UITextField!
    @IBOutlet weak var currentPasswordShowBtn: UIButton!
    @IBOutlet weak var newPasswordBtn: UIButton!
    @IBOutlet weak var confirmPasswordBtn: UIButton!
    @IBOutlet weak var currentpasswordWarningLbl: UILabel!
    @IBOutlet weak var newPassWarningLbl: UILabel!
    @IBOutlet weak var confirmNewPassWarningLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!

    
    let maxLengths: [Int: Int] = [

        1: 50, // old pass field
        2: 50, // Password field
        3: 50  // Confirm password field
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.oldpasswordField.setLeftPaddingPoints(12)
        self.newpasswordField.setLeftPaddingPoints(12)
        self.confirmpasswordField.setLeftPaddingPoints(12)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true

        oldpasswordField.tag = 1
        newpasswordField.tag = 2
        confirmpasswordField.tag = 3
        self.currentpasswordWarningLbl.hide()
        self.newPassWarningLbl.hide()
        self.confirmNewPassWarningLbl.hide()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func currentPShowBtnTapped(_ sender: Any) {
        
        self.currentPasswordShowBtn.isSelected = !self.currentPasswordShowBtn.isSelected
        self.oldpasswordField.isSecureTextEntry = self.currentPasswordShowBtn.isSelected ? false : true
    }
    
    @IBAction func newPShowBtnTapped(_ sender: Any) {
        
        self.newPasswordBtn.isSelected = !self.newPasswordBtn.isSelected
        self.newpasswordField.isSecureTextEntry = self.newPasswordBtn.isSelected ? false : true
    }
    
    @IBAction func confirmPShowBtnTapped(_ sender: Any) {
        
        self.confirmPasswordBtn.isSelected = !self.confirmPasswordBtn.isSelected
        self.confirmpasswordField.isSecureTextEntry = self.confirmPasswordBtn.isSelected ? false : true
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        var isValid = true
        
        // Validate current password format
        if !ValidationClass.isValidPassword(password: oldpasswordField.text ?? "") {
            currentpasswordWarningLbl.unhide()
            currentpasswordWarningLbl.text = StringConstants.passwordIsRequired
            isValid = false
        } else {
            currentpasswordWarningLbl.hide()
        }
        
        // Validate new password format
        if !ValidationClass.isValidPassword(password: newpasswordField.text ?? "") {
            newPassWarningLbl.unhide()
            newPassWarningLbl.text = StringConstants.passwordCharacterCountError
            isValid = false
        } else {
            newPassWarningLbl.hide()
        }
        
        // Validate password match
        if  newpasswordField.text != confirmpasswordField.text {
            confirmNewPassWarningLbl.unhide()
            confirmNewPassWarningLbl.text = StringConstants.newPasswordsDoNotMatch
            isValid = false
        } else {
            confirmNewPassWarningLbl.hide()
        }
        
        // Proceed with API call if all validations pass
        if isValid {
            self.saveBtn?.showButtonLoading()
            self.performChangePassword()
        }
    }
    /// api method to change the password
    func performChangePassword() {
        
        let param = ["old_password" : (oldpasswordField.text ?? "").trimString(),
                     "new_password" : (newpasswordField.text ?? "").trimString()] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/change-password",params: param,HTTPMethod: .patch)
        
        if roleKey == "teacher"{
            self.callServiceMethod(service: Constants.Urls.teacherChangePasswordUrl,method: .patch, params: param, key: "ChangePasswordUrl", headers: headers)
            
        }else{
            self.callServiceMethod(service: Constants.Urls.parentChangePasswordUrl,method: .get, params: param, key: "ChangePasswordUrl", headers: headers)
        }
    }
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "ChangePasswordUrl"{
                        self.saveBtn?.hideButtonLoading()
                        
                        let msg = result?["message"] as? String ?? ""

                        self.delay(bySeconds: 0.0) {
                            
                            DispatchQueue.main.async {
                                
                                self.performLogout(msg: msg, Vc: self, isForcefull: false)
                                
                            }
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                
                let errorCode: Int = result!["error_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                self.saveBtn?.hideButtonLoading()

               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }

            }
        }) { (error) in
            self.saveBtn?.hideButtonLoading()

            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            
            debugPrint(error)
        }
    }
}

extension ChangePasswordVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
         if textField == oldpasswordField {
             newpasswordField.becomeFirstResponder()
            // Check for empty mobile
             if !ValidationClass.isValidPassword(password: oldpasswordField.text ?? "") {
                currentpasswordWarningLbl.unhide()
                currentpasswordWarningLbl.text = StringConstants.passwordIsRequired
            } else {
                currentpasswordWarningLbl.hide()
            }
            
            return true
        }  else if textField == newpasswordField {
            confirmpasswordField.becomeFirstResponder()
            // Validate new password format
            if !ValidationClass.isValidPassword(password: newpasswordField.text ?? "") {
                newPassWarningLbl.unhide()
                newPassWarningLbl.text = StringConstants.passwordCharacterCountError

            } else {
                newPassWarningLbl.hide()
            }

            return true
        } else if textField == confirmpasswordField {
            self.view.endEditing(true)
            // Validate password match
            if  newpasswordField.text != confirmpasswordField.text {
                confirmNewPassWarningLbl.unhide()
                confirmNewPassWarningLbl.text = StringConstants.newPasswordsDoNotMatch
            } else {
                confirmNewPassWarningLbl.hide()
            }
            return true
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the updated text after the replacement
        guard let currentText = textField.text else { return true }
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == oldpasswordField {
            
            if ValidationClass.isValidPassword(password: updatedText) {
                currentpasswordWarningLbl.hide()
            }
        }else if textField == newpasswordField {
            
            if ValidationClass.isValidPassword(password: updatedText) {
                newPassWarningLbl.hide()
            }
        }else if textField == confirmpasswordField {
            if newpasswordField.text != updatedText {
                confirmNewPassWarningLbl.unhide()
                confirmNewPassWarningLbl.text = StringConstants.newPasswordsDoNotMatch
                
            }else if ValidationClass.isValidPassword(password: updatedText) {
                confirmNewPassWarningLbl.hide()
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
