//
//  APILogger.swift
//  KliqEdu
//
//  Created by codegama on 15/12/25.
//

import Foundation

// MARK: - Release log silencing
// Console logging is for development only. In Release builds these module-level
// overrides shadow Swift's `print`/`debugPrint`, so no request/response data,
// tokens or keys are written to the device log.
#if DEBUG
let isDebugLoggingEnabled = true
#else
let isDebugLoggingEnabled = false

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
#endif

enum APILogType {
    case request
    case response
    case error
}

final class APILogger {

    static func log(
        type: APILogType,
        endPoint: String,
        url: String,
        method: String,
        headers: [String: String]? = nil,
        params: Any? = nil,
        response: Any? = nil,
        error: Error? = nil,
        startTime: Date? = nil
    ) {
        guard isDebugLoggingEnabled else { return }

        let timestamp = Self.formattedDate(Date())
        
        print("""
        \n*********************************************************************************************
        🔵 API \(type == .request ? "REQUEST" : type == .response ? "RESPONSE" : "ERROR")
        ⏰ Time : \(timestamp)
        🌐 Request URL : \(url)
        🔗 Endpoint : \(endPoint)
        🔁 Http Method : \(method)
        *********************************************************************************************
        """)

        if let headers = headers {
            print("📌 Headers:")

         //   print(Self.prettyJSON(headers))
            print(prettyHeaders(headers))

            print("*********************************************************************************************")
        }

        if let params = params {
           
            print("📦 Params / Body:")
            print( Self.prettyJSON(params))
        }

        if let response = response {
            print("✅ /\(endPoint) Response:")
            print(Self.prettyJSON(response))
        }

        if let error = error {
            print("""
            ❌ Error:
            \(error.localizedDescription)
            """)
        }

        print("*********************************************************************************************\n")
    }

    static func prettyJSON(_ object: Any) -> String {

        // ✅ If already String, print as-is (NO escaping)
        if let string = object as? String {
            return string
        }

        // ✅ If Dictionary / Array, pretty print JSON
        if JSONSerialization.isValidJSONObject(object),
           let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }

        // Fallback
        return "\(object)"
    }
    private static func prettyHeaders(_ headers: [String: String]) -> String {
        var result = "{\n"
        for (key, value) in headers {
            result += "  \"\(key)\" : \(value) \n"
        }
        result += "}"
        return result
    }
    private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
}
