//
//  ConfigurationsVC.swift
//  KliqEdu
//
//  Created by codegama on 24/05/26.
//

import UIKit
import LocalAuthentication
import Alamofire
import SwiftyJSON

class ConfigurationsVC: UIViewController {

    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var faceIDSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        faceIDSwitch.isEnabled = isFaceIDAvailable()
        faceIDSwitch.isOn = UserDefaults.standard.bool(forKey: Constants.Keys.faceID)
        self.startViewAnimation()
        self.configurationsApi()
        // Do any additional setup after loading the view.
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func startViewAnimation()  {
        faceIDSwitch.showSkeleton(cornerRadius: 10)
        pushSwitch.showSkeleton(cornerRadius: 10)
        emailSwitch.showSkeleton(cornerRadius: 10)
    }
    func stopViewAnimation()  {
        faceIDSwitch.hideSkeleton()
        pushSwitch.hideSkeleton()
        emailSwitch.hideSkeleton()
    }
    
    func configurationsApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/configurations",params: param,HTTPMethod: .get)
        if roleKey == "teacher"{
            
            self.callServiceMethod(service: Constants.Urls.teacherconfigurationsUrl,method: .get, params: param, key: "configurationsUrl", headers: headers)
        }else{
            self.callServiceMethod(service: Constants.Urls.parentconfigurationsUrl,method: .get, params: param, key: "configurationsUrl", headers: headers)

        }
    }
    @IBAction func faceIDSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            enableFaceID()
        } else {
            disableFaceID()
        }
    }
    @IBAction func pushSwitchToggled(_ sender: UISwitch) {
        let param = [
            "push_notifications_allowed": sender.isOn ? 1 : 0,"email_notifications_allowed":emailSwitch.isOn ? 1 : 0] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/configurations",params: param,HTTPMethod: .patch)
        
        if roleKey == "teacher"{
            
            self.callServiceMethod(service: Constants.Urls.teacherconfigurationsUrl,method: .patch, params: param, key: "updateConfigurationsUrl", headers: headers)
        }else{
            self.callServiceMethod(service: Constants.Urls.parentconfigurationsUrl,method: .patch, params: param, key: "updateConfigurationsUrl", headers: headers)

        }
    }
    @IBAction func emailSwitchToggled(_ sender: UISwitch) {
        let param = [
            "email_notifications_allowed": sender.isOn ? 1 : 0,"push_notifications_allowed":pushSwitch.isOn ? 1 : 0] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/configurations",params: param,HTTPMethod: .patch)
        
        if roleKey == "teacher"{
            
            self.callServiceMethod(service: Constants.Urls.teacherconfigurationsUrl,method: .patch, params: param, key: "updateConfigurationsUrl", headers: headers)
        }else{
            self.callServiceMethod(service: Constants.Urls.parentconfigurationsUrl,method: .patch, params: param, key: "updateConfigurationsUrl", headers: headers)

        }
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "configurationsUrl"{
                        self.stopViewAnimation()
                        
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            
                            let pushNotificationsAllowed = dataList.value(forKey: "push_notifications_allowed") as? Int ?? 0
                            let emailNotificationsAllowed = dataList.value(forKey: "email_notifications_allowed") as? Int ?? 0
                            
                            self.pushSwitch.isOn = pushNotificationsAllowed == 1
                            self.emailSwitch.isOn = emailNotificationsAllowed == 1
                        }
                    }else if key == "updateConfigurationsUrl"{
                        self.showAnimatedToast(message: responseDict.value(forKey: "message") as? String ?? "Updated successfully", type: .success)
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
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
    func isFaceIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func enableFaceID() {
        if !isFaceIDAvailable() {
            faceIDSwitch.setOn(false, animated: true)
            showAnimatedToast(message: "Biometric authentication is not available", type: .warning)
            return
        }
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        print("face")
        // Check if the device supports Face ID and if so, try to enable it
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable Face ID to secure your account") { success, error in
                DispatchQueue.main.async {
                    if success {
                        // Face ID enabled successfully
                        // Handle successful enablement (e.g., save the state to UserDefaults)
                        UserDefaults.standard.set(true, forKey: Constants.Keys.faceID)
                    } else {
                        // Face ID could not be enabled
                        // Handle error (e.g., show an alert)
                        self.faceIDSwitch.setOn(false, animated: true)
                        self.showAnimatedToast(message: "Face ID authentication failed", type: .error)
                    }
                }
            }
        } else {
            // Device does not support Face ID
            // Handle this case (e.g., show an alert)
            faceIDSwitch.setOn(false, animated: true)
        }
    }

    func disableFaceID() {
        UserDefaults.standard.set(false, forKey: Constants.Keys.faceID)
    }
}
