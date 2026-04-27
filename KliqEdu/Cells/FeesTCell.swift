//
//  FeesTCell.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit

class FeesTCell: UITableViewCell {

    @IBOutlet weak var amtLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dueLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.statusLbl.layer.cornerRadius = 12.5
        self.statusLbl.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
