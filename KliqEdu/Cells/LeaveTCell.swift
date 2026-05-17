//
//  LeaveTCell.swift
//  KliqEdu
//
//  Created by codegama on 06/04/26.
//

import UIKit

class LeaveTCell: UITableViewCell {

    @IBOutlet weak var placeHolderlbl: UILabel!
    @IBOutlet weak var datesLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var idNumberLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var leaveImg: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.statusLbl.layer.cornerRadius = 8
        self.statusLbl.layer.masksToBounds = true
        self.gradeLbl.layer.cornerRadius = 8
        self.gradeLbl.layer.masksToBounds = true
        self.placeHolderlbl.layer.cornerRadius = 10
        self.placeHolderlbl.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
