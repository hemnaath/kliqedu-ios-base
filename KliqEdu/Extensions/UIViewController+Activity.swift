//
//  UIViewController+Activity.swift
//  herald-exchange
//
//  Created by codegama on 13/11/25.
//

import Foundation
import UIKit

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

func showTopBanner(message: String) {
    guard let window = UIApplication.shared.keyWindowInConnectedScenes else { return }

    let topInset = window.safeAreaInsets.top        // 👈 Status bar / notch height
    let bannerHeight: CGFloat = topInset + 55       // 👈 Increase height to avoid overlap

    let banner = UIView(frame: CGRect(
        x: 0,
        y: -bannerHeight,
        width: window.frame.width,
        height: bannerHeight
    ))

    banner.backgroundColor = UIColor(red: 220/255, green: 53/255, blue: 69/255, alpha: 1)
    let font = UIFont(name: GLOBAL.FontsIdentifier.FontBold, size: 14)!

    let label = UILabel(frame: CGRect(
        x: 16,
        y: topInset,   // 👈 Place LABEL below the status bar
        width: window.frame.width - 32,
        height: 55
    ))
    label.text = message
    label.textColor = .white
    label.font = font
    label.textAlignment = .center

    banner.addSubview(label)
    window.addSubview(banner)

    // Slide down
    UIView.animate(withDuration: 0.3) {
        banner.frame.origin.y = 0
    } completion: { _ in
        // Show for 2 sec → slide up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3) {
                banner.frame.origin.y = -bannerHeight
            } completion: { _ in
                banner.removeFromSuperview()
            }
        }
    }
}
func hideTopBanner() {
    guard let window = UIApplication.shared.keyWindowInConnectedScenes else { return }

    for view in window.subviews {
        // Match only your banner (top positioned red view)
        if view.frame.origin.y == 0,
           view.backgroundColor == UIColor(red: 220/255, green: 53/255, blue: 69/255, alpha: 1) {

            let bannerHeight = view.frame.height

            UIView.animate(withDuration: 0.3) {
                view.frame.origin.y = -bannerHeight
            } completion: { _ in
                view.removeFromSuperview()
            }
        }
    }
}
func showBottomToast(message: String) {
    guard let window = UIApplication.shared.keyWindowInConnectedScenes else { return }

    let bottomInset = window.safeAreaInsets.bottom    // 👈 Home indicator safe area
    let toastHeight: CGFloat = 50
    let yStart = window.frame.height + toastHeight    // Start position (below screen)
    let yEnd = window.frame.height - toastHeight - bottomInset - 16 // Final position above bottom

    let toast = UIView(frame: CGRect(
        x: 16,
        y: yStart,
        width: window.frame.width - 32,
        height: toastHeight
    ))

    toast.backgroundColor = UIColor.black.withAlphaComponent(0.85)
    toast.layer.cornerRadius = 10
    toast.clipsToBounds = true

    let label = UILabel(frame: toast.bounds.insetBy(dx: 12, dy: 8))
    label.text = message
    label.textColor = .white
    label.font = UIFont(name: GLOBAL.FontsIdentifier.FontRegular, size: 13) ?? .systemFont(ofSize: 13)
    label.numberOfLines = 2
    label.textAlignment = .center

    toast.addSubview(label)
    window.addSubview(toast)

    // Animate up
    UIView.animate(withDuration: 0.3) {
        toast.frame.origin.y = yEnd
    } completion: { _ in
        // 2.5s delay → animate down
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            UIView.animate(withDuration: 0.3, animations: {
                toast.frame.origin.y = yStart
            }, completion: { _ in
                toast.removeFromSuperview()
            })
        }
    }
}
