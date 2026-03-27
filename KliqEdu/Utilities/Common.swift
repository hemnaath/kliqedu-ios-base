//
//  Common.swift
//  OnlyAlly
//
//  Created by Karthick RJ on 20/05/21.
//

import Foundation
import UIKit
import SVProgressHUD

class Common: NSObject {

    /// To Get Storyboard
    ///
    /// - Parameter name: Name of Storyboard
    /// - Returns: UIStoryboard with input name
    
    class func getStoryBoard(name: String) -> UIStoryboard {
        
        return UIStoryboard.init(name: name, bundle: nil)
    }
    
    /// To show activity indicator
    class func showNetworkActivity() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /// To Hide activity indicator
    class func hideNetworkActivity() {
    
        SVProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    /// To show a message
    ///
    /// - Parameter message: message content
    class func showMessage(_ message : String) {
    
        //KRProgressHUD.showMessage(message)
        DispatchQueue.main.async {
            SVProgressHUD.showInfo(withStatus: message)
        }
    }
    class func showSuccessMessage(_ message : String) {
        
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    class func showInfoMessage(_ message : String) {
        
        SVProgressHUD.showInfo(withStatus: message)
    }
    
    class func showWarningMessage(_ message : String) {
        
        SVProgressHUD.showError(withStatus: message)
    }
    
    class func showErrorMessage(_ message : String) {
        
        SVProgressHUD.showError(withStatus: message)
    }
    
    /// To show api response -- Success or failure
    ///
    /// - Parameter dictionary: Api response dictionary
    class func showApiResponse(_ dictionary : NSDictionary) {
    
        if let msg = dictionary.value(forKey: "message") as? String {
        
            self.showMessage(msg)
        }
        
        if let msgAry = dictionary.value(forKey: "message") as? NSArray {
            
            self.showMessage(msgAry.componentsJoined(by: "\n"))
        }
    }
    
    /// Method to clear all informations stored when logged in
    class func clearLoginData() {
    
//        UserDefaults.standard.set(false, forKey: Constants.Keys.isLoggedIn)
//        UserDefaults.standard.removeObject(forKey: Constants.Keys.customerIdKey)
//        UserDefaults.standard.removeObject(forKey: self.getPrefixKey() + Constants.Keys.userNameKey)
    }
    
    /// Method find the current user is Logged in or not
    ///
    /// - Returns: True if logged in user
    class func isLoggedIn() -> Bool {
        
        if UserDefaults.standard.bool(forKey: Constants.Keys.isLoggedIn) {
            
            return true
            
        } else {
            
            return false
        }
    }
    
    /// Method find the current user is Logged in manual or not
    ///
    /// - Returns: True if logged in using manual
    class func isUserManuallyLogedIn() -> Bool {
        
        let loginType : String = UserDefaults.standard.value(forKey: Constants.Keys.loginTypeKey) as! String
        if loginType == "manual" {
            
            return true
            
        } else {
            
            return false
        }
    }
}
