//
//  AlamofireHC.swift
//
//  Created by Karthick RJ on 18/11/20.
//  Copyright © 2020 Karthick RJ. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import os

//static let alamofireService = AlamofireHC()
// Create a logger for your app
let apiLogger = Logger(subsystem: "com.efi.herald-exchange", category: "API")
let requestStartTime = Date()

class AlamofireHC: NSObject {
    
    // 🕒 Custom session with longer timeout
    private static let longTimeoutSession: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 300   // Request timeout
        configuration.timeoutIntervalForResource = 300  // Full resource timeout
        return Session(configuration: configuration)
    }()
    
    class func request(_ strMethod: String,method: HTTPMethod = .get,rawJSONString: String? = nil,params: [String: Any]? = nil,headers: [String: String]? = nil,shouldShowHUD: Bool = true,success: @escaping (JSON) -> Void,failure: @escaping (Error) -> Void
    ) {
        print("Connected:", NetworkManager.shared.isConnected)
        // ✅ Reliable connectivity check
            if !NetworkManager.shared.isConnected {
                showTopBanner(message: StringConstants.noInternetConnectionFound)
                return
            }

        if shouldShowHUD {
            LoadingIndicator.show()
        }
     //   showBottomToast(message: "sdfds")
        
        let url = Constants.baseUrl + strMethod
        
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 300        // 🔥 Required to override 60s default timeout
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add body for POST and PUT, Delete
        if method == .post || method == .put || method == .patch || method == .delete {
            if let rawJSONString = rawJSONString {
                urlRequest.httpBody = rawJSONString.data(using: .utf8)
                print("Ordered Raw JSON Parameters:\n\(rawJSONString)")
            } else if let params = params {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                    urlRequest.httpBody = jsonData
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                    }
                } catch {
                    print("Error serializing params: \(error)")
                }
            }
        }
        
        APILogger.log(
            type: .request,
            endPoint: strMethod,
            url: url,
            method: method.rawValue,
            headers: headers,
            params: rawJSONString ?? params,
            startTime: requestStartTime
        )
        // ✅ Use long timeout session here

        longTimeoutSession.request(urlRequest).validate(statusCode: 200..<600).responseJSON { response in
                        
            if shouldShowHUD {
                LoadingIndicator.hide()
            }
            if let error = response.error,
                  error.isSessionTaskError {
                   showTopBanner(message: StringConstants.noInternetConnectionFound)
                   return
               }
            switch response.result {
            case .success(let value):
                let resJson = JSON(value)
                print("✅ /\(strMethod) Response:")
                print(APILogger.prettyJSON(value))
                success(resJson)
                
            case .failure(let error):
                APILogger.log(
                    type: .error,
                    endPoint: strMethod,
                    url: url,
                    method: method.rawValue,
                    headers: headers,
                    params: rawJSONString ?? params,
                    error: error,
                    startTime: requestStartTime
                )
                debugPrint("\(strMethod) Request failed: \(error)")
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        
                        let errorMessage = json?["message"] as? String
                        let errorCode = json?["status_code"] as? Int
                        
                        print("🔥 Backend Error Message:", errorMessage ?? "Unknown error")
                        print("🔥 Backend Error Code:", errorCode ?? 0)
                        
                        //  showTopBanner(message: errorMessage ?? "Something went wrong")
                        
                    } catch {
                        print("❌ Failed to parse error JSON:", error)
                    }
                } else {
                    print("❌ No response data received")
                }
                
                failure(error)
            }
        }
    }

    class func requestGET(_ strMethod: String, shouldShowHUD: Bool = true, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        // Check network availability
            if !NetworkManager.shared.isConnected {
                showTopBanner(message: StringConstants.noInternetConnectionFound)
                return
            }
        
        if shouldShowHUD {
            LoadingIndicator.show()
        }
        
        let url = Constants.baseUrl + strMethod
        
        print("***************************************************************")
        print("URL: \(url)")
        print("***************************************************************")
        
        // Alamofire 5 request
        longTimeoutSession.request(url, method: .get)
            .validate() // Automatically validates response status codes 200-299
            .responseJSON { response in
                
                print(response)
                
                if shouldShowHUD {
                    LoadingIndicator.hide()
                }
                
                switch response.result {
                case .success(let value):
                    let resJson = JSON(value)
                    
                    // Ensure `value` is a valid JSON object (dictionary or array)
                    if let jsonObject = value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                            if let jsonString = String(data: jsonData, encoding: .utf8) {
                                debugPrint("********************************************")

                                print("Formatted JSON Response:\n\(jsonString)")
                            }
                        } catch {
                            print("Error formatting JSON: \(error)")
                        }
                    } else {
                        print("Received response is not a valid JSON object")
                    }
                    
                    success(resJson)
                case .failure(let error):
                    debugPrint("Upload failed: \(error)")
                    failure(error)
                }
            }
    }
    class func requestGET1(_ strMethod: String, params: [String: Any]?, headers: [String: String]?, shouldShowHUD: Bool = true, success: @escaping (JSON) -> Void, failure: @escaping (Error) -> Void) {
        
        // Check network availability
        if !NetworkManager.shared.isConnected {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            return
        }
        
        if shouldShowHUD {
            LoadingIndicator.show()
        }

        let url = strMethod
        
        debugPrint("********************************************")
        debugPrint("Request URL: \(url)")
        debugPrint("********************************************")
        debugPrint("Param: \(params ?? [:])")
        debugPrint("********************************************")

        // Convert headers to Alamofire format
        let afHeaders: HTTPHeaders? = headers != nil ? HTTPHeaders(headers!) : nil
        
        // Alamofire 5 request
        longTimeoutSession.request(url, method: .get, parameters: params, headers: afHeaders)
            .validate() // Automatically validates status codes 200-299
            .responseJSON { response in
                
                if shouldShowHUD {
                    LoadingIndicator.hide()
                }
                
                switch response.result {
                case .success(let value):
                    let resJson = JSON(value)
                    
                    // Ensure `value` is a valid JSON object (dictionary or array)
                    if let jsonObject = value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                            if let jsonString = String(data: jsonData, encoding: .utf8) {
                                print("Formatted JSON Response:\n\(jsonString)")
                            }
                        } catch {
                            print("Error formatting JSON: \(error)")
                        }
                    } else {
                        print("Received response is not a valid JSON object")
                    }
                    
                    success(resJson)
                case .failure(let error):
                    debugPrint("Upload failed: \(error)")
                    failure(error)
                }
            }
    }

    class func requestPOST(_ strMethod: String,rawJSONString: String? = nil,params: [String: Any]? = nil,headers: [String: String]? = nil,shouldShowHUD: Bool = true,success: @escaping (JSON) -> Void,failure: @escaping (Error) -> Void) {
        
        // Check network
        if !NetworkManager.shared.isConnected {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            return
        }
        
        if shouldShowHUD {
            LoadingIndicator.show()
        }
        
        let url = Constants.baseUrl + strMethod
        debugPrint("********************************************")

        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 300        // 🔥 Required to override 60s default timeout
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        APILogger.log(
            type: .request,
            endPoint: strMethod,
            url: url,
            method: "POST",
            headers: headers,
            params: rawJSONString ?? params,
            startTime: requestStartTime
        )
        
        //  debugPrint("Parameters: \(params ?? [:])")
        debugPrint("********************************************")
        
        // Use raw JSON string if provided (to preserve key order)
        if let rawJSONString = rawJSONString {
            urlRequest.httpBody = rawJSONString.data(using: .utf8)
            print("Ordered Raw JSON Parameters:\n\(rawJSONString)")
        } else if let params = params {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                urlRequest.httpBody = jsonData
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                }
            } catch {
                print("Error serializing params: \(error)")
            }
        }
        
        debugPrint("********************************************")
        
        longTimeoutSession.request(urlRequest).validate(statusCode: 200..<600).responseJSON { response in
            debugPrint("🔥 Reached inside response block for method: \(strMethod)")
            
            if shouldShowHUD {
                print("🔥 shouldShowHUD is TRUE for method: \(strMethod)")
                
                if strMethod == "purpose_of_payments" {
                    print("rjkios", strMethod)
                } else {
                    LoadingIndicator.hide()
                }
            }
            switch response.result {
            case .success(let value):
                let resJson = JSON(value)
                
                // Ensure `value` is a valid JSON object (dictionary or array)
                if let jsonObject = value as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            debugPrint("********************************************")
                            
                            print("\(strMethod) Formatted JSON Response:\n\(jsonString)")
                        }
                    } catch {
                        print("Error formatting JSON: \(error)")
                    }
                } else {
                    print("Received response is not a valid JSON object")
                }
                success(resJson)
                
                
            case .failure(let error):
            
                debugPrint("\(strMethod) Request failed: \(error)")
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                        let errorMessage = json?["message"] as? String
                        let errorCode = json?["status_code"] as? Int

                        print("🔥 Backend Error Message:", errorMessage ?? "Unknown error")
                        print("🔥 Backend Error Code:", errorCode ?? 0)
                   //     showAnimatedToast(message: StringConstants.pleaseTryAgain)

                    } catch {
                        print("❌ Failed to parse error JSON:", error)
                    }
                } else {
                    print("❌ No response data received")
                }
            }
        }
    }
    class func requestPOST2(_ strMethod: String,rawJSONString: String? = nil,params: [String: Any]? = nil,headers: [String: String]? = nil,shouldShowHUD: Bool = true,success: @escaping (JSON) -> Void,failure: @escaping (Error) -> Void) {

        // Check network
        if !NetworkManager.shared.isConnected {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            return
        }

        if shouldShowHUD {
            LoadingIndicator.show()
        }

        let url = strMethod
        debugPrint("********************************************")
        debugPrint("Request URL: \(url)")

        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 300        // 🔥 Required to override 60s default timeout
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
      //  debugPrint("Parameters: \(params ?? [:])")
        debugPrint("********************************************")
        
        // Use raw JSON string if provided (to preserve key order)
        if let rawJSONString = rawJSONString {
            urlRequest.httpBody = rawJSONString.data(using: .utf8)
            print("Ordered Raw JSON Parameters:\n\(rawJSONString)")
        } else if let params = params {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                urlRequest.httpBody = jsonData

                if let jsonString = String(data: jsonData, encoding: .utf8) {

                }
            } catch {
                print("Error serializing params: \(error)")
            }
        }

        debugPrint("********************************************")

        longTimeoutSession.request(urlRequest).validate(statusCode: 200..<600).responseJSON { response in

                if shouldShowHUD {
                    LoadingIndicator.hide()
                }

                switch response.result {
                case .success(let value):
                    let resJson = JSON(value)

                    // Ensure `value` is a valid JSON object (dictionary or array)
                    if let jsonObject = value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                            if let jsonString = String(data: jsonData, encoding: .utf8) {
                                debugPrint("********************************************")

                                print("\(strMethod) Formatted JSON Response:\n\(jsonString)")
                            }
                        } catch {
                            print("Error formatting JSON: \(error)")
                        }
                    } else {
                        print("Received response is not a valid JSON object")
                    }
                    success(resJson)

                case .failure(let error):
                    debugPrint("  \(strMethod) Upload failed: \(error)")
                    failure(error)
                }
            }
    }

    class func requestPOSTwithImage(_ strMethod : String,image : UIImage, params : [String : AnyObject]?, imageParam: String, headers : [String : String]?, shouldShowHUD: Bool = true, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        
        // Check network availability
        if !NetworkManager.shared.isConnected {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            return
        }
        
        if shouldShowHUD {
            LoadingIndicator.show()
        }
        
        let url = Constants.baseUrl + strMethod
        debugPrint("********************************************")
        debugPrint("Request URL: \(url)")
        if let params = params {
            do {
                // Convert params values to ensure they are JSON-compatible
                let validParams = params.mapValues { "\($0)" }
                
                let jsonData = try JSONSerialization.data(withJSONObject: validParams, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {

                }
            } catch {
                print("Error formatting parameters: \(error)")
            }
        } else {
            print("Parameters: {}")
        }
      //  debugPrint("Parameters: \(params ?? [:])")
        debugPrint("********************************************")
        
        // Convert headers to Alamofire format
        let afHeaders: HTTPHeaders? = headers != nil ? HTTPHeaders(headers!) : nil
        
        AF.upload(multipartFormData: { multipartFormData in
            
            // Compress and append image
            if let imageData = image.jpegData(compressionQuality: 0.25) {
                multipartFormData.append(imageData, withName: imageParam, fileName: "image.jpg", mimeType: "image/jpeg")
            }
            params?.sorted(by: { $0.key < $1.key }).forEach { key, value in
                if let data = "\(value)".data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
            // Append additional parameters
    //        params?.forEach { key, value in
    //            if let data = "\(value)".data(using: .utf8) {
    //                multipartFormData.append(data, withName: key)
    //            }
    //        }
            
        }, to: url, method: .post, headers: afHeaders)
        .validate()
        .responseJSON { response in
            
            if shouldShowHUD {
                LoadingIndicator.hide()
            }
            
            switch response.result {
            case .success(let value):
                let resJson = JSON(value)
                
                // Ensure `value` is a valid JSON object (dictionary or array)
                if let jsonObject = value as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            debugPrint("********************************************")

                            print("Formatted JSON Response:\n\(jsonString)")
                        }
                    } catch {
                        print("Error formatting JSON: \(error)")
                    }
                } else {
                    print("Received response is not a valid JSON object")
                }
                
                success(resJson)
            case .failure(let error):
                debugPrint("  \(strMethod) Upload failed: \(error)")
                failure(error)
            }
        }
    }
    
    class func requestUploadWithImage(
        _ strMethod: String,
        image: UIImage,
        orderedParams: [(String, Any)],
        imageParam: String,
        headers: [String: String]? = nil,
        method: HTTPMethod, // <-- You’ll pass .post or .put
        shouldShowHUD: Bool = true,
        success: @escaping (JSON) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        print("requestUploadWithImage called [Method: \(method.rawValue.uppercased())]")
        
        // 🔹 Check Internet
        if !NetworkManager.shared.isConnected {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            return
        }

//        // 🔹 Show HUD
//        if shouldShowHUD {
//            LoadingIndicator.show()
//        }

        // 🔹 Build URL
        let url = Constants.baseUrl + strMethod
        debugPrint("********************************************")
        debugPrint("Request URL: \(url)")

        // 🔹 Print Params
        do {
            let dict = Dictionary(uniqueKeysWithValues: orderedParams)
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Parameters:\n\(jsonString)")
            }
        } catch {
            print("Error formatting parameters: \(error)")
        }

        debugPrint("********************************************")

        // 🔹 Prepare Headers
        let afHeaders: HTTPHeaders? = headers != nil ? HTTPHeaders(headers!) : nil

        // 🔹 Upload
        longTimeoutSession.upload(
            multipartFormData: { multipartFormData in
                // Image
                if let imageData = image.jpegData(compressionQuality: 0.9) {
                    multipartFormData.append(
                        imageData,
                        withName: imageParam,
                        fileName: "image.jpg",
                        mimeType: "image/jpeg"
                    )
                }

                // Params
                for (key, value) in orderedParams {
                    if let data = "\(value)".data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            },
            to: url,
            method: method, // 👈 dynamic method
            headers: afHeaders
        )
        .validate()
        .responseJSON { response in
            if shouldShowHUD {
                LoadingIndicator.hide()
            }

            switch response.result {
            case .success(let value):
                let resJson = JSON(value)

                if let jsonObject = value as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            debugPrint("********************************************")
                            print("Formatted JSON Response:\n\(jsonString)")
                        }
                    } catch {
                        print("Error formatting JSON: \(error)")
                    }
                } else {
                    print("Received response is not a valid JSON object")
                }

                success(resJson)

            case .failure(let error):
                debugPrint("Upload failed: \(error)")
                failure(error)
            }
        }
    }
    class func requestUploadWithMultipleImages(
        _ strMethod: String,
        images: [(param: String, image: UIImage)],
        orderedParams: [(String, Any)],
        headers: [String: String]? = nil,
        method: HTTPMethod,
        shouldShowHUD: Bool = true,
        success: @escaping (JSON) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        print("requestUploadWithImage called [Method: \(method.rawValue.uppercased())]")

        if !NetworkManager.shared.isConnected {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            return
        }

        if shouldShowHUD {
            LoadingIndicator.show()
        }

        let url = Constants.baseUrl + strMethod
        debugPrint("********************************************")
        debugPrint("Request URL: \(url)")
        debugPrint("********************************************")

        let afHeaders: HTTPHeaders? = headers != nil ? HTTPHeaders(headers!) : nil

        longTimeoutSession.upload(
            multipartFormData: { multipartFormData in

                // 🔹 Upload Multiple Images
                for (index, item) in images.enumerated() {
                    if let imageData = item.image.jpegData(compressionQuality: 0.9) {
                        multipartFormData.append(
                            imageData,
                            withName: item.param,
                            fileName: "image\(index).jpg",
                            mimeType: "image/jpeg"
                        )
                    }
                }

                // 🔹 Params
                for (key, value) in orderedParams {
                    if let data = "\(value)".data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }

            },
            to: url,
            method: method,
            headers: afHeaders
        )
        .validate()
        .responseJSON { response in

            if shouldShowHUD {
                LoadingIndicator.hide()
            }

            switch response.result {

            case .success(let value):
                let resJson = JSON(value)
                success(resJson)

            case .failure(let error):
                debugPrint("Upload failed: \(error)")
                failure(error)
            }
        }
    }
