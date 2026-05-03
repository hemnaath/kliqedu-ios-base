//
//  LogoutVC.swift
//  KliqEdu
//
//  Created by codegama on 16/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class LogoutVC: UIViewController {
    @IBOutlet weak var logoutBtn: UIButton!
    
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = .clear

        self.delay(bySeconds: 0.25) { [weak self] in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.5)
            }
        }
    }
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
      //  self.performLogout(msg: "", Vc: self, isForcefull: false)
        logoutBtn?.showButtonLoading()

        let param = ["email":defaults.value(forKey: Constants.Keys.emailIdKey) ?? ""] as [String : Any]
        
        let (headers, _, _) = APIHelper.createHeadersAndSignature(endpoint: "/logout",params: param)

        self.callServiceMethod(service: Constants.Urls.logOutUrl,method: .post, params: param, key: "logout", headers: headers)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.onDismiss?()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss?()
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "logout" {
                        self.logoutBtn?.hideButtonLoading()

                        let msg = result?["message"] as? String ?? ""
                        self.performLogout(msg: msg, Vc: self, isForcefull: false)
                    }
                } else {
                    self.logoutBtn?.hideButtonLoading()

                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                
                let errorCode: Int = result!["error_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                self.logoutBtn?.hideButtonLoading()

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
