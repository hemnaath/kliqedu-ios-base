//
//  APIHelper.swift
//  herald-exchange
//
//  Created by codegama on 08/10/25.
//

import Foundation
import SwiftyRSA
import CryptoSwift

class APIHelper {

    static func createHeadersAndSignature(endpoint: String,
                                          params: [String: Any]) -> (headers: [String: String], signatureBase64: String?, timeStamp: Int) {

        // 1. Convert params to JSON string (empty {} if needed)
        let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
        let parameter = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

        // 2. Timestamp
        let timeStamp = Int(Date().timeIntervalSince1970)

        // 3. Build plainContent EXACT like website team
        let apiNonce = String.generateNonce()
        let api_sig = "\(endpoint)\(parameter)\(timeStamp)\(salt_Key)"

        print("api_sig:",api_sig)

        // 4. HMAC WITH api_Key (IMPORTANT!)
        var hmac: String? = nil
        if let hmacHex = try? HMAC(key: api_Key, variant: .sha256)
            .authenticate(Array(api_sig.utf8))
            .toHexString()
        {
            hmac = hmacHex
        } else {
            print("❌ HMAC failed")
        }

        // 5. RSA SIGN HMAC → Base64
        var signatureBase64: String? = nil
        if let hmac = hmac,
           let privateKey = try? PrivateKey(pemEncoded: private_key),
           let msg = try? ClearMessage(string: hmac, using: .utf8),
           let signature = try? msg.signed(with: privateKey, digestType: .sha256)
        {
            signatureBase64 = signature.base64String
        } else {
            print("❌ RSA signing failed")
        }

        // 6. Headers
        let headers = [
            "Authorization": "Bearer \(token)",
            "X-Api-Key": api_Key,
            "X-Api-Signature": signatureBase64 ?? "",
            "X-Api-Timestamp": "\(timeStamp)",
            "Idempotency-Key": UUID().uuidString,
            "genesis": "grdpdxkx.herald.exchange",
            "x-mobile-secret": "8ebc7fde7a65d00b118eaaf1d9f9c7b0684204e70c52e87ff6266bc8b583800c",
            "x-api-nonce": String.generateNonce()
        ]

        return (headers, signatureBase64, timeStamp)
    }
    static func createHeadersAndSignatureForWithdraw(endpoint: String,
                                          params: [String: Any]) -> (headers: [String: String], signatureBase64: String?, timeStamp: Int) {

        // 1. Convert params to JSON string (empty {} if needed)
        let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
        let parameter = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

        // 2. Timestamp
        let timeStamp = Int(Date().timeIntervalSince1970)

        // 3. Build plainContent EXACT like website team
        let apiNonce = String.generateNonce() // For withdraw 
        let api_sig = "\(endpoint)\(parameter)\(timeStamp)\(apiNonce)\(salt_Key)"

        print("api_sig:",api_sig)

        // 4. HMAC WITH api_Key (IMPORTANT!)
        var hmac: String? = nil
        if let hmacHex = try? HMAC(key: api_Key, variant: .sha256)
            .authenticate(Array(api_sig.utf8))
            .toHexString()
        {
            hmac = hmacHex
        } else {
            print("❌ HMAC failed")
        }

        // 5. RSA SIGN HMAC → Base64
        var signatureBase64: String? = nil
        if let hmac = hmac,
           let privateKey = try? PrivateKey(pemEncoded: private_key),
           let msg = try? ClearMessage(string: hmac, using: .utf8),
           let signature = try? msg.signed(with: privateKey, digestType: .sha256)
        {
            signatureBase64 = signature.base64String
        } else {
            print("❌ RSA signing failed")
        }

        // 6. Headers
        let headers = [
            "Authorization": "Bearer \(token)",
            "X-Api-Key": api_Key,
            "X-Api-Signature": signatureBase64 ?? "",
            "X-Api-Timestamp": "\(timeStamp)",
            "Idempotency-Key": UUID().uuidString,
            "genesis": "grdpdxkx.herald.exchange",
            "x-mobile-secret": "8ebc7fde7a65d00b118eaaf1d9f9c7b0684204e70c52e87ff6266bc8b583800c",
            "x-api-nonce": apiNonce
        ]

        return (headers, signatureBase64, timeStamp)
    }
}
