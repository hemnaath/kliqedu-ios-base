//
//  SettingsVC.swift
//  KliqEdu
//
//  Created by codegama on 15/04/26.
//

import UIKit
import LocalAuthentication

class SettingsVC: UIViewController {

    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var switchStudentView: UIView!
    @IBOutlet weak var faceIDSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        faceIDSwitch.isEnabled = isFaceIDAvailable()
        faceIDSwitch.isOn = UserDefaults.standard.bool(forKey: Constants.Keys.faceID)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if roleKey == "parent"{
            self.switchStudentView.unhide()
            self.editProfileView.hide()
        }else{
            self.switchStudentView.hide()
            self.editProfileView.unhide()

        }
    }
    @IBAction func faceIDSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            enableFaceID()
        } else {
            disableFaceID()
        }
    }
       
    @IBAction func profileInfoTapped(_ sender: Any) {
        if roleKey == "parent"{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ParentProfileVC") as? ParentProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @IBAction func editProfileTapped(_ sender: Any) {
        if roleKey == "parent"{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @IBAction func switchAccTapped(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = true

        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "SwitchAccountVC") as? SwitchAccountVC {
            
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical   // animation
            vc.onDismiss = { [weak self] in
                   self?.tabBarController?.tabBar.isHidden = false
                let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                     vc.selectedIndex = 0
                    vc.hidesBottomBarWhenPushed = true

                    self?.navigationController?.pushViewController(vc, animated: true)
                }
               }
            vc.onDismiss1 = { [weak self] in
                   self?.tabBarController?.tabBar.isHidden = false
                
               }
    
            present(vc, animated: true)
        }
    }
    @IBAction func changePasswordTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC {
            
//            vc.bankId = dataModel.unique_id ?? ""
//            vc.accStatus = dataModel.status_formatted ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func deleteAccTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "DeleteAccountVC") as? DeleteAccountVC {

            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func helpTapped(_ sender: Any) {

    }
    
    @IBAction func contactTapped(_ sender: Any) {
    }
    @IBAction func termTapped(_ sender: Any) {
    }
    @IBAction func logoutTapped(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = true

        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "LogoutVC") as? LogoutVC {
            
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical   // animation
            vc.onDismiss = { [weak self] in
                   self?.tabBarController?.tabBar.isHidden = false
               }
    
            present(vc, animated: true)
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
