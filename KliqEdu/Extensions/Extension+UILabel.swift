//
//  Extension+UILabel.swift
//  Gambol
//
//  Created by Krishnendu Biswas on 22/05/20.
//  Copyright © 2019 Krishnendu Biswas. All rights reserved.
//

import UIKit
let badgeSize: CGFloat = 20
let badgeTag = 9830384

extension UILabel{
    
    convenience init(text: String? = nil, font: UIFont? = nil, numberOfLines: Int? = nil, textColor: UIColor? = nil, textAlligment: NSTextAlignment? = nil) {
        self.init(frame: .zero)
        self.text = text
        self.font = font
        self.numberOfLines = numberOfLines ?? 0
        self.textColor = textColor
        self.textAlignment = textAlligment ?? .left
    }
    func set(text: String, withKerning kerning: CGFloat) {
          let attributedString = NSMutableAttributedString(string: text)

          // The value parameter defines your spacing amount, and range is
          // the range of characters in your string the spacing will apply to.
          // Here we want it to apply to the whole string so we take it from 0 to text.count.
          attributedString.addAttribute(NSAttributedString.Key.kern, value: kerning, range: NSMakeRange(0, text.count))

          attributedText = attributedString
      }
    func badgeLabel(withCount count: Int) -> UILabel {
        let badgeCount = UILabel(frame: CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize))
        badgeCount.translatesAutoresizingMaskIntoConstraints = false
        badgeCount.tag = badgeTag
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(12)
        badgeCount.backgroundColor = .systemRed
        badgeCount.text = String(count)
        return badgeCount
    }
    // MARK: - spacingValue is spacing that you need
    func addInterlineSpacing(spacingValue: CGFloat = 5, alignment: NSTextAlignment = .left) {

        // MARK: - Check if there's any text
        guard let textString = text else { return }

        // MARK: - Create "NSMutableAttributedString" with your text
        let attributedString = NSMutableAttributedString(string: textString)

        // MARK: - Create instance of "NSMutableParagraphStyle"
        let paragraphStyle = NSMutableParagraphStyle()

        // MARK: - Actually adding spacing and alignment to ParagraphStyle
        paragraphStyle.lineSpacing = spacingValue
        paragraphStyle.alignment = alignment

        // MARK: - Adding ParagraphStyle to your attributed String
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )

        // MARK: - Assign string that you've modified to current attributed Text
        attributedText = attributedString
    }
    func applyPadding(_ insets: UIEdgeInsets) {
        guard let currentText = text else { return }
        let paddedLabel = UILabel(frame: CGRect(x: insets.left, y: insets.top, width: frame.size.width - insets.left - insets.right, height: frame.size.height - insets.top - insets.bottom))
        paddedLabel.text = currentText
        paddedLabel.font = font
        paddedLabel.textColor = textColor
        paddedLabel.backgroundColor = backgroundColor
        addSubview(paddedLabel)
    }
}
