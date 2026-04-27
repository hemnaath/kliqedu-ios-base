//
//  AnnouncementDetailsVC.swift
//  KliqEdu
//
//  Created by codegama on 10/04/26.
//

import UIKit

class AnnouncementDetailsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    

}
