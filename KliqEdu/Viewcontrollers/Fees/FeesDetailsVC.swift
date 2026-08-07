//
//  FeesDetailsVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit

class FeesDetailsVC: UIViewController {
    @IBOutlet weak var gradeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gradeLbl.layer.cornerRadius = 15
        self.gradeLbl.layer.masksToBounds = true
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func copyBtnTapped(_ sender: Any) {
        UIPasteboard.general.string = "#INV000123456"
        self.showAnimatedToast(message: "Invoice ID Copied")
    }
   

}
