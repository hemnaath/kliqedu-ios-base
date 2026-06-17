//
//  LaunchVC.swift
//  TodoApp
//
//  Created by Karthick RJ on 06/11/23.
//

import UIKit
import LocalAuthentication

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let defaults = UserDefaults.standard
var userID = Int()//
var token = String()
var api_Key = String()
var salt_Key = String()
var private_key = String()
var serviceType_Key = Int()
var roleKey = String()
var onboardingStep = Int()
var kycStatus = Int()
var tfaStatus = Int()

var finalSig = String()

let isFirstLaunch = defaults.bool(forKey: "isLaunched")
var modeState: Int?

class LaunchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        userID = defaults.value(forKey: Constants.Keys.userIdKey) as? Int ?? 0
        token = defaults.value(forKey: Constants.Keys.accessTokenKey) as? String ?? ""
        api_Key = defaults.value(forKey: Constants.Keys.apiKey) as? String ?? ""
        salt_Key = defaults.value(forKey: Constants.Keys.saltKey) as? String ?? ""
        private_key = defaults.value(forKey: Constants.Keys.private_key) as? String ?? ""
        finalSig = defaults.value(forKey: Constants.Keys.finalSignature) as? String ?? ""
        roleKey = defaults.value(forKey: Constants.Keys.roleKey) as? String ?? ""

        kycStatus = defaults.value(forKey: Constants.Keys.kycVerified) as? Int ?? 0

        onboardingStep = defaults.value(forKey: Constants.Keys.onboardingKey) as? Int ?? 0
        firstLaunch()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    fileprivate func firstLaunch() {
        
        if !isFirstLaunch{
            let seconds = 1.5

            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                
                let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }

            }
        }else{
            self.checkIfLoggedIn()
        }
    }
    fileprivate func checkIfLoggedIn() {
        let seconds = 1.5
        if UserDefaults.standard.bool(forKey: Constants.Keys.isLoggedIn) {
            if UserDefaults.standard.bool(forKey: Constants.Keys.faceID) == true{
                
                authenticateWithFaceID { [weak self] success in
                    DispatchQueue.main.async {
                        if success {
                            print("Face ID Authentication successful.")
                            // Proceed to the main app
                            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
                            if let vc = sb.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                                
                                self?.navigationController?.pushViewController(vc, animated: true)
                            }
                        } else {
                            print("Face ID Authentication failed.")
                            // Handle failure (e.g., show an alert or lock the app)
                            self?.showAuthenticationFailedAlert()
                        }
                    }
                }
            }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {

                        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
                        if let vc = sb.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
                    if let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    func authenticateWithFaceID(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
            context.localizedCancelTitle = "Cancel"
            context.localizedFallbackTitle = "Use Passcode" // Fallback to system passcode

            let reason = "Authenticate with Face ID or Passcode to access the app"

            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                    completion(success)
                }
            } else {
                // Device does not support Face ID or Passcode
                completion(false)
            }
    }
    func showAuthenticationFailedAlert() {
           let alert = UIAlertController(title: "Authentication Failed", message: "Unable to authenticate with Face ID. Please try again.", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            self.checkIfLoggedIn() // Retry authentication
           }))
           alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { _ in
              // exit(0) // Exit the app (optional)
               UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
           }))
           present(alert, animated: true, completion: nil)
       }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
