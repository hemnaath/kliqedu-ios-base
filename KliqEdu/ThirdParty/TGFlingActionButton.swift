//
//  TGFlingActionButton.swift
//  TGFlingActionButton
//
//  Created by Karthic RJ on 23/05/25.
//  Copyright © 2025 Karthic RJ. All rights reserved.


import UIKit

class TGFlingActionButton: UIButton {

    private var panGesture: UIPanGestureRecognizer!
    private var swipableView: UIView!
    private var swipeOverlay: UIImageView?

    private(set) var swipe_direction: Swipe_Direction = .none

    enum Swipe_Direction {
        case right
        case left
        case none
    }

    @IBInspectable var InitialStateColor: UIColor = UIColor(
        red: 239/255,
        green: 82/255,
        blue: 45/255,
        alpha: 1
    )

    @IBInspectable var FinalStateColor: UIColor = UIColor(
        red: 0/255,
        green: 138/255,
        blue: 62/255,
        alpha: 1
    )

    @IBInspectable var ImageOverlay: UIImage?

    override func layoutSubviews() {
        super.layoutSubviews()

        if swipableView == nil {
            setupSwipeView()
        }
    }

    private func setupSwipeView() {
        clipsToBounds = true
        layer.cornerRadius = frame.height / 2

        let size = frame.height - 4
        swipableView = UIView(frame: CGRect(x: 2, y: 2, width: size, height: size))
        swipableView.backgroundColor = FinalStateColor
        swipableView.layer.cornerRadius = size / 2
        swipableView.clipsToBounds = true

        if let image = ImageOverlay {
            swipeOverlay = UIImageView(image: image)
            swipeOverlay?.frame = CGRect(x: 6, y: 6, width: size - 12, height: size - 12)
            swipeOverlay?.contentMode = .scaleAspectFit
            swipableView.addSubview(swipeOverlay!)
        }

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        swipableView.addGestureRecognizer(panGesture)

        addSubview(swipableView)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {

        let translation = gesture.translation(in: self)
        let maxX = frame.width - swipableView.frame.width - 2

        switch gesture.state {

        case .changed:
            if translation.x > 0 {
                swipableView.frame.origin.x = min(translation.x, maxX)
            }

        case .ended:
            if translation.x >= maxX * 0.5 {
                completeSwipe(maxX: maxX)
            } else {
                reset()
            }

        default:
            break
        }
    }

    private func completeSwipe(maxX: CGFloat) {
        swipe_direction = .right

        UIView.animate(withDuration: 0.25) {
            self.swipableView.frame.origin.x = maxX
        }

        UIView.animate(withDuration: 0.3) {
            self.swipableView.backgroundColor = self.FinalStateColor
            self.swipeOverlay?.transform = CGAffineTransform(rotationAngle: .pi)
        }

        sendActions(for: .valueChanged)
    }

    func reset() {
        swipe_direction = .none

        UIView.animate(withDuration: 0.25) {
            self.swipableView.frame.origin.x = 2
        }

        UIView.animate(withDuration: 0.3) {
            self.swipableView.backgroundColor = self.FinalStateColor
            self.swipeOverlay?.transform = .identity
        }
    }
}
