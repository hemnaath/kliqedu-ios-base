//
//  Extension+UIView.swift
//  Gambol
//
//  Created by Krishnendu Biswas on 22/05/20.
//  Copyright © 2019 Krishnendu Biswas. All rights reserved.
//

import UIKit
import SkeletonView

struct AnchoredConstraints {
    var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
}

extension UIView{
    
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }
    
    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        //  gradient.frame.size = button.frame.size
        gradient.colors =
        [UIColor.white.cgColor,UIColor.green.withAlphaComponent(1).cgColor]
        //Use diffrent colors
        
        gradient.frame.size = self.bounds.size
        //   gradient.colors = colours.map { $0.cgColor }
        //            gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradient
    }
    func setGradientBackground() {
        let colorTop = UIColor(hex: "#FFCB01")
        let colorBottom = UIColor(hex: "#FF9A01")
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 10
        //        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        //        self.layer.shadowOpacity = 0.3
        //        self.layer.shadowRadius = 3.0
        //        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    func applyVerticalLigtGradient() {
        let topColor = UIColor(hex: "#E3DEFD").withAlphaComponent(0.6) // #D4EDFF
        let bottomColor = UIColor(hex: "#FFFFFF")
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        
        gradientLayer.locations = [0.0, 0.8]
        
        // Top → Bottom
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        gradientLayer.frame = self.bounds
        
        // Remove existing gradients
        self.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    func setBorderProperties(borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat, masksToBounds: Bool) {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = masksToBounds
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
        
    }
    func setBorderProperties2(borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat, masksToBounds: Bool,backgroundColor: UIColor) {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = masksToBounds
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
        self.layer.backgroundColor = backgroundColor.cgColor
        
    }
    convenience init(backgroundColor: UIColor? = nil, cornerRadius: CGFloat? = nil){
        self.init()
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius ?? 0
        self.backgroundColor = backgroundColor
    }
    
    func roundTopCorners(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if #available(iOS 13.0, *) {
            layer.shadowColor = UIColor.clear.cgColor
        } else {
            layer.shadowColor = UIColor.darkGray.cgColor
        }
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 3
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0.5
        
    }
    func roundBottomCorners(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        if #available(iOS 13.0, *) {
            layer.shadowColor = UIColor.clear.cgColor
        } else {
            layer.shadowColor = UIColor.darkGray.cgColor
        }
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 3
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0.5
        
    }
    func RightBottomCorners(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
    }
    func LeftTopCorners(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner]
        
    }
    func LeftBottomCorners(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMaxYCorner]
        
    }
    func RightTopCorners(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMaxXMinYCorner]
        
    }
    @discardableResult
    func pin(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) -> AnchoredConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        
        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        
        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        
        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        
        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        
        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        [anchoredConstraints.top, anchoredConstraints.leading, anchoredConstraints.bottom, anchoredConstraints.trailing, anchoredConstraints.width, anchoredConstraints.height].forEach{ $0?.isActive = true }
        
        return anchoredConstraints
    }
    
    func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }
        
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }
        
        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
    
    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func centerXInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func centerYInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func constrainWidth(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: constant).isActive = true
    }
    
    func constrainHeight(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: constant).isActive = true
    }
    
    /**
     This function declare here for corner Radius, default value is 6
     */
    
    func makeEdgeRound(withRadius: CGFloat? = nil){
        self.layer.cornerRadius = withRadius ?? 6
        self.clipsToBounds = true
    }
    
    /**
     This func can apply shadow effect to a view.
     
     Parameters
     
     `followBackgroundColor:` Whether shadow color should follow the background color of the view.
     
     `shadowColor:` Explicit shadow color. Default value is lightGray
     
     `shadowRadius:` Explicit shadow radius by default value is 5.
     
     `opacity:` Explicitly shadow opacity by default value is 0.5
     
     `offset:` Explicitly shadow offset by default size (width: 1.5, height: 1.5).
     
     `Note:` if the 'followBackgroundColor' is true but the background color of the view is nil; then this function does nothing.
     */
    func dropShadow() {
        //  layer.cornerRadius = 12
        
        layer.shadowColor = UIColor(hex: "#7367F0").cgColor
        layer.shadowOpacity = 0.3   // ✅ correct range
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        layer.masksToBounds = false
    }
    
    func dropShadowProfile() {
        layer.cornerRadius = 60
        if #available(iOS 13.0, *) {
            layer.shadowColor = UIColor.systemGray5.cgColor
        } else {
            layer.shadowColor = UIColor.darkGray.cgColor
        }
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 3
        layer.borderColor = UIColor.systemGray5.cgColor
        layer.borderWidth = 1
        
    }
    func addDashedBorder(borderColor: UIColor?, cornerRadius: CGFloat?) {
        // Remove existing dashed border
        self.layer.sublayers?.removeAll(where: { $0.name == "DashedBorderLayer" })
        
        let color = borderColor?.cgColor
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.name = "DashedBorderLayer"
        shapeLayer.bounds = self.bounds
        shapeLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [4,2]
        
        shapeLayer.path = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: cornerRadius ?? 0.0
        ).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    func addShadow(followBackgroundColor: Bool, shadowColor: UIColor?, shadowRadius: CGFloat?,shadowOpacity: Float?,shadowOffset: CGSize?) {
        
        var color: UIColor!
        (followBackgroundColor) ? (color = backgroundColor!) : (color = shadowColor ?? UIColor.black.withAlphaComponent(0.75))
        
        var radius: CGFloat!
        (shadowRadius != nil) ? (radius = shadowRadius!) : (radius = 3)
        
        var opacity: Float!
        (shadowOpacity != nil ) ? (opacity = shadowOpacity!) : (opacity = 0.5)
        
        var offset: CGSize!
        (shadowOffset != nil) ? (offset = shadowOffset) : (offset = CGSize(width: 3, height: 3))
        
        layer.shadowColor = color.cgColor
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
    
    func addGradientLayerInForeground(frame: CGRect, colors:[UIColor]){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors.map{$0.cgColor}
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.addSublayer(gradient)
    }
    
    
    //MARK:- Hide/Unhide Functions
    func hide() {
        self.gone()
        self.isHidden = true
    }
    
    func unhide() {
        self.visible()
        self.isHidden = false
    }
    
    // skeleto view hide and show
    
    
    func showSkeleton(
        cornerRadius: CGFloat = 12,
        baseColor: UIColor = .systemGray5,
        secondaryColor: UIColor = .systemGray4
    ) {
        
        guard !sk.isSkeletonActive else { return }
        
        layoutIfNeeded()
        
        isSkeletonable = true
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        
        let gradient = SkeletonGradient(
            baseColor: baseColor,
            secondaryColor: secondaryColor
        )
        
        let animation = SkeletonAnimationBuilder()
            .makeSlidingAnimation(withDirection: .leftRight)
        
        showAnimatedGradientSkeleton(
            usingGradient: gradient,
            animation: animation,
            transition: .crossDissolve(0.2)
        )
    }
    
    func hideSkeleton() {
        
        guard sk.isSkeletonActive else { return }
        
        hideSkeleton(
            reloadDataAfter: true,
            transition: .crossDissolve(0.2)
        )
    }
}
extension UIView {
    func fadeIn(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        self.alpha = 0.0

        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }

