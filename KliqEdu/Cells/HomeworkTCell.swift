//
//  HomeworkTCell.swift
//  KliqEdu
//
//  Created by codegama on 13/04/26.
//

import UIKit

class HomeworkTCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var gradelbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.gradelbl.dropShadow()
        self.gradelbl.layer.cornerRadius = 15
        self.gradelbl.layer.masksToBounds = true
        self.subjectLbl.layer.cornerRadius = 8
        self.subjectLbl.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