//    class func requestPOSTwithVideo(_ strMethod : String,image : UIImage, params : [String : AnyObject]?, imageParam: String, headers : [String : String]?, shouldShowHUD: Bool = true, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
//
//        //check the network availability
//
//        if NetworkManager.sharedInstance.reachability.connection == .none {
//
//            showTopBanner(message: StringConstants.noInternetConnectionFound)
//            return
//        }
//
//        if shouldShowHUD {
//
//            LoadingIndicator.show()
//
//            // Common.showNetworkActivity()
//        }
//
//        let URL = Constants.baseUrl + strMethod
//
//        Alamofire.upload(multipartFormData:{ multipartFormData in
//            //            let videoURL = info[UIImagePickerControllerMediaURL] as! URL
//            //
//            //            if let imageData = image.jpegData(compressionQuality: 0.25) {
//            //                multipartFormData.append(videoURL, withName: "File1", fileName: "video.mp4", mimeType: "video/mp4")
//            //
//            //            }
//            for (key, value) in params! {
//
//                multipartFormData.append(("VIDEO".data(using: String.Encoding.utf8, allowLossyConversion: false))!, withName: "Type")
//
//            }},
//                         usingThreshold:UInt64.init(),
//                         to:URL,
//                         method:.post,
//                         headers:headers,
//                         encodingCompletion: { encodingResult in
//            switch encodingResult {
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    let json =  JSON(response.result.value!)
//                    debugPrint(json)
//                    if shouldShowHUD {
//
//                        LoadingIndicator.hide()
//
//                        //  Common.hideNetworkActivity()
//                    }
//                    success(json)
//                }
//            case .failure(let encodingError):
//                debugPrint(encodingError)
//                if shouldShowHUD {
//
//                    LoadingIndicator.hide()
//
//                    //  Common.hideNetworkActivity()
//                }
//                failure(encodingError)
//            }
//        })
//    }
    
