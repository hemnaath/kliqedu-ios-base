//
//  ChangePasswordVC.swift
//  KliqEdu
//
//  Created by codegama on 16/04/26.
//

import UIKit

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var oldpasswordField: UITextField!
    @IBOutlet weak var newpasswordField: UITextField!
    @IBOutlet weak var confirmpasswordField: UITextField!
    @IBOutlet weak var currentPasswordShowBtn: UIButton!
    @IBOutlet weak var newPasswordBtn: UIButton!
    @IBOutlet weak var confirmPasswordBtn: UIButton!
    @IBOutlet weak var currentpasswordWarningLbl: UILabel!
    @IBOutlet weak var newPassWarningLbl: UILabel!
    @IBOutlet weak var confirmNewPassWarningLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.oldpasswordField.setLeftPaddingPoints(12)
        self.newpasswordField.setLeftPaddingPoints(12)
        self.confirmpasswordField.setLeftPaddingPoints(12)

        self.currentpasswordWarningLbl.hide()
        self.newPassWarningLbl.hide()
        self.confirmNewPassWarningLbl.hide()

    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
}
