//
//  HomeworkViewVC.swift
//  KliqEdu
//
//  Created by codegama on 13/04/26.
//

import UIKit

class HomeworkViewVC: UIViewController {

    @IBOutlet weak var subjectLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.subjectLbl.layer.cornerRadius = 10
        self.subjectLbl.layer.masksToBounds = true
    }
    

    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

}
