//
//  GeneralSingleton.swift
//  OnlyAlly
//
//  Created by Karthick RJ on 19/05/21.
//

import Foundation
import CryptoSwift
import CommonCrypto
import CryptoKit

class GeneralSingleton {
    
    static let shared = GeneralSingleton()
    
    private init() {}
    
    //to dismiss to viewplansdVc
    var transactionPages : String = ""
        
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func encryptData(data: String, key: String) -> String? {
        // Convert the key and data to bytes
        guard let keyData = key.data(using: .utf8),
              let dataToEncrypt = data.data(using: .utf8) else {
            return nil
        }
        
        // Create an array to hold the hash result
        var hashBytes = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        // Perform HMAC-SHA256 encryption
        keyData.withUnsafeBytes { keyBytes in
            dataToEncrypt.withUnsafeBytes { dataBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes.baseAddress, keyData.count, dataBytes.baseAddress, dataToEncrypt.count, &hashBytes)
            }
        }
        
        // Convert the hash bytes to a hexadecimal string
        let hexString = hashBytes.map { String(format: "%02x", $0) }.joined()
        return hexString
    }
    
    func decryptKey(encryptedKey: String) -> String? {
        let keyBase64 = Constants.keyFile
        
        guard let keyData = Data(base64Encoded: keyBase64) else {
            print("Invalid Base64 key")
            return nil
        }
        
        guard let encryptedKeyData = Data(base64Encoded: encryptedKey) else {
            print("Invalid Base64 encrypted key")
            return nil
        }
        
        guard let encryptedKeyJson = try? JSONSerialization.jsonObject(with: encryptedKeyData, options: []) as? [String: String],
              let valueBase64 = encryptedKeyJson["value"],
              let ivBase64 = encryptedKeyJson["iv"],
              let valueData = Data(base64Encoded: valueBase64),
              let ivData = Data(base64Encoded: ivBase64) else {
            print("Invalid JSON structure or Base64 encoding")
            return nil
        }

        let key: [UInt8] = Array(keyData)   // Explicit conversion
        let iv: [UInt8] = Array(ivData)     // Explicit conversion
        let ciphertext: [UInt8] = Array(valueData)  // Explicit conversion

        do {
            let decrypted = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(ciphertext)
            let decryptedData = Data(decrypted)
            let decryptedString = String(data: decryptedData, encoding: .utf8)
            return decryptedString
        } catch {
            print("Decryption failed: \(error)")
            return nil
        }
    }
    func prepareHeadersAndSignature(endpoint: String, params: [String: Any]) -> (headers: [String: String], apiSig: String)? {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []),
                  let parameter = String(data: jsonData, encoding: .utf8) else {
                print("Failed to serialize parameters.")
                return nil
            }

            let apiSig = "\(endpoint)\(parameter)\(salt_Key)"
        let encryptedSignature = GeneralSingleton.shared.encryptData(data: apiSig, key: api_Key) ?? ""

            print("api_sig: \(apiSig)")

            let headers: [String: String] = [
                "Authorization": "Bearer \(token)",
                "X-Api-Key": api_Key,
                "X-Api-Signature": encryptedSignature
            ]

            print("headers: \(headers)")
            
            return (headers, apiSig)
        }
}
