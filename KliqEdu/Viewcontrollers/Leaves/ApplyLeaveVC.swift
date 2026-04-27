//
//  ApplyLeaveVC.swift
//  KliqEdu
//
//  Created by codegama on 08/04/26.
//

import UIKit

class ApplyLeaveVC: UIViewController {

    @IBOutlet weak var reasonTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reasonTextView.setPlaceholder("  Provide a brief reason for your request")
        reasonTextView.setPaddingTextView(12)
    }

    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
}
