//
//  FeesDetailsVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit

class FeesDetailsVC: UIViewController {
    @IBOutlet weak var studentPic: UIImageView!
    @IBOutlet weak var staudentNameLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
    
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    
    @IBOutlet weak var feesTypeLbl: UILabel!
    @IBOutlet weak var invoiceIdLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    var feeDetails = FeesModel(dictionary: [:])

    override func viewDidLoad() {
        super.viewDidLoad()

        self.gradeLbl.layer.cornerRadius = 15
        self.gradeLbl.layer.masksToBounds = true
        
        self.feesTypeLbl.text = self.feeDetails?.fee_type
        self.staudentNameLbl.text = self.feeDetails?.student_name
        self.gradeLbl.text = "Grade \(self.feeDetails?.student_grade ?? "")"
        self.invoiceIdLbl.text = self.feeDetails?.unique_id ?? ""
        self.dateLbl.text = self.feeDetails?.due_date
        self.amountLbl.text = "\(self.feeDetails?.remaining_amount ?? "")"
        
        self.statusLbl.text = self.feeDetails?.status

        let status = self.feeDetails?.status ?? ""

        switch status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {

        case "pending":
            statusImg.image = UIImage(systemName: "clock.fill")
            statusView.backgroundColor = .systemOrange.withAlphaComponent(0.15)
            statusLbl.textColor = .systemOrange
            statusImg.tintColor = .systemOrange
        case "success", "paid":
            statusImg.image = UIImage(systemName: "checkmark.circle.fill")
            statusView.backgroundColor = .systemGreen.withAlphaComponent(0.15)
            statusLbl.textColor = .systemGreen
            statusImg.tintColor = .systemGreen

        case "failed":
            statusImg.image = UIImage(systemName: "xmark.circle.fill")
            statusView.backgroundColor = .systemRed.withAlphaComponent(0.15)
            statusLbl.textColor = .systemRed
            statusImg.tintColor = .systemRed

        case "overdue":
            statusImg.image = UIImage(systemName: "exclamationmark.triangle.fill")
            statusView.backgroundColor = .systemPurple.withAlphaComponent(0.15)
            statusLbl.textColor = .systemPurple
            statusImg.tintColor = .systemPurple

        case "partial":
            statusImg.image = UIImage(systemName: "minus.circle.fill")
            statusView.backgroundColor = .systemBlue.withAlphaComponent(0.15)
            statusLbl.textColor = .systemBlue
            statusImg.tintColor = .systemBlue

        default:
            statusImg.image = UIImage(systemName: "clock.fill")
        }
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func copyBtnTapped(_ sender: Any) {
        UIPasteboard.general.string = self.feeDetails?.unique_id ?? ""
        self.showAnimatedToast(message: "Invoice ID Copied")
    }
 

}
