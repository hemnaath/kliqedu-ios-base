//
//  ForgotPasswordVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit
import SwiftyJSON

class ForgotPasswordVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailWarningLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    var dictLocal = Dictionary<String, Any>()
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.emailField.setLeftPaddingPoints(12)
        self.emailWarningLbl.hide()
        self.descriptionLbl.addInterlineSpacing(spacingValue: 5, alignment: .center)

        // Do any additional setup after loading the view.
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendBtnTapped(_ sender: Any) {
//        let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "ResetPasswordVC") as? ResetPasswordVC {
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        var isValid = true
         
        if let error = ValidationClass.validateEmail(emailField.text ?? "") {
            emailWarningLbl.text = error
            emailWarningLbl.unhide()
            isValid = false
        } else {
            emailWarningLbl.hide()
        }
        
        // Proceed if all validations pass
        if isValid {
            self.submitBtn?.showButtonLoading()
//            let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
//            if let vc = sb.instantiateViewController(withIdentifier: "ResetPasswordVC") as? ResetPasswordVC {
////                                vc.emailId = self.emailField.text ?? ""
////                                vc.comingFrom = "forgotPassword"
//
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
            self.callAPI()
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the updated text after the replacement
        guard let currentText = textField.text else { return true }
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == emailField {
            // Validate email
            if let error = ValidationClass.validateEmail(updatedText) {
                emailWarningLbl.text = error
                emailWarningLbl.unhide()
            } else {
                emailWarningLbl.hide()
            }
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            
            self.emailField.resignFirstResponder()
        }
        return true
    }
    
    func callAPI() {
        
        let paramDic = ["email": (self.emailField.text ?? "").trimString(),
                        "device_type":"mobile"]
        self.callService(service: Constants.Urls.forgotPasswordUrl, params: paramDic, key: "forgotP")
    }
    
    func callService(service: String, params: [String: Any], key: String, hudStauts : Bool = true) {
        
        AlamofireHC.requestPOST(service, params : params, headers: Constants.mobile_headers, shouldShowHUD: hudStauts, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if (result as NSDictionary?) != nil {
                    
                    if key == "forgotP" {

                        self.submitBtn?.hideButtonLoading()
                        let msg = result!["message"] as? String ?? ""
                        self.showAnimatedToast(message: msg)
                        
//                            let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
//                            if let vc = sb.instantiateViewController(withIdentifier: "ResetPasswordVC") as? ResetPasswordVC {
////                                vc.emailId = self.emailField.text ?? ""
////                                vc.comingFrom = "forgotPassword"
//
//                                self.navigationController?.pushViewController(vc, animated: true)
//                            }
                    }
                } else {
                    
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                self.submitBtn?.hideButtonLoading()

                let errorCode: Int = result?["error_code"] as? Int ?? 0
                let msg = result?["error"] as? String ?? ""
                
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