//    class func requestPOSTwithMultipleImage(_ strMethod : String,image : UIImage, image1 : UIImage,  params : [String : AnyObject]?, imageParam: String, imageParam1: String, headers : [String : String]?, shouldShowHUD: Bool = true, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
//
//        //check the network availability
//
//        if NetworkManager.sharedInstance.reachability.connection == .none {
//
//            showTopBanner(message: StringConstants.noInternetConnectionFound)
//            return
//        }
//
//        if shouldShowHUD {
//            LoadingIndicator.show()
//
//            // Common.showNetworkActivity()
//        }
//
//        let URL = Constants.baseUrl + strMethod
//
//        Alamofire.upload(multipartFormData:{ multipartFormData in
//            if let imageData = image.jpegData(compressionQuality: 0.25) {
//                multipartFormData.append(imageData, withName: imageParam, fileName: "image.jpg", mimeType: "image/jpg")
//            }
//            if let imageData1 = image1.jpegData(compressionQuality: 0.25) {
//                multipartFormData.append(imageData1, withName: imageParam1, fileName: "image.jpg", mimeType: "image/jpg")
//            }
//
//
//
//            for (key, value) in params! {
//
//                multipartFormData.append((value as AnyObject).data(using:String.Encoding.utf8.rawValue)!, withName: key)
//            }},
//                         usingThreshold:UInt64.init(),
//                         to:URL,
//                         method:.post,
//                         headers:headers,
//                         encodingCompletion: { encodingResult in
//            switch encodingResult {
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    let json =  JSON(response.result.value!)
//                    debugPrint(json)
//                    if shouldShowHUD {
//                        LoadingIndicator.hide()
//
//                        // Common.hideNetworkActivity()
//                    }
//                    success(json)
//                }
//            case .failure(let encodingError):
//                debugPrint(encodingError)
//                if shouldShowHUD {
//                    LoadingIndicator.hide()
//
//                    // Common.hideNetworkActivity()
//                }
//                failure(encodingError)
//            }
//        })
//    }
}
