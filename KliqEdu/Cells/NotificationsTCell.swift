//
//  NotificationsTCell.swift
//  KliqEdu
//
//  Created by codegama on 09/04/26.
//

import UIKit

class NotificationsTCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateLbl.layer.cornerRadius = 8
        self.dateLbl.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
