//
//  StaticPagesVC.swift
//  EFIBank
//
//  Created by Karthick RJ on 14/06/24.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class StaticPagesVC: UIViewController {

    @IBOutlet weak var staticPageView: UITextView!
    @IBOutlet weak var titleLbl: UILabel!
    
    //MARK: Variables
    var heading : String? = ""
    var contentString : String? = ""
    var arrayList = [StaticPagesModel]()
    let defaults = UserDefaults.standard
    var pageType : String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.titleLbl.text = heading
        LoadingIndicator.show()

        getStaticPages()
    }
    func getStaticPages(){
        
        let param = [:] as [String : Any]
               
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(pageType ?? "")",params: param,HTTPMethod: .get)

        self.callServiceMethod(service: "\(Constants.Urls.staticPageUrl)/\(pageType ?? "")",method: .get, params: param, key: "staticPages", headers: headers)
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "staticPages"{
                        
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary{
                            var data = String()
                            LoadingIndicator.hide()

                            if self.pageType == "terms-and-conditions"{
                                 data = dataList["terms_and_conditions"] as? String ?? ""
                            }else if self.pageType == "privacy-policy"{
                                 data = dataList["privacy-policy"] as? String ?? ""
                            }
                            DispatchQueue.main.async {
                                let font = UIFont(name: GLOBAL.FontsIdentifier.FontRegular, size: 16) ?? UIFont.systemFont(ofSize: 16)
                                
                                let styledHTML = """
                                <style>
                                body {
                                    font-family: '\(font.fontName)';
                                    font-size: 16px;
                                    color: black;
                                    text-align: left;
                                    line-height: 1.5;
                                }
                                </style>\(data)
                                """
                                
                                if let attributedData = styledHTML.data(using: .utf8) {
                                    do {
                                        let attributedString = try NSAttributedString(
                                            data: attributedData,
                                            options: [
                                                .documentType: NSAttributedString.DocumentType.html,
                                                .characterEncoding: String.Encoding.utf8.rawValue
                                            ],
                                            documentAttributes: nil
                                        )
                                        self.staticPageView.attributedText = attributedString
                                    } catch {
                                        print("HTML parse error:", error)
                                        self.staticPageView.text = data
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {

                let errorCode: Int = result!["error_code"] as? Int ?? 0
                let msg = result!["error"] as? String ?? ""
                
               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }

            }
        }) { (error) in

            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            
            debugPrint(error)
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
}
