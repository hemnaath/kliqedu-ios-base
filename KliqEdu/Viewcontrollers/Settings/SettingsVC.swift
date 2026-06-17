//
//  SettingsVC.swift
//  KliqEdu
//
//  Created by codegama on 15/04/26.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var switchStudentView: UIView!
    var childrensArr: [ChildrensModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: Constants.Keys.childrenArrayKey),
           let array = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            self.childrensArr = ChildrensModel.modelsFromDictionaryArray(array: array as NSArray)
        }
        if roleKey == "parent"{
            if childrensArr.count > 1{
                self.switchStudentView.unhide()
            }else{
                self.switchStudentView.hide()
            }
            self.editProfileView.hide()
        }else{
            self.switchStudentView.hide()
            self.editProfileView.unhide()

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
    @IBAction func configurationBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ConfigurationsVC") as? ConfigurationsVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
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
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "WebviewVC") as? WebviewVC {
            
            vc.docFile = "https://kliqedu.com/contact-us"
            vc.titel = "Help & Support"
            vc.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func contactTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "WebviewVC") as? WebviewVC {
            
            vc.docFile = "https://kliqedu.com/contact-us"
            vc.titel = "Contact Us"
            vc.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func termTapped(_ sender: Any) {
//        let storyBoard = UIStoryboard(name: Constants.StoryboardIds.settingsSB, bundle: nil)
//        if let vc = storyBoard.instantiateViewController(withIdentifier: "StaticPagesVC") as? StaticPagesVC {
//            vc.heading = "Terms & Conditions"
//            vc.pageType = "terms-and-conditions"
//            vc.hidesBottomBarWhenPushed = true
//
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "WebviewVC") as? WebviewVC {
            
            vc.docFile = "https://kliqedu.com/terms-of-service"
            vc.titel = "Terms & Conditions"
            vc.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(vc, animated: true)
        }

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
