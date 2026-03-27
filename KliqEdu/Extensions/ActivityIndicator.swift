//
//  ActivityIndicator.swift
//  ICH
//
//  Created by DOBLE N J on 18/12/17.
//  Copyright © 2017 BTeem. All rights reserved.
//

import UIKit
import SVProgressHUD

class ActivityIndicator: NSObject {
    
    /// Shows activity
    ///
    /// - Parameters:
    ///   - view: View witch the activity is presenting
    class func showActivity(){
        
        SVProgressHUD.show()
    }
    
    /// Dismiss activity
    class func hideActivity() {
        
        SVProgressHUD.dismiss()
    }
    
    /// Show alert
    ///
    /// - Parameter alert: Alert string
    class func showInfoAlert(_ alert: String){
        
        SVProgressHUD.showInfo(withStatus: alert)
    }
    
    /// Show error alert
    ///
    /// - Parameter alert: Alert string
    class func showErrorAlert(_ alert: String) {
        SVProgressHUD.dismiss(withDelay: 1.0)
        SVProgressHUD.showError(withStatus: alert)
    }
    
    /// Show success alert
    ///
    /// - Parameter alert: String
    class func showSuccessAlert(_ alert: String) {
        
        SVProgressHUD.showSuccess(withStatus: alert)
    }
}
