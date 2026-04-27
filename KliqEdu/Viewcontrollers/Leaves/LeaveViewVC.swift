//
//  LeaveViewVC.swift
//  KliqEdu
//
//  Created by codegama on 07/04/26.
//

import UIKit

class LeaveViewVC: UIViewController {

    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.gradeLbl.layer.cornerRadius = 10
        self.gradeLbl.layer.masksToBounds = true
        self.statusLbl.layer.cornerRadius = 10
        self.statusLbl.layer.masksToBounds = true
        
        self.statusLbl.tintColor = .systemOrange
        self.statusLbl.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        // Do any additional setup after loading the view.
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

}
