//
//  ResetPasswordVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit
import SwiftyJSON

class ResetPasswordVC: UIViewController ,UITextFieldDelegate{

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

    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
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

            self.resetPasswordApi()
        }
    }
    func resetPasswordApi(){
    
        let paramDic = ["token" : token,
                        "password" : (newPasswordField.text ?? "").trimString()] as [String : Any]
        
        AlamofireHC.requestPOST(Constants.Urls.resetPasswordUrl, params: paramDic, headers: Constants.mobile_headers, success: { (response) in
            
            let  result = response.dictionaryObject
            
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck){
                self.submitBtn?.hideButtonLoading()

                DispatchQueue.main.async {
                    
                    //self.showAnimatedToast(message: msg)
                }
                self.delay(bySeconds: 0.0) {
                    
                    let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
                    if let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            else{
                self.submitBtn?.hideButtonLoading()

                let msg = result!["error"] as? String ?? ""
                if result!["error_code"] as? Int ?? 0 == 101 {
                    self.showAnimatedToast(message: msg,type: .error)
                    
                }else{
                    DispatchQueue.main.async {
                        self.showAnimatedToast(message: msg,type: .error)
                    }
                }
            }
        }) { (error) in
            self.submitBtn?.hideButtonLoading()

            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            
            print(error)
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
