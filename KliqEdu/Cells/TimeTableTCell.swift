//
//  TimeTableTCell.swift
//  KliqEdu
//
//  Created by codegama on 06/08/26.
//

import UIKit

class TimeTableTCell: UITableViewCell {

    @IBOutlet weak var breakImage: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var intervelTimeLbl: UILabel!
    @IBOutlet weak var teacherNameLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var periodNumberLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.intervelTimeLbl.layer.cornerRadius = 8
        self.intervelTimeLbl.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
