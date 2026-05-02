//
//  CreateAnnouncementVC.swift
//  KliqEdu
//
//  Created by codegama on 29/04/26.
//

import UIKit

class CreateAnnouncementVC: UIViewController {

    @IBOutlet weak var descriptionTextview: UITextView!
    @IBOutlet weak var titleField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        titleField.setLeftPaddingPoints(12)
        descriptionTextview.setPlaceholder("  Provide a detailed instruction here")
        descriptionTextview.setPaddingTextView(12)
    }

    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
}
