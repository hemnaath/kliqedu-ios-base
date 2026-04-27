//
//  ForgotPasswordVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var emailWarningLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.emailField.setLeftPaddingPoints(12)
        self.emailWarningLbl.hide()

        // Do any additional setup after loading the view.
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ResetPasswordVC") as? ResetPasswordVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
