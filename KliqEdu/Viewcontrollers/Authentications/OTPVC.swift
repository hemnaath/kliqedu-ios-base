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
        
        let param = ["email": defaults.value(forKey: Constants.Keys.emailIdKey) ?? "",
                     "role": defaults.value(forKey: Constants.Keys.roleKey) ?? ""] as [String : Any]
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
            ["email" : defaults.value(forKey: Constants.Keys.emailIdKey) ?? "",
             "otp" : txtDPOTPView.text ?? "",
             "role": defaults.value(forKey: Constants.Keys.roleKey) ?? ""] as [String : Any]
            
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
                    
                    self.dict = result!["data"] as? Dictionary
                    
                    self.submitBtn?.hideButtonLoading()
                    
                    let msg = result!["message"] as? String ?? ""
                    self.showAnimatedToast(message: msg)
                    self.navigationController?.popViewController(animated: true)

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

