//
//  EditProfileVC.swift
//  KliqEdu
//
//  Created by codegama on 29/04/26.
//

import UIKit

class EditProfileVC: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var bgField: UITextField!
    @IBOutlet weak var mobileField: UITextField!
    @IBOutlet weak var addressField: UITextField!

    
    @IBOutlet weak var dobWarningLbl: UILabel!
    @IBOutlet weak var nameWarningLbl: UILabel!
    @IBOutlet weak var bgWarningLbl: UILabel!
    @IBOutlet weak var mobileWarningLbl: UILabel!
    @IBOutlet weak var addressWarningLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameWarningLbl.hide()
        self.dobWarningLbl.hide()
        self.bgWarningLbl.hide()
        self.mobileWarningLbl.hide()
        self.addressWarningLbl.hide()
        
        self.nameField.setLeftPaddingPoints(12)
        self.dobField.setLeftPaddingPoints(12)
        self.bgField.setLeftPaddingPoints(12)
        self.mobileField.setLeftPaddingPoints(12)
        self.addressField.setLeftPaddingPoints(12)
    }
    

    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

}
