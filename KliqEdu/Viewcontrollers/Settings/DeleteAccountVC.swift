//
//  DeleteAccountVC.swift
//  KliqEdu
//
//  Created by codegama on 16/04/26.
//

import UIKit

class DeleteAccountVC: UIViewController {

    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordField.setLeftPaddingPoints(12)
        self.warningLbl.hide()

    }

    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

}
