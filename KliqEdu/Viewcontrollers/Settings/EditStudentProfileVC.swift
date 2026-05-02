//
//  EditStudentProfileVC.swift
//  KliqEdu
//
//  Created by codegama on 01/05/26.
//

import UIKit

class EditStudentProfileVC: UIViewController {

    @IBOutlet weak var firstNameWarningLbl: UILabel!
    @IBOutlet weak var lastNameWarningLbl: UILabel!
    @IBOutlet weak var dobWarningLbl: UILabel!
    @IBOutlet weak var genderWarningLbl: UILabel!
    @IBOutlet weak var bgWarningLbl: UILabel!
    @IBOutlet weak var religionWarningLbl: UILabel!
    @IBOutlet weak var casteWarningLbl: UILabel!
    @IBOutlet weak var addressWarningLbl: UILabel!
    @IBOutlet weak var fatherNameWarningLbl: UILabel!
    @IBOutlet weak var motherNameWarningLbl: UILabel!
    @IBOutlet weak var fatherMobileWarningLbl: UILabel!
    @IBOutlet weak var motherMobileWarningLbl: UILabel!
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var bgField: UITextField!
    @IBOutlet weak var religionField: UITextField!
    @IBOutlet weak var casteField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var fatherNameField: UITextField!
    @IBOutlet weak var motherNameField: UITextField!
    @IBOutlet weak var fatherMobileField: UITextField!
    @IBOutlet weak var motherMobileField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.firstNameWarningLbl.hide()
        self.lastNameWarningLbl.hide()
        self.dobWarningLbl.hide()
        self.genderWarningLbl.hide()
        self.bgWarningLbl.hide()
        self.religionWarningLbl.hide()
        self.casteWarningLbl.hide()
        self.addressWarningLbl.hide()
        self.fatherNameWarningLbl.hide()
        self.motherNameWarningLbl.hide()
        self.fatherMobileWarningLbl.hide()
        self.motherMobileWarningLbl.hide()
       
        
        self.firstNameField.setLeftPaddingPoints(12)
        self.lastNameField.setLeftPaddingPoints(12)
        self.dobField.setLeftPaddingPoints(12)
        self.genderField.setLeftPaddingPoints(12)
        self.bgField.setLeftPaddingPoints(12)
        self.religionField.setLeftPaddingPoints(12)
        self.casteField.setLeftPaddingPoints(12)
        self.addressField.setLeftPaddingPoints(12)
        self.fatherNameField.setLeftPaddingPoints(12)
        self.motherNameField.setLeftPaddingPoints(12)
        self.fatherMobileField.setLeftPaddingPoints(12)
        self.motherMobileField.setLeftPaddingPoints(12)

    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

}
