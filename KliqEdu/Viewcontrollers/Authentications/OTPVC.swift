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
    var emailId = ""
    var dict : [String : AnyObject]!
    var secondsRemaining = 15
    var comingFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtDPOTPView.dpOTPViewDelegate = self
        self.descriptionLbl.addInterlineSpacing(spacingValue: 5, alignment: .center)
        
        self.descriptionLbl.text = "Enter the OTP code sent to your email address \(emailId)"

        self.submitBtn.isEnabled = false
      //  self.submitBtn.setButtonLeftRightGradientBackground(cornerRadius: 10,leftColor: .gray,rightColor: .gray)
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // if you already applied gradient before, make sure it matches final size
      //  submitBtn.updateButtonGradientFrame()
    }
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func resendOTPTapped(_ sender: Any) {
        
//        let param = ["email": emailId] as [String : Any]
//        self.callServiceMethod(service: Constants.Urls.sendVerificationCodeUrl,method: .post, params: param, key: "verifyEmailResendUrl", headers: [:])
        
    }
    @IBAction func submitBtnTapped(_ sender: Any) {
        
        if txtDPOTPView.text ?? "" == "" {
            self.showAnimatedToast(message: "Fields can't be empty")
            self.submitBtn.isEnabled = false
            self.submitBtn.backgroundColor = .gray
            
        }else{
            self.submitBtn?.showButtonLoading()
            
            self.submitBtn.isEnabled = true
            submitBtn.setButtonLeftRightGradientBackground(cornerRadius: 10,leftColor: .theme,rightColor: .themeSecondColor)

            let param =
            ["email" :  emailId,
             "email_code" : txtDPOTPView.text ?? ""] as [String : Any]
            
            self.callServiceMethod(service: Constants.Urls.verifyEmailUrl,method: .post, params: param, key: "verifyEmailUrl", headers: [:])
            
        }
    }
    func getCredentialsApiCall() {
        
        // Need token to get credentials
        
//        token = defaults.value(forKey: Constants.Keys.accessTokenKey) as? String ?? ""
//
//        let param = [:] as [String : Any]
//
//        let (headers, _, _) = APIHelper.createHeadersAndSignature(endpoint: "/get_credentials",params: param)
//
//        self.callServiceMethod(service: Constants.Urls.getCredentialsUrl,method: .get, params: param, key: "getCredentialsUrl", headers: headers)
        
    }
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck){
                if key == "verifyEmailResendUrl" {
                                        
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
                    
                    let defaults = UserDefaults.standard
                    self.dict = result!["data"] as? Dictionary
                    self.dictLocal = self.dict["user"] as! Dictionary
                    let token : String = self.dict["access_token"] as? String ?? ""
                    let qrCode : String = self.dict["qr_code_png"] as? String ?? ""
                    let google2fa_secret : String = self.dict["google2fa_secret"] as? String ?? ""
                    let api_key : String = self.dict["api_key"] as? String ?? ""
                    let salt_key : String = self.dict["salt_key"] as? String ?? ""
                    let private_key : String = self.dict["private_key"] as? String ?? ""
                    
                    let username = self.dictLocal["username"] as? String ?? ""
                    let userID : Int = self.dictLocal["user_id"] as? Int ?? 0
                    let emailId : String = self.dictLocal["email"] as? String ?? ""
                    let name : String = self.dictLocal["name"] as? String ?? ""
                    let firstName : String = self.dictLocal["first_name"] as? String ?? ""
                    let middleName : String = self.dictLocal["middle_name"] as? String ?? ""
                    let lastName : String = self.dictLocal["last_name"] as? String ?? ""
                    
                    let pic : String = self.dictLocal["picture"] as? String ?? ""
                    let loginBy : String = self.dictLocal["login_by"] as? String ?? ""
                    let gender : String = self.dictLocal["gender"] as? String ?? ""
                    let mobileNum = self.dictLocal["mobile"] as? String ?? ""
                    let pushNotiStatus : Int =  self.dictLocal["is_push_notification"] as? Int ?? 0
                    let emailNotiStatus : Int =  self.dictLocal["is_email_notification"] as? Int ?? 0
                    let userUniqueID : String = self.dictLocal["unique_id"] as? String ?? ""
                    let mobile_country_code : String = self.dictLocal["mobile_country_code"] as? String ?? ""
                    
                    let onboarding : Int = self.dictLocal["onboarding"] as? Int ?? 0
                    let user_type : Int = self.dictLocal["user_type"] as? Int ?? 0
                    
                    let email_status : Int = self.dictLocal["email_status"] as? Int ?? 0
                    
                    let errorCode = result!["code"] as? Int ?? 0
                    
                    defaults.set(token, forKey:Constants.Keys.accessTokenKey)
                    defaults.set(qrCode, forKey:Constants.Keys.qrCodeKey)
                    defaults.set(google2fa_secret, forKey:Constants.Keys.secretKey)
                    //                    defaults.set(api_key, forKey: Constants.Keys.apiKey)
                    //                    defaults.set(salt_key, forKey: Constants.Keys.saltKey)
                    defaults.set(private_key, forKey: Constants.Keys.private_key)
                    
                    defaults.set(firstName, forKey: Constants.Keys.firstNameKey)
                    defaults.set(middleName, forKey: Constants.Keys.middleNameKey)
                    defaults.set(lastName, forKey: Constants.Keys.lastNameKey)
                    defaults.set(emailId, forKey: Constants.Keys.emailIdKey)
                    defaults.set(name, forKey: Constants.Keys.userNameKey)
                    defaults.set(pic, forKey:Constants.Keys.userPicKey)
                    defaults.set(userID, forKey: Constants.Keys.userIdKey)
                    defaults.set(loginBy, forKey: Constants.Keys.loginTypeKey)
                    defaults.set(emailNotiStatus, forKey: Constants.Keys.emailNotiStatus)
                    defaults.set(pushNotiStatus, forKey: Constants.Keys.pushNotiStatus)
                    defaults.set(userUniqueID, forKey: Constants.Keys.userUniqueIdKey)
                    defaults.set(mobile_country_code, forKey: Constants.Keys.mobilecountrycodeKey)
                    defaults.set(onboarding, forKey: Constants.Keys.onboardingKey)
                  //  defaults.set(user_type, forKey: Constants.Keys.userTypeKey)
                    defaults.set(email_status, forKey: Constants.Keys.email_statusKey)
                    
                    defaults.synchronize()
                    self.submitBtn?.hideButtonLoading()
                    
                    self.getCredentialsApiCall()
                  
                } else if key == "getCredentialsUrl" {
                    
                    let defaults = UserDefaults.standard
                    self.dict = result!["data"] as? Dictionary
                    let client_id : String = self.dict["client_id"] as? String ?? ""
                    let client_secret : String = self.dict["client_secret"] as? String ?? ""
                    
                 //   defaults.set(client_id, forKey: Constants.Keys.clientIdKey)
                //    defaults.set(client_secret, forKey: Constants.Keys.clientSecretKey)
                    
                    self.delay(bySeconds: 0.0) {
                        
                        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
                        if let vc = sb.instantiateViewController(withIdentifier: "BubbleTabBarController") as? BubbleTabBarController {
                            self.defaults.set(true, forKey: Constants.Keys.isLoggedIn)
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
            else{
                self.submitBtn?.hideButtonLoading()
                
                let msg = result!["error"] as? String ?? ""
                if result!["error_code"] as? Int ?? 0 == 101 {
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
         //   self.submitBtn.setButtonLeftRightGradientBackground(cornerRadius: 10,leftColor: .theme,rightColor: .themeSecondColor)
            self.submitBtn.setTitleColor(.white, for: .normal)

        } else {
            self.submitBtn.isEnabled = false
          //  self.submitBtn.setButtonLeftRightGradientBackground(cornerRadius: 10,leftColor: .gray,rightColor: .gray)

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

