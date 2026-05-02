//
//  TeachersTCell.swift
//  KliqEdu
//
//  Created by codegama on 28/04/26.
//

import UIKit

class TeachersTCell: UITableViewCell {

    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var teacherPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.subjectLbl.layer.cornerRadius = 8
        self.subjectLbl.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
