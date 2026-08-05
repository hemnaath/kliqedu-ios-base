//
//  ChatSenderTCell.swift
//  OurClub
//
//  Created by Karthick RJ on 27/05/21.
//

import UIKit

class ChatSenderTCell: UITableViewCell {

    //MARK: Variable
    
    //MARK: Outlets
    
 
    @IBOutlet weak var bubbleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var updatedLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        bubbleView.roundThreeCorners1(radius: 15.0)

    }
   
}
