//
//  SettingsVC.swift
//  KliqEdu
//
//  Created by codegama on 15/04/26.
//

import UIKit

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func profileInfoTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {

            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func editProfileTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {

            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
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
}