    func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        self.alpha = 1.0

        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.isHidden = true
            self.alpha = 0.0
        }, completion: completion)
    }
    @IBInspectable
        var cornerRadius: CGFloat {
            get {
                return layer.cornerRadius
            }
            set {
                layer.cornerRadius = newValue
            }
        }

        @IBInspectable
        var borderWidth: CGFloat {
            get {
                return layer.borderWidth
            }
            set {
                layer.borderWidth = newValue
            }
        }
    @IBInspectable
        var borderColor: UIColor? {
            get {
                if let color = layer.borderColor {
                    return UIColor(cgColor: color)
                }
                return nil
            }
            set {
                if let color = newValue {
                    layer.borderColor = color.cgColor
                } else {
                    layer.borderColor = nil
                }
            }
        }
}
import UIKit

extension UISearchBar {
    func applyDefaultStyle(placeholder: String? = nil) {
        self.sizeToFit()
        self.placeholder = placeholder
        self.text = ""
        self.isTranslucent = true
        self.backgroundImage = nil
        self.searchBarStyle = .minimal
        self.delegate = self.delegate // preserve delegate if already set
        
        self.setBorderProperties(borderColor: .clear, borderWidth: 1.0, cornerRadius: 25, masksToBounds: true)
        
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear
            textField.textColor = .black
            textField.tintColor = .black
            textField.clipsToBounds = true
        }
    }
}
