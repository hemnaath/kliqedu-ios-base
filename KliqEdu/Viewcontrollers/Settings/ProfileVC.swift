//
//  ProfileVC.swift
//  KliqEdu
//
//  Created by codegama on 27/03/26.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var positionLbl: UILabel!
    @IBOutlet weak var personalView: UIView!
    @IBOutlet weak var empView: UIView!
    @IBOutlet weak var empDetailsBtn: UIButton!
    @IBOutlet weak var personalDetailsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        self.positionLbl.layer.cornerRadius = 17.5
        self.positionLbl.layer.masksToBounds = true
        
        empDetailsBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        personalDetailsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.personalView.isHidden = true
        self.empView.isHidden = false
        // Do any additional setup after loading the view.
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func empDetailsBtnTapped(_ sender: Any) {
        empDetailsBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        personalDetailsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.personalView.isHidden = true
        self.empView.isHidden = false
    }
    @IBAction func personalDetailsBtnTapped(_ sender: Any) {
        empDetailsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        personalDetailsBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        self.personalView.isHidden = false
        self.empView.isHidden = true
    }

}
