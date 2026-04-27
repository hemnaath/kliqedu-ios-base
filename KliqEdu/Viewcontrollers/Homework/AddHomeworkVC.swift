//
//  AddHomeworkVC.swift
//  KliqEdu
//
//  Created by codegama on 13/04/26.
//

import UIKit

class AddHomeworkVC: UIViewController {

    @IBOutlet weak var attachmentOuterview: UIView!
    @IBOutlet weak var descriptionTextview: UITextView!
    @IBOutlet weak var titleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.setLeftPaddingPoints(12)
        descriptionTextview.setPlaceholder("  Provide a detailed instruction here")
        descriptionTextview.setPaddingTextView(12)
    }
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        attachmentOuterview.addDashedBorder(borderColor: .theme, cornerRadius: 10)
       
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

}
