//
//  ValidationClass.swift
//  OnlyAlly
//
//  Created by Karthick RJ on 20/05/21.
//

import Foundation
import UIKit
//import libPhoneNumber_iOS

class ValidationClass: NSObject {
    
    class func isValidPassword1(password:String) ->Bool {
        
        if password.count < 6 {
            
            return false
        } else {
            return true
        }
    }

    /// To validate phone number given
    ///
    /// - Parameter value: input number
    /// - Returns: true if valid

    class func isValidMobileNumber(value: String) -> Bool {
        
        // Check only numbers
        let regexNumbersOnly = try! NSRegularExpression(pattern: "^[0-9]+$", options: [])
        
        let isOnlyNumbers = regexNumbersOnly.firstMatch(
            in: value,
            options: [],
            range: NSRange(location: 0, length: value.count)
        ) != nil
        
        // Length validation
        let isValidLength = value.count >= 5 && value.count <= 15
        
        return isOnlyNumbers && isValidLength
    }
    //Validate email address logic
    class func isValidEmailID(email: String) -> Bool {

        let trimmedEmail = email.trimString()
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: trimmedEmail)
        
        return result
    }
    
    //validate name logic
    class func isValid(name: String) -> Bool {
        //Declaring the rule of characters to be used. Applying rule to current state. Verifying the result.
        let regex = "[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: name)
        
        return result
    }
    //validate uniqueID
    class  func convertDateFormat(from input: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: input) else { return input }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        return outputFormatter.string(from: date)
    }
    class  func convertDMYToYMD(from input: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let date = inputFormatter.date(from: input) else { return input }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        return outputFormatter.string(from: date)
    }
    class func getCountryName(from countryCode: String) -> String? {
        return Locale.current.localizedString(forRegionCode: countryCode)
    }
    class func isValidUniqueID(input: String) -> Bool {
        let regex = "^[a-zA-Z0-9_-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: input)
    }
    //    length 6 to 16.
    //    One Alphabet in Password.
    //    One Special Character in Password.
    
    class func isValidPassword(password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    class func isValidUrl(url: String) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
    
    //==========================
    //MARK:- PhoneNumber Validation
    //==========================
    class func isValidPhoneNumber(_ PhoneNumber : String) -> Bool{
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: PhoneNumber)
        return result
    }
    
    //==========================
    //MARK:- UserName Validation
    //==========================
    class func isValidUsername(Username: String) -> Bool {
        let trimmed = Username.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = "^[\\p{L}_\\-'’\\.\\s]{2,150}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: trimmed)
    }

    class func validateName(Field: String,minValue: Int,maxValue: Int,fieldName: String) -> String? {
        
        let trimmed = Field.trimmingCharacters(in: .whitespacesAndNewlines)
    
        if trimmed.isEmpty {
            return "\(fieldName) cannot be empty"
        }
        
        if trimmed.count < minValue {
            return "\(fieldName) must be at least \(minValue) characters"
        }
        
        if trimmed.count > maxValue {
            return "\(fieldName) cannot exceed \(maxValue) characters"
        }
        
        // Allows letters (all languages), space, hyphen, apostrophe, dot
        let regex = "^[\\p{L} .'’-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "\(fieldName) contains invalid characters"
        }
        
        return nil   // ✅ Valid
    }
    class func validateBusinessName(Field: String, minValue: Int, maxValue: Int, fieldName: String) -> String? {
        
        let trimmed = Field.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "\(fieldName) cannot be empty"
        }
        
        if trimmed.count < minValue {
            return "\(fieldName) must be at least \(minValue) characters"
        }
        
        if trimmed.count > maxValue {
            return "\(fieldName) cannot exceed \(maxValue) characters"
        }
        
        // ✅ Allows letters (all languages), numbers, space, and common business symbols
        let regex = "^[\\p{L}0-9 .,'&()\\-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Enter a valid \(fieldName.lowercased())"
        }
        
        return nil   // ✅ Valid
    }

    class func validateEmail(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return "Email cannot be empty"
        }
        
        if trimmed.count > 100 {
            return "Email cannot exceed 100 characters"
        }
        
        // Standard email regex
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Enter a valid email address"
        }
        
        return nil   // ✅ Valid
    }
    class func validateMobileNumber(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Mobile number cannot be empty"
        }
        
        // Length check (5–15 digits as per international standard)
        if trimmed.count < 5 || trimmed.count > 15 {
            return "Mobile number must be 5–15 digits"
        }
        
        // Numbers only
        let regex = "^[0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Mobile number must contain digits only"
        }
        
        return nil   // ✅ Valid
    }

    class func validateQualification(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Qualification cannot be empty"
        }
        
        if trimmed.count < 2 {
            return "Qualification must be at least 2 characters"
        }
        
        if trimmed.count > 50 {
            return "Qualification cannot exceed 50 characters"
        }
        
        // Allows letters, numbers, spaces, dots, commas, hyphen and slash
        let regex = "^[A-Za-z0-9 .,&()\\-/]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Qualification contains invalid characters"
        }
        
        return nil
    }

    class func validateReligion(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Religion cannot be empty"
        }
        
        if trimmed.count < 2 {
            return "Religion must be at least 2 characters"
        }
        
        if trimmed.count > 30 {
            return "Religion cannot exceed 30 characters"
        }
        
        // Allows letters, spaces, apostrophe, hyphen and dots
        let regex = "^[\\p{L} .'-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Religion contains invalid characters"
        }
        
        return nil
    }
    class func validateCaste(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Caste cannot be empty"
        }
        
        if trimmed.count < 2 {
            return "Caste must be at least 2 characters"
        }
        
        if trimmed.count > 30 {
            return "Caste cannot exceed 30 characters"
        }
        
        // Allows letters, spaces, apostrophe, hyphen and dots
        let regex = "^[\\p{L} .'-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Caste contains invalid characters"
        }
        
        return nil
    }
    class func validatePassword(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Password must include upper, lower, number & special character"
        }
        
        if trimmed.count < 8 {
            return "Password must be at least 8 characters"
        }
        
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Password must include upper, lower, number & special character"
        }
        
        return nil   // ✅ Valid
    }
 
    class func validateRegistrationNumber(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Registration number cannot be empty"
        }
        
        if trimmed.count < 5 {
            return "Registration number must be at least 5 characters"
        }
        
        if trimmed.count > 30 {
            return "Registration number cannot exceed 30 characters"
        }
        
        // Allow letters, numbers, hyphen, slash
        let regex = "^[A-Za-z0-9\\-/]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Registration number contains invalid characters"
        }
        
        return nil   // ✅ Valid
    }
    class func validateSwiftCode(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if trimmed.isEmpty {
            return "SWIFT code cannot be empty"
        }
        
        if trimmed.count != 8 && trimmed.count != 11 {
            return "SWIFT code must be 8 to 11 characters"
        }
        
        // 4 letters (Bank) + 2 letters (Country) + 2 alphanumeric (Location) + optional 3 alphanumeric (Branch)
        let regex = "^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Enter a valid SWIFT code"
        }
        
        return nil
    }
    class func validateIBAN(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if trimmed.isEmpty {
            return "IBAN cannot be empty"
        }
        
        if trimmed.count < 15 || trimmed.count > 34 {
            return "IBAN must be 15 to 34 characters"
        }
        
        let regex = "^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,34}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Enter a valid IBAN"
        }
        
        return nil
    }
    class func isValidDescription(description: String) -> Bool {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = "^[\\p{L}0-9_\\-’'@\\.\\s]{2,150}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: trimmed)
    }
    class func validateAccountNumber(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Account number cannot be empty"
        }
        
        if trimmed.count < 4 {
            return "Account number must be at least 4 characters"
        }
        
        if trimmed.count > 50 {
            return "Account number cannot exceed 50 characters"
        }
        
        let regex = "^[A-Za-z0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Account number contains invalid characters"
        }
        
        return nil
    }
    
    class func isValidIFSC(_ ifsc: String) -> Bool {
        let RegEx = "^[A-Z]{4}0[A-Z0-9]{6}$"
        let ifscPred = NSPredicate(format: "SELF MATCHES %@", RegEx)
        return ifscPred.evaluate(with: ifsc)
    }
    class func isValidOccupation(occupation: String) -> Bool {
        let RegEx = "^[A-Za-z\\s-]{2,256}$"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: occupation)
    }
    class func validateAddress(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Address cannot be empty"
        }
        
        if trimmed.count < 3 {
            return "Address must be at least 3 characters"
        }
        
        if trimmed.count > 250 {
            return "Address cannot exceed 250 characters"
        }
        
        let regex = "^[a-zA-Z0-9_@.,#!\\$%\\^&*()\\-/&\\s]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Address contains invalid characters"
        }
        
        return nil   // ✅ Valid
    }
    class func validateTransactionReferenceID(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Transaction ID cannot be empty"
        }
        
        if trimmed.count < 6 {
            return "Transaction ID must be at least 6 characters"
        }
        
        if trimmed.count > 40 {
            return "Transaction ID cannot exceed 40 characters"
        }
        
        // Allow letters, numbers, hyphen and slash
        let regex = "^[A-Za-z0-9\\-/]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Transaction ID contains invalid characters"
        }
        
        return nil   // ✅ Valid
    }
    class func validateCityOrState(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Field cannot be empty"
        }
        
        if trimmed.count < 2 {
            return "Must be at least 2 characters"
        }
        
        if trimmed.count > 30 {
            return "Cannot exceed 30 characters"
        }
        
        let regex = "^\\s*[a-zA-Z0-9_@.,#\\/\\-]+(?:\\s+[a-zA-Z0-9_@.,#\\/\\-]+)*\\s*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Contains invalid characters"
        }
        
        return nil
    }
    class func validatePincode(_ value: String) -> String? {
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Zipcode cannot be empty"
        }
        
        if trimmed.count < 3 {
            return "Zipcode must be at least 3 characters"
        }
        
        if trimmed.count > 10 {
            return "Zipcode cannot exceed 10 characters"
        }
        
        // Indian PIN (6 digits) OR general postal code with optional space
        let regex = "^[A-Za-z0-9]{3,10}\\s?[A-Za-z0-9]$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: trimmed) {
            return "Enter a valid zipcode "
        }
        
        return nil
    }
    
    static  func isValidWalletAddress(value: String) -> Bool {
        let pattern = "^[a-zA-Z0-9]{25,65}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        let range = NSRange(location: 0, length: value.utf16.count)
        return regex.firstMatch(in: value, options: [], range: range) != nil
    }
    
    static func isValidBitcoinAddress(value: String) -> Bool {
        // Legacy (1...), P2SH (3...), Bech32 mainnet (bc1...), Bech32 testnet (tb1...)
        let pattern = "^(bc1|tb1|[13])[a-zA-HJ-NP-Z0-9]{25,39}$"
        return matches(pattern: pattern, in: value)
    }

    static func isValidEthereumAddress(value: String) -> Bool {
        // Ethereum testnets (Goerli, Sepolia, etc.) use the same address format
        let pattern = "^0x[a-fA-F0-9]{40}$"
        return matches(pattern: pattern, in: value)
    }

    static func isValidTronAddress(value: String) -> Bool {
        // Mainnet starts with 'T', testnet (Shasta/Nile) often starts with 'T' or 'a'
        let pattern = "^[T|a][a-zA-Z0-9]{33}$"
        return matches(pattern: pattern, in: value)
    }

    static func isValidSolanaAddress(value: String) -> Bool {
        // Same address format for both mainnet and testnet
        let pattern = "^[1-9A-HJ-NP-Za-km-z]{32,44}$"
        return matches(pattern: pattern, in: value)
    }

    static func isValidPolygonAddress(value: String) -> Bool {
        // Polygon (mainnet + testnets) follow Ethereum address format
        let pattern = "^0x[a-fA-F0-9]{40}$"
        return matches(pattern: pattern, in: value)
    }

    static func isValidBNBAddress(value: String) -> Bool {
        // Binance Smart Chain (BEP-20) -> Ethereum format
        // Binance Chain (BEP-2) -> starts with 'bnb' or 'tbnb'
        let pattern = "^(0x[a-fA-F0-9]{40}|(bnb|tbnb)[a-z0-9]{39})$"
        return matches(pattern: pattern, in: value)
    }
    class func convertDateFormatToAPIDate(_ dateString: String) -> String {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMM yyyy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
//    static func getMaxLength(forCountryCode countryCode: String) -> Int? {
//        let phoneUtil = NBPhoneNumberUtil.sharedInstance()
//        
//        do {
//            // Convert country code (e.g., "+91") to numeric value (e.g., "91")
//            let countryCodeNumber = Int(countryCode.replacingOccurrences(of: "+", with: "")) ?? 0
//            
//            // Get region code (e.g., "IN" for India)
//            if let regionCode = phoneUtil?.getRegionCode(forCountryCode: NSNumber(value: countryCodeNumber)) {
//                
//                // Get an example phone number for the region
//                if let exampleNumber = try phoneUtil?.getExampleNumber(forType: regionCode, type: .MOBILE) {
//                    
//                    // Format the number and return its length
//                    let formattedNumber = try phoneUtil?.format(exampleNumber, numberFormat: .E164) ?? ""
//                    
//                    // Remove "+" and country code from formatted number
//                    let nationalNumber = formattedNumber.replacingOccurrences(of: "+\(countryCodeNumber)", with: "")
//                    
//                    return nationalNumber.count
//                }
//            }
//        } catch {
//            print("Error getting phone number metadata: \(error)")
//        }
//        
//        return nil
//    }

//    static func isValidPhoneNumber1(countryCode: String, phoneNumber: String) -> Bool {
//           guard let util = NBPhoneNumberUtil.sharedInstance() else {
//               return false
//           }
//    
//           // Convert +971 → 971
//           guard let countryCodeInt = Int(countryCode.replacingOccurrences(of: "+", with: "")) else {
//               return false
//           }
//    
//           // Get ISO region code like "AE" for UAE
//           guard let regionCode = util.getRegionCode(forCountryCode: NSNumber(value: countryCodeInt)) else {
//               return false
//           }
//    
//           do {
//               // Parse the number (e.g., "501234567")
//               let parsed = try util.parse(phoneNumber, defaultRegion: regionCode)
//    
//               // Strict region-based validation
//               let isValid = util.isValidNumber(forRegion: parsed, regionCode: regionCode)
//    
//               // Optional: Check number type (MOBILE or FIXED_LINE_OR_MOBILE)
//               let numberType = try util.getNumberType(parsed)
//               let isMobile = numberType == .MOBILE || numberType == .FIXED_LINE_OR_MOBILE
//    
//               return isValid && isMobile
//           } catch {
//               print("❌ Error parsing number: \(error)")
//               return false
//           }
//       }
    
    private static func matches(pattern: String, in value: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        let range = NSRange(location: 0, length: value.utf16.count)
        return regex.firstMatch(in: value, options: [], range: range) != nil
    }
    /// to check for the error code from backend and forcelogout if so
    ///
    /// - Parameter errorCode: errorcode from response
    /// - Returns: true or false
    class func shouldForceLogoutForErrorCode(errorCode: Int) -> Bool {
        
        switch errorCode {
            
        case 1003:
            return true
        case 1004:
            return true
        case 1629:
            return true
        case 401:
            return true
        default:
            return false
        }
    }
    
}
