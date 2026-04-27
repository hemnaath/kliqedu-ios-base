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
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "LogoutVC") as? LogoutVC {
            
            vc.modalPresentationStyle = .popover
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
    
            present(vc, animated: true)
        }
    }
}
