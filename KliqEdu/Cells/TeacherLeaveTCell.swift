//
//  TeacherLeaveTCell.swift
//  KliqEdu
//
//  Created by codegama on 28/04/26.
//

import UIKit

class TeacherLeaveTCell: UITableViewCell {

    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryOuterView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.statusLbl.layer.cornerRadius = 8
        self.statusLbl.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
