//
//  StudentListTCell.swift
//  KliqEdu
//
//  Created by codegama on 29/03/26.
//

import UIKit

class StudentListTCell: UITableViewCell {

    @IBOutlet weak var placeHolderlbl: UILabel!
    @IBOutlet weak var studentPic: UIImageView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var idNumberLbl: UILabel!
    @IBOutlet weak var classLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.classLbl.layer.cornerRadius = 8
        self.classLbl.layer.masksToBounds = true
        self.placeHolderlbl.layer.cornerRadius = 35
        self.placeHolderlbl.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
