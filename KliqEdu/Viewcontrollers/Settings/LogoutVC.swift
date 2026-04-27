//
//  LogoutVC.swift
//  KliqEdu
//
//  Created by codegama on 16/04/26.
//

import UIKit

class LogoutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
        self.performLogout(Vc: self, isForcefull: false)
    }
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
