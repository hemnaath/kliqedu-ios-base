//
//  PaddedLabel.swift
//  CityPlots-App
//
//  Created by Karthick RJ on 24/02/25.
//

import Foundation
import UIKit

@IBDesignable
class PaddedLabel: UILabel {
    @IBInspectable var leftPadding: CGFloat = 10
    @IBInspectable var rightPadding: CGFloat = 10

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftPadding + rightPadding, height: size.height)
    }
}
