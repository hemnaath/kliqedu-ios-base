//
//  UITextView Extention.swift
//  ECommerce
//
//  Created by Karthick RJ on 05/09/22.
//

import Foundation
import UIKit

extension UITextView{
    
    func setLeftPaddingPoints1(_ amount:CGFloat){
        
        let color = Constants.CommonColors.theameGreenColor.cgColor

//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
//        self.leftAnchor = paddingView
//        self.leftViewMode = .always
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1.5
        self.tintColor = UIColor.white
        
        layer.cornerRadius = 5
        if #available(iOS 13.0, *) {
            layer.shadowColor = UIColor.systemGray5.cgColor
        } else {
            layer.shadowColor = UIColor.darkGray.cgColor
        }
        layer.shadowOpacity = 5
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.masksToBounds = false

       // dropSffpfppfphadow()
        if #available(iOS 13.0, *) {
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            // Fallback on earlier versions
        }
//        //self.layer.masksToBounds = true
//        let placeholder = self.placeholder ?? "" //There should be a placeholder set in storyboard or elsewhere string or pass empty
//        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    }
}
