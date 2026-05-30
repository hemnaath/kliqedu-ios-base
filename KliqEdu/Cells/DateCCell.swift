//
//  DateCCell.swift
//  KliqEdu
//
//  Created by codegama on 17/05/26.
//

import UIKit

class DateCCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var dayLbl: UILabel!
    
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = 15
        
        
    }
    
    func configure(data: DateModel) {
        
        
        
    }
}
