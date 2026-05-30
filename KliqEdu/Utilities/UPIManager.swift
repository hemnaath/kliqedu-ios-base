//
//  UPIManager.swift
//  Indcrypt
//
//  Created by codegama on 19/12/25.
//

import Foundation
import UIKit

struct UPIApp {
    let name: String
    let scheme: String
    let payURL: String
    let icon: UIImage?
}

final class UPIManager {

    static let shared = UPIManager()
    private init() {}

    let apps: [UPIApp] = [
        UPIApp(
            name: "PhonePe",
            scheme: "phonepe",
            payURL: "phonepe://pay",
            icon: UIImage(named: "user-plus")
        ),
        UPIApp(
            name: "Paytm",
            scheme: "paytmmp",
            payURL: "paytmmp://pay",
            icon: UIImage(named: "paytm")
        ),
        UPIApp(
            name: "Google Pay",
            scheme: "gpay",
            payURL: "gpay://upi/pay",
            icon: UIImage(named: "gpay")
        ),
        UPIApp(
            name: "BHIM",
            scheme: "bhim",
            payURL: "bhim://upi/pay",
            icon: UIImage(named: "bhim")
        ),

        UPIApp(
            name: "Amazon Pay",
            scheme: "amazonpay",
            payURL: "amazonpay://upi/pay",
            icon: UIImage(named: "amazonpay")
        ),

        UPIApp(
            name: "WhatsApp",
            scheme: "whatsapp",
            payURL: "whatsapp://upi/pay",
            icon: UIImage(named: "whatsapp")
        )
    ]

    func installedUPIApps() -> [UPIApp] {
        apps.filter {
            if let url = URL(string: "\($0.scheme)://") {
                return UIApplication.shared.canOpenURL(url)
            }
            return false
        }
    }

    func openUPI(app: UPIApp, backendUPIURL: String) {

        guard let url = buildAppSpecificUPIURL(
            appPayURL: app.payURL,
            originalUPIURL: backendUPIURL
        ) else { return }

        UIApplication.shared.open(url)
    }
    func parseUPIParams(from upiURL: String) -> [URLQueryItem] {

        guard let components = URLComponents(string: upiURL) else { return [] }
        return components.queryItems ?? []
    }
    func buildAppSpecificUPIURL(
        appPayURL: String,
        originalUPIURL: String
    ) -> URL? {

        guard var components = URLComponents(string: appPayURL) else { return nil }

        // reuse backend query params
        components.queryItems = parseUPIParams(from: originalUPIURL)

        return components.url
    }
}
