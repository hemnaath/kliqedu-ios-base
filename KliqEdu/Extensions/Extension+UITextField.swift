//
//  Extension+UITextField.swift
//  Gambol
//
//  Created by Krishnendu Biswas on 22/05/20.
//  Copyright © 2019 Krishnendu Biswas. All rights reserved.
//

import UIKit

extension UITextField{
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.tintColor = .lightGray
    }
    func setLeftPaddingPointsForEditProfile(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.tintColor = .black
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    func addBottomBorder(){
           let bottomLine = CALayer()
           bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
           bottomLine.backgroundColor = UIColor.lightGray.cgColor
           borderStyle = .none
           layer.addSublayer(bottomLine)
       }
    func setLeftPaddingPoints1(_ amount:CGFloat){

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1.5
        self.tintColor = UIColor.black
        
        layer.cornerRadius = 5
        layer.masksToBounds = false
        layer.borderColor = UIColor.systemGray5.cgColor
        layer.borderWidth = 1

       // dropShadow()
        if #available(iOS 13.0, *) {
            self.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            // Fallback on earlier versions
        }
        //self.layer.masksToBounds = true
        let placeholder = self.placeholder ?? "" //There should be a placeholder set in storyboard or elsewhere string or pass empty
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    }
    
    func cornerRadius(value: CGFloat) {
        self.layer.cornerRadius = value
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.systemGray4.cgColor
        self.layer.masksToBounds = true
        self.textColor = .black
        let color = UIColor.black
        let placeholder = self.placeholder ?? "" //There should be a placeholder set in storyboard or elsewhere string or pass empty
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : color])
        self.textAlignment = .left
        
    }
    func set(placeholder: String, withFont font: UIFont?, withColor color: UIColor?){
        var attributes = [NSAttributedString.Key: NSObject]()
        if let font = font{
            attributes[NSAttributedString.Key.font] = font
        }
        if let placeholderColor = color {
            attributes[NSAttributedString.Key.foregroundColor] = placeholderColor
        }
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
}
