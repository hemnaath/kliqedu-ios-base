//
//  Extensions+String.swift
//  rentcar
//
//  Created by Karthick RJ on 10/11/20.
//  Copyright © 2020 Karthick RJ. All rights reserved.
//

import Foundation
import UIKit
import CryptoKit
import CommonCrypto

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstLowercased: String { return prefix(1).lowercased() + dropFirst() }

    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
    
    func getFirstChar(_ deckName : String) -> String {
        return deckName.first.map {String($0)} ?? ""
    }
}

extension String {
    
    //MARK:- String Attributes
    
    /**
     attribute string properties, such as text color, font, underline etc.
     - make some perticular texts differ to the other texts in the same text content
     */
    
    public func with(attributes words: [(string: String, color: (foreground: UIColor, background: UIColor?)?, font: UIFont?, underlineAttributes: (style: NSUnderlineStyle, color: UIColor?)?, strikeThroughAttributes: (value: NSNumber, color: UIColor?)?, textLinkUrl: URL?)]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for word in words {
            let range = (self as NSString).range(of: word.string)
            
            //MARK:- Text Foreground And Background Color Attribute
            
            if let color = word.color{
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color.foreground, range: range)
                if let backgroundColor = color.background{
                    attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: backgroundColor, range: range)
                }
            }
            
            //MARK:- Text Font Attribute
            
            if let font = word.font{
                attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            }
            
            //MARK:- Text Underline Attribute
            
            if let underlineAttributes = word.underlineAttributes{
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: underlineAttributes.style.rawValue, range: range)
                if let underlineColor = underlineAttributes.color{
                    attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: underlineColor, range: range)
                }
            }
            
            //MARK:- Text Strike Through Attribute
            
            if let strikeThroughAttributes = word.strikeThroughAttributes{
                attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: strikeThroughAttributes.value, range: range)
                if let strikeThroughColor = strikeThroughAttributes.color{
                    attributedString.addAttribute(NSAttributedString.Key.strikethroughColor
                                                  , value: strikeThroughColor, range: range)
                }
            }
            
            //MARK:- Text Link Attribute
            
            if let linkUrl = word.textLinkUrl{
                attributedString.addAttribute(NSAttributedString.Key.link, value: linkUrl, range: range)
            }
        }
        return attributedString
    }
    func trimString() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var isNotEmpty: Bool {
        return !isEmpty
    }
    func OTPVerification(txt: String, arrTextField: String, maxCount: Int) -> (status: Bool, updateStr: String){
        var updatedText = txt
        if(arrTextField.count>updatedText.count) {
            if(updatedText.count < maxCount && updatedText.count != maxCount-1) {
                if(!updatedText.hasSuffix("-")) {
                    updatedText = String(updatedText.dropLast(1))
                }
            }
        }else {
            if(updatedText.hasSuffix("-")) {
                return (false, "")
            }
            if(updatedText.count < maxCount) {
                if(!updatedText.hasSuffix("-")) {
                    updatedText = updatedText.appending("-")
                }
            }
        }
        return (true, updatedText)
    }
    
    func convertForUI()->String{
        let dateFormatter = DateFormatter()
      //  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.date(from: self){
            dateFormatter.dateStyle = .medium
         //   dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        } else {
            return self
        }
    }
    
}
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
               value: NSUnderlineStyle.single.rawValue,
                   range:NSMakeRange(0,attributeString.length))
        return attributeString
    }
    
}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
extension Optional where Wrapped == String {
    func or(_ defaultValue: String) -> String {
        if let value = self, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return value
        }
        return defaultValue
    }
}

extension String {
   func maxLength(length: Int) -> String {
       var str = self
       let nsString = str as NSString
       if nsString.length >= length {
           str = nsString.substring(with:
               NSRange(
                location: 0,
                length: nsString.length > length ? length : nsString.length)
           )
       }
       return  str
   }
    func withoutWhitespace() -> String {
        return self.replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\0", with: "")
    }
}
extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
    }
    private var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    public func convertHtmlToAttributedStringWithCSS(font: UIFont?, csscolor: String, lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)"
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error)
            return nil
        }
    }
    func countryName(from countryCode: String) -> String {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            // Country name was found
            return name
        } else {
            // Country name cannot be found
            return "Select Country"
        }
    }
    func toCurrencySymbol() -> String? {
         // Iterate through all available locales
         for localeIdentifier in Locale.availableIdentifiers {
             let locale = Locale(identifier: localeIdentifier)
             if locale.currencyCode == self {
                 return locale.currencySymbol
             }
         }
         return nil // Return nil if no match is found
     }
    func formatCardNumber(_ number: String) -> String? {
        guard number.count == 16, number.allSatisfy({ $0.isNumber }) else { return nil }
        
        var formattedNumber = ""
        for (index, digit) in number.enumerated() {
            if index > 0 && index % 4 == 0 {
                formattedNumber.append(" ")
            }
            formattedNumber.append(digit)
        }
        return formattedNumber
    }
    
    static func generateNonce() -> String {
        let randomString = UUID().uuidString + String(Date().timeIntervalSince1970)
        let data = Data(randomString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    func formatAmount() -> String {
        guard let number = Double(self) else { return "0.00" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 16
        
        return formatter.string(from: NSNumber(value: number)) ?? "0.00"
    }
}
extension NSAttributedString {
    func withStrikeThrough(_ style: Int = 1) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        attributedString.addAttribute(.strikethroughStyle,
                                      value: style,
                                      range: NSRange(location: 0, length: string.count))
        return NSAttributedString(attributedString: attributedString)
    }
  
    
}
// MARK: - Manual JSON Builder
func buildOrderedJSONString(from orderedParams: [(String, Any)]) -> String {
    var jsonString = "{"
    for (index, (key, value)) in orderedParams.enumerated() {
        let formattedValue: String
        if let v = value as? String {
            let escaped = v.replacingOccurrences(of: "\"", with: "\\\"")
            formattedValue = "\"\(escaped)\""
        } else if let v = value as? NSNumber {
            formattedValue = "\(v)"
        } else if value is Bool {
            formattedValue = "\(value)"
        } else {
            formattedValue = "\"\(value)\"" // fallback as string
        }

        jsonString += "\"\(key)\":\(formattedValue)"
        if index != orderedParams.count - 1 {
            jsonString += ","
        }
    }
    jsonString += "}"
    return jsonString
}
func buildOrderedJSONString1(from params: [(String, Any)]) -> String {
    
    // Step 1: Extract ubo dictionary from flat params
    var uboDict: [String: String] = [:]
    
    for (key, value) in params {
        if key.contains("ubo[0].") {
            let cleanKey = key.replacingOccurrences(of: "ubo[0].", with: "")
            uboDict[cleanKey] = "\(value)"
        }
    }
    
    // Step 2: Maintain strict order
    let orderedKeys = [
        "first_name",
        "last_name",
        "middle_name",
        "email",
        "mobile",
        "mobile_code",
        "id_type",
        "id_number",
        "address_line_1",
        "address_line_2",
        "city",
        "postal_code",
        "state",
        "country",
        "nationality",
        "ownership_percentage"
    ]
    
    // Step 3: Build JSON manually
    var jsonString = "{\"ubo\":[{"
    
    for (index, key) in orderedKeys.enumerated() {
        let value = (uboDict[key] ?? "")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        jsonString += "\"\(key)\":\"\(value)\""
        
        if index != orderedKeys.count - 1 {
            jsonString += ","
        }
    }
    
    jsonString += "}]}"

    return jsonString
}
