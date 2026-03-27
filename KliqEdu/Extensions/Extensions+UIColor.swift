//
//  Extensions+UIColor.swift
//  OnlyAlly
//
//  Created by Karthick RJ on 20/04/21.
//

import Foundation
import UIKit

extension UIColor{
    
    /**
     This initializer initialise UIColor from a valid hex color string
     
     *Value*
     
     `hex:` The hex color string from where UIColor instance to be created.
     */
    
    convenience init(hex:String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static let themeColor : UIColor = {
        return UIColor(hex: "#7367F0")
    }()
    static let themeSecondColor : UIColor = {
        return UIColor(hex: "#4B4E99")
    }()
    static let themeLiteColor : UIColor = {
        return UIColor(hex: "#4F4BAC").withAlphaComponent(7)
    }()
    static let liteWhite : UIColor = {
        return UIColor(hex: "#E0E0E0")
    }()

}
