//
//  ResetPasswordVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var passwordWarningLbl: UILabel!
    @IBOutlet weak var confirmPassWarningLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.newPasswordField.setLeftPaddingPoints(12)
        self.confirmPasswordField.setLeftPaddingPoints(12)

        self.passwordWarningLbl.hide()
        self.confirmPassWarningLbl.hide()

    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func resetPasswordBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    

}
