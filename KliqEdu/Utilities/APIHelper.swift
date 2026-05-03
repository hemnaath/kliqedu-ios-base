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

        let encryptedSaltKey = salt_Key

        let encryptionKey = "q83Jf9K2mYkzYF7v0T1LwH8xZpQeR5aC6nB2dXyUo9E="

        if let decryptedSalt = decryptSaltKey(
            encryptedSaltKey: encryptedSaltKey,
            encryptionKey: encryptionKey
        ) {
            
            print("Decrypted Salt Key:", decryptedSalt)
            salt_Key = decryptedSalt
        }
        
        // 1. Convert params to JSON string (empty {} if needed)
        let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
        let parameter = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

        // 2. Timestamp
        let timeStamp = Int(Date().timeIntervalSince1970)

        // 3. Build plainContent EXACT like website team
        let api_sig = "\(endpoint)\(parameter)\(timeStamp)\(salt_Key)"

        print("api_sig:",api_sig)
        

        // 4. HMAC WITH api_Key (matches backend verifySignature)
        var signatureBase64: String = ""
        do {
            signatureBase64 = try HMAC(key: api_Key, variant: .sha256)
                .authenticate(Array(api_sig.utf8))
                .toHexString()
        } catch {
            print("❌ HMAC failed: \(error)")
        }

        // 6. Headers
        var headers = [
            "Authorization": "Bearer \(token)",
            "X-Api-Key": api_Key,
            "X-Api-Signature": signatureBase64,
            "X-Api-Timestamp": "\(timeStamp)"
        ]
        if roleKey == "parent" {
            headers["student-id"] = "\(defaults.value(forKey: Constants.Keys.userUniqueIdKey) ?? "")"
        }

        return (headers, signatureBase64, timeStamp)
    }
    
}
import Foundation
import SwiftyRSA

func decryptSaltKey(encryptedSaltKey: String, encryptionKey: String) -> String? {
    do {
        // MARK: Step 1 - Decode Key
        guard let keyData = Data(base64Encoded: encryptionKey) else {
            print("❌ Invalid base64 encryption key")
            return nil
        }
        
        if keyData.count != 32 {
            print("❌ Invalid key length: \(keyData.count). Expected 32 bytes.")
            return nil
        }

        // MARK: Step 2 - Decode Payload
        guard let payloadData = Data(base64Encoded: encryptedSaltKey),
              let payloadString = String(data: payloadData, encoding: .utf8),
              let jsonData = payloadString.data(using: .utf8),
              let payload = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("❌ Invalid encrypted payload")
            return nil
        }

        let ivBase64 = payload["iv"] as? String ?? ""
        let valueBase64 = payload["value"] as? String ?? ""
        let mac = payload["mac"] as? String ?? ""

        guard let ivData = Data(base64Encoded: ivBase64),
              let cipherData = Data(base64Encoded: valueBase64) else {
            print("❌ Invalid iv/value base64")
            return nil
        }

        // MARK: Step 3 - Verify MAC
        let macSource = ivBase64 + valueBase64

        let expectedMac = try HMAC(
            key: Array(keyData),
            variant: .sha256
        )
        .authenticate(Array(macSource.utf8))
        .toHexString()

        guard mac.lowercased() == expectedMac.lowercased() else {
            print("❌ Invalid MAC. Data may have been tampered.")
            return nil
        }

        // MARK: Step 4 - AES256 CBC Decrypt
        let aes = try AES(
            key: Array(keyData),
            blockMode: CBC(iv: Array(ivData)),
            padding: .pkcs7
        )

        let decryptedBytes = try aes.decrypt(Array(cipherData))
        let decryptedText = String(bytes: decryptedBytes, encoding: .utf8) ?? ""

        // MARK: Step 5 - Clean Laravel Serialized Format
        // Example: s:8:"abc123";
        if decryptedText.contains(":\"") {
            let cleaned = decryptedText
                .components(separatedBy: ":\"")
                .last?
                .replacingOccurrences(of: "\";", with: "") ?? decryptedText
            
            return cleaned
        }

        return decryptedText

    } catch {
        print("❌ SaltKey Decryption Failed:", error)
        return nil
    }
}
