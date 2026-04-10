//
//  StudentInfoVC.swift
//  KliqEdu
//
//  Created by codegama on 06/04/26.
//

import UIKit

class StudentInfoVC: UIViewController {

    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        self.idLbl.layer.cornerRadius = 15
        self.idLbl.layer.masksToBounds = true
        self.gradeLbl.layer.cornerRadius = 15
        self.gradeLbl.layer.masksToBounds = true
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
