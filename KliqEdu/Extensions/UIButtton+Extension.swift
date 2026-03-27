//
//  UIButtton+Extension.swift
//  OurClub
//
//  Created by Aravinth Ramesh on 26/03/21.
//

import Foundation
import UIKit
import Lottie

//private var originalButtonText: String?
//private var activityIndicator: UIActivityIndicatorView!

private var lottieView: LottieAnimationView!
private var originalButtonText: String?

extension UIButton {

    func setBorderProperties1(borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat, masksToBounds: Bool) {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = masksToBounds
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
        if #available(iOS 13.0, *) {
            self.layer.backgroundColor = UIColor.systemBackground.cgColor
        } else {
            // Fallback on earlier versions
        }
        self.setTitleColor(.darkGray, for: .normal)
    }
    func underline() {
           guard let text = self.titleLabel?.text else { return }
           let attributedString = NSMutableAttributedString(string: text)
           //NSAttributedStringKey.foregroundColor : UIColor.blue
           attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
           attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
           attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
           self.setAttributedTitle(attributedString, for: .normal)
    }
    func addUnderline(color: UIColor = .blue, height: CGFloat = 2.0, spacing: CGFloat = 15.0, horizontalPadding: CGFloat = 10.0) {
        // Remove existing underline views if any
        self.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }

        guard let titleLabel = self.titleLabel else { return }

        titleLabel.sizeToFit()

        let underlineView = UIView()
        underlineView.backgroundColor = color
        underlineView.tag = 999

        // Add horizontal padding
        let underlineX = titleLabel.frame.origin.x - horizontalPadding
        let underlineWidth = titleLabel.frame.width + (horizontalPadding * 2)

        underlineView.frame = CGRect(
            x: underlineX,
            y: titleLabel.frame.maxY + spacing,
            width: underlineWidth,
            height: height
        )

        self.addSubview(underlineView)
    }
    
//    func showButtonLoading() {
//           originalButtonText = self.title(for: .normal)
//           self.setTitle("", for: .normal)
//           
//           if (activityIndicator == nil) {
//               activityIndicator = UIActivityIndicatorView(style: .medium)
//               activityIndicator.color = .theme // change if needed
//           }
//           
//           activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//           self.addSubview(activityIndicator)
//           
//           // Center the loader inside the button
//           NSLayoutConstraint.activate([
//               activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//               activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
//           ])
//           
//           activityIndicator.startAnimating()
//           self.isUserInteractionEnabled = false
//       }
//       
//       func hideButtonLoading() {
//           self.setTitle(originalButtonText, for: .normal)
//           activityIndicator.stopAnimating()
//           activityIndicator.removeFromSuperview()
//           self.isUserInteractionEnabled = true
//       }
    
    func showButtonLoading() {
        originalButtonText = self.title(for: .normal)
        self.setTitle("", for: .normal)
        
        if lottieView == nil {
            // Load your Lottie JSON file (e.g. "loader.json")
            lottieView = LottieAnimationView(name: "buttonloading")
            lottieView.loopMode = .loop
            lottieView.contentMode = .scaleAspectFit
        }

        // Clean up any old views
        lottieView.removeFromSuperview()
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lottieView)
        
        // Center the Lottie animation inside the button
        NSLayoutConstraint.activate([
            lottieView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            lottieView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            lottieView.heightAnchor.constraint(equalToConstant: 100),
            lottieView.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        lottieView.play()
        self.isUserInteractionEnabled = false
    }

    func hideButtonLoading() {
        if let original = originalButtonText {
            self.setTitle(original, for: .normal)
        }
        lottieView?.stop()
        lottieView?.removeFromSuperview()
        self.isUserInteractionEnabled = true
    }
}
import UIKit

extension UIButton {

    private struct AssociatedKeys {
        static var gradientLayer = "UIButtonGradientLayer"
    }

    private var gradientLayer: CAGradientLayer? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.gradientLayer) as? CAGradientLayer }
        set { objc_setAssociatedObject(self, &AssociatedKeys.gradientLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func setButtonLeftRightGradientBackground(cornerRadius: CGFloat,
                                              leftColor: UIColor,
                                              rightColor: UIColor) {

        // Remove previous gradient
        gradientLayer?.removeFromSuperlayer()

        let g = CAGradientLayer()
        g.colors = [leftColor.cgColor, rightColor.cgColor]
        g.startPoint = CGPoint(x: 0.0, y: 0.5)
        g.endPoint = CGPoint(x: 1.0, y: 0.5)
        g.cornerRadius = cornerRadius
        g.frame = bounds

        layer.insertSublayer(g, at: 0)
        gradientLayer = g

        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }

    /// Call in layoutSubviews to adjust gradient frame after AutoLayout.
    func updateButtonGradientFrame() {
        gradientLayer?.frame = bounds
        gradientLayer?.cornerRadius = layer.cornerRadius
    }
}
