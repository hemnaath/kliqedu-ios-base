//
//  GoneVisible.swift
//  herald-exchange
//
//  Created by codegama on 12/01/26.
//

import UIKit
import ObjectiveC

public enum GVSpace {
    case top
    case bottom
    case leading
    case trailing
    
    func attribute() -> NSLayoutConstraint.Attribute {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
}

public enum GVAxis {
    case vertical
    case horizontal
}

extension NSLayoutConstraint {

    private static var originalConstantKey = "originalConstantKey"

    private var originalConstant: CGFloat? {
        get {
            objc_getAssociatedObject(self, &Self.originalConstantKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(
                self,
                &Self.originalConstantKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func setGoneConstant() {
        guard originalConstant == nil else { return }
        originalConstant = constant
        constant = 0
    }

    func restoreConstant() {
        guard let originalConstant else { return }
        constant = originalConstant
        self.originalConstant = nil
    }

    func isHeightConstraint() -> Bool {
        firstAttribute == .height && secondAttribute == .notAnAttribute
    }

    func isWidthConstraint() -> Bool {
        firstAttribute == .width && secondAttribute == .notAnAttribute
    }

    func isAspectRatio() -> Bool {
        (firstAttribute == .width && secondAttribute == .height) ||
        (firstAttribute == .height && secondAttribute == .width)
    }

    func isSpacing(for view: UIView, attribute: NSLayoutConstraint.Attribute) -> Bool {
        (firstItem as? UIView == view && firstAttribute == attribute) ||
        (secondItem as? UIView == view && secondAttribute == attribute)
    }

    func isEqualSize(for view: UIView, attribute: NSLayoutConstraint.Attribute) -> Bool {
        (firstItem as? UIView == view && secondItem != nil && firstAttribute == attribute) ||
        (secondItem as? UIView == view && secondAttribute == attribute)
    }
}

extension UIView {

    private static var isGoneKey = "isGoneKey"
    private static var disabledConstraintsKey = "disabledConstraintsKey"

    private var isGone: Bool {
        get { objc_getAssociatedObject(self, &Self.isGoneKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Self.isGoneKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var disabledConstraints: [NSLayoutConstraint] {
        get { objc_getAssociatedObject(self, &Self.disabledConstraintsKey) as? [NSLayoutConstraint] ?? [] }
        set { objc_setAssociatedObject(self, &Self.disabledConstraintsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: - Public API

    public func gone(
        axis: GVAxis? = nil,
        spaces: [GVSpace]? = nil,
        animated: Bool = false,
        duration: TimeInterval = 0.25
    ) {
        guard !isGone else { return }
        isGone = true
        isUserInteractionEnabled = false

        let changes = {
            self.applyGone(axis: axis, spaces: spaces)
            self.superview?.layoutIfNeeded()
        }

        animated
            ? UIView.animate(withDuration: duration, animations: changes)
            : changes()
    }

    public func visible(
        animated: Bool = false,
        duration: TimeInterval = 0.25
    ) {
        guard isGone else { return }
        isGone = false
        isUserInteractionEnabled = true

        let changes = {
            self.restoreFromGone()
            self.superview?.layoutIfNeeded()
        }

        animated
            ? UIView.animate(withDuration: duration, animations: changes)
            : changes()
    }
}

private extension UIView {

    func applyGone(axis: GVAxis?, spaces: [GVSpace]?) {

        let heightConstraints = constraints.filter { $0.isHeightConstraint() }
        let widthConstraints  = constraints.filter { $0.isWidthConstraint() }

        if axis != .horizontal {
            (heightConstraints.isEmpty ? [addHeightConstraint()] : heightConstraints)
                .forEach { $0.setGoneConstant() }
        }

        if axis != .vertical {
            (widthConstraints.isEmpty ? [addWidthConstraint()] : widthConstraints)
                .forEach { $0.setGoneConstant() }
        }

        let toDisable = constraints.filter {
            $0.isAspectRatio() ||
            $0.isEqualSize(for: self, attribute: .width) ||
            $0.isEqualSize(for: self, attribute: .height)
        }

        toDisable.forEach { $0.isActive = false }
        disabledConstraints = toDisable

        spaces?.forEach { space in
            findSpacingConstraints(attribute: space.attribute())?.forEach {
                $0.setGoneConstant()
            }
        }
    }

    func restoreFromGone() {

        constraints.forEach {
            $0.restoreConstant()
        }

        disabledConstraints.forEach { $0.isActive = true }
        disabledConstraints.removeAll()

        [.top, .bottom, .leading, .trailing].forEach {
            findSpacingConstraints(attribute: $0)?.forEach {
                $0.restoreConstant()
            }
        }
    }

    func findSpacingConstraints(attribute: NSLayoutConstraint.Attribute) -> [NSLayoutConstraint]? {
        guard let superview else { return nil }
        let found = superview.constraints.filter {
            $0.isSpacing(for: self, attribute: attribute)
        }
        return found.isEmpty ? superview.findSpacingConstraints(attribute: attribute) : found
    }

    func addHeightConstraint() -> NSLayoutConstraint {
        addSizeConstraint(attribute: .height, constant: bounds.height)
    }

    func addWidthConstraint() -> NSLayoutConstraint {
        addSizeConstraint(attribute: .width, constant: bounds.width)
    }

    func addSizeConstraint(attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: constant
        )
        constraint.priority = .defaultHigh
        addConstraint(constraint)
        return constraint
    }
}
