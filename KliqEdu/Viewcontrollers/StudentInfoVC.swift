//
//  StudentInfoVC.swift
//  KliqEdu
//
//  Created by codegama on 06/04/26.
//

import UIKit

class StudentInfoVC: UIViewController {

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    
    var comingFrom = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        self.idLbl.layer.cornerRadius = 15
        self.idLbl.layer.masksToBounds = true
        self.gradeLbl.layer.cornerRadius = 15
        self.gradeLbl.layer.masksToBounds = true
        
        if comingFrom == "home"{
            self.editBtn.unhide()
        }else{
            self.editBtn.hide()

        }
    }
    @IBAction func editBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "EditStudentProfileVC") as? EditStudentProfileVC {

            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }


}
