//
//  DeleteAccountVC.swift
//  KliqEdu
//
//  Created by codegama on 16/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class DeleteAccountVC: UIViewController ,UITextFieldDelegate{

    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var PasswordShowBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var confrimBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionLbl.addInterlineSpacing()

        self.passwordField.setLeftPaddingPoints(12)
        self.warningLbl.hide()
        self.confrimBtn.isEnabled = false
        self.confrimBtn.backgroundColor = .lightGray
        self.confrimBtn.setTitleColor(.white, for: .normal)
    }

    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func PShowBtnTapped(_ sender: Any) {
        
        self.PasswordShowBtn.isSelected = !self.PasswordShowBtn.isSelected
        self.passwordField.isSecureTextEntry = self.PasswordShowBtn.isSelected ? false : true
    }
    @IBAction func confirmBtnTapped(_ sender: Any) {
        if passwordField.text ?? "" == "" {
            self.confrimBtn.isEnabled = false
            self.confrimBtn.backgroundColor = .lightGray
            self.confrimBtn.setTitleColor(.white, for: .normal)

        }else{
            self.confrimBtn.isEnabled = true
            self.confrimBtn.backgroundColor = .theme
            self.confrimBtn.setTitleColor(.white, for: .normal)

            self.confrimBtn?.showButtonLoading()

            let param = ["password": passwordField.text ?? "" ] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/delete-account",params: param,HTTPMethod: .post)

            if roleKey == "teacher"{
                self.callServiceMethod(service: Constants.Urls.teacherDelAccUrl,method: .post, params: param, key: "deleteAccountUrl", headers: headers)
                
            }else{
                self.callServiceMethod(service: Constants.Urls.parentDelAccUrl,method: .post, params: param, key: "deleteAccountUrl", headers: headers)
            }
        }
    }
    
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "deleteAccountUrl"{
                        self.confrimBtn?.hideButtonLoading()

                        let msg = result?["message"] as? String ?? ""
                        self.performLogout(msg: msg, Vc: self, isForcefull: false)
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                self.confrimBtn?.hideButtonLoading()

                let errorCode: Int = result!["error_code"] as? Int ?? 0
                let msg = result!["error"] as? String ?? ""
                
               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }
            }
            
        }) { (error) in
            self.confrimBtn?.hideButtonLoading()

            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)

            debugPrint(error)
        }
    }
    func textField(_ textField: UITextField,shouldChangeCharactersIn range: NSRange,replacementString string: String) -> Bool {

        guard let currentText = textField.text else { return true }
        
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let trimmedText = updatedText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.isEmpty {
            self.confrimBtn.isEnabled = false
            self.confrimBtn.backgroundColor = .lightGray
            self.confrimBtn.setTitleColor(.white, for: .normal)

        } else {
            self.confrimBtn.isEnabled = true
            self.confrimBtn.backgroundColor = .theme
            self.confrimBtn.setTitleColor(.white, for: .normal)
        }

        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == passwordField {
            
            self.passwordField.resignFirstResponder()
        }
        return true
    }
}
