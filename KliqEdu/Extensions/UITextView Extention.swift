//
//  UITextView Extention.swift
//  ECommerce
//
//  Created by Karthick RJ on 05/09/22.
//

import Foundation
import UIKit

extension UITextView{
    
    func setPaddingTextView(_ amount:CGFloat){
        
        // Apply left padding
        self.textContainerInset = UIEdgeInsets(top: amount,
                                               left: amount,
                                               bottom: amount,
                                               right: amount)
        // Remove default internal padding so left inset is accurate
        self.textContainer.lineFragmentPadding = 0
        
        self.tintColor = UIColor.black
        
        if #available(iOS 13.0, *) {
            layer.shadowColor = UIColor.systemGray5.cgColor
        } else {
            layer.shadowColor = UIColor.darkGray.cgColor
        }
        layer.shadowOpacity = 5
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.masksToBounds = false
        
        if #available(iOS 13.0, *) {
            self.layer.borderColor = UIColor.black.cgColor
        } else {
            // Fallback on earlier versions
        }

    }
    
    private struct AssociatedKeys {
        static var placeholderLabel = "placeholderLabel"
    }
    
    private var placeholderLabel: UILabel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabel) as? UILabel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.placeholderLabel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setPlaceholder(_ text: String, color: UIColor = .lightGray) {
        
        if placeholderLabel == nil {
            let label = UILabel()
            label.numberOfLines = 0
            // Apply custom font if available, else fallback
            label.font = self.font ?? UIFont(name: GLOBAL.FontsIdentifier.RedHatDisplayRegular, size: 20) ?? UIFont.systemFont(ofSize: 20)
            label.textColor = color
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
                label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
            ])
            
            placeholderLabel = label
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(textDidChange),
                name: UITextView.textDidChangeNotification,
                object: self
            )
        }
        
        placeholderLabel?.text = text
        // Ensure placeholder uses same font as textView if updated later
        placeholderLabel?.font = self.font ?? placeholderLabel?.font
        placeholderLabel?.isHidden = !self.text.isEmpty
    }
    
    @objc private func textDidChange() {
        placeholderLabel?.isHidden = !self.text.isEmpty
    }
}
