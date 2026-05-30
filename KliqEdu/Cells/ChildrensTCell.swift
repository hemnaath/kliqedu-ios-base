//
//  ChildrensTCell.swift
//  KliqEdu
//
//  Created by codegama on 19/05/26.
//

import UIKit

class ChildrensTCell: UITableViewCell {

    @IBOutlet weak var placeHolderlbl: UILabel!
    @IBOutlet weak var radioBtn: UIButton!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var studentPicture: UIImageView!
    
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
