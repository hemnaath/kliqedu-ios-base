//
//  ChatRecieverTCell.swift
//  OurClub
//
//  Created by Karthick RJ on 27/05/21.
//

import UIKit

class ChatRecieverTCell: UITableViewCell {

    //MARK: Variable
    
    //MARK: Outlets
  
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var updatedLbl: UILabel!
    @IBOutlet weak var bubbleViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        bubbleView.roundThreeCorners(radius: 15)
    }
    func configureMoreCellWith(list : SingleChatModel, indexPath : IndexPath) {
        

    }
}
