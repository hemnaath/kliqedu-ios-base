//
//  NetworkManager.swift
//  OnlyAlly
//
//  Created by Karthick RJ on 20/05/21.
//

import Foundation
import UIKit
import Alamofire

final class NetworkManager {

    static let shared = NetworkManager()

    private let reachabilityManager = NetworkReachabilityManager.default

    private init() {
        startListening()
    }

    private func startListening() {
        reachabilityManager?.startListening { status in
            print("📡 Network status:", status)

            switch status {
            case .reachable(.cellular), .reachable(.ethernetOrWiFi):
                NotificationCenter.default.post(
                    name: Notification.Name(Constants.Notifications.networkConnected),
                    object: nil
                )

            case .notReachable, .unknown:
                NotificationCenter.default.post(
                    name: Notification.Name(Constants.Notifications.networkDisconnected),
                    object: nil
                )
            }
        }
    }

    /// ✅ REAL-TIME CHECK (NO CACHE)
    var isConnected: Bool {
        reachabilityManager?.isReachable ?? false
    }
}
