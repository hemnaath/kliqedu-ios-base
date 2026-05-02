//
//  SwitchAccountVC.swift
//  KliqEdu
//
//  Created by codegama on 01/05/26.
//

import UIKit

class SwitchAccountVC: UIViewController {

    @IBOutlet weak var acc1Btn: UIButton!
    @IBOutlet weak var acc2Btn: UIButton!
    
    var onDismiss: (() -> Void)?
    var onDismiss1: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = .clear
        
        self.delay(bySeconds: 0.25) { [weak self] in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.5)
            }
        }
    }
    

    @IBAction func acc1Tapped(_ sender: Any) {
        self.acc1Btn.isSelected = true
        self.acc2Btn.isSelected = false
    }
    @IBAction func acc2Tapped(_ sender: Any) {
        self.acc1Btn.isSelected = false
        self.acc2Btn.isSelected = true
    }
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.onDismiss1?()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss1?()
    }
    @IBAction func switchTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.onDismiss?()
        }
    }
}
