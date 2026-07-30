//
//  SelectTeacherTCell.swift
//  KliqEdu
//
//  Created by codegama on 13/07/26.
//

import UIKit

class SelectTeacherTCell: UITableViewCell {

    @IBOutlet weak var placeHolderlbl: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.placeHolderlbl.layer.cornerRadius = 35
        self.placeHolderlbl.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
