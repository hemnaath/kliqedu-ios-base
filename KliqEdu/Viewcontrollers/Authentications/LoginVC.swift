//
//  LoginVC.swift
//  KliqEdu
//
//  Created by codegama on 25/03/26.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailWarningLbl: UILabel!
    @IBOutlet weak var passwordWarningLbl: UILabel!
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var passwordShowBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.setLeftPaddingPoints(12)
        self.passwordField.setLeftPaddingPoints(12)
        loginView.roundTopCorners(radius: 50)

        self.emailWarningLbl.hide()
        self.passwordWarningLbl.hide()
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
        if !isValid {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
