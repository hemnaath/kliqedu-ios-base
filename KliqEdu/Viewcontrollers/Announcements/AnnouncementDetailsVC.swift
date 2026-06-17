//
//  AnnouncementDetailsVC.swift
//  KliqEdu
//
//  Created by codegama on 10/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class AnnouncementDetailsVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    var announcementDetails = AnnouncementModel(dictionary: [:])
    var uniqueId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if roleKey == "parent"{
            self.titleLbl.text = self.announcementDetails?.title
            self.descriptionLbl.text = self.announcementDetails?.descriptionValue
            self.dateLbl.text = "Created on \(self.announcementDetails?.created_at ?? "")"

            self.editBtn.isHidden = !(self.announcementDetails?.is_editable ?? false)
            self.deleteBtn.isHidden = !(self.announcementDetails?.is_deletable ?? false)

        }else{
            startViewAnimation()
            getAnnouncementInfoApi()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    func getAnnouncementInfoApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(uniqueId)",params: param, HTTPMethod: .get)
      
        self.callServiceMethod(service: "\(Constants.Urls.viewAnnouncementUrl)/\(uniqueId)",method: .get, params: param, key: "viewAnnouncementUrl", headers: headers)
    }
    func startViewAnimation()  {
        titleLbl.showSkeleton(cornerRadius: 10)
        descriptionLbl.showSkeleton(cornerRadius: 10)
        dateLbl.showSkeleton(cornerRadius: 10)
        deleteBtn.showSkeleton(cornerRadius: 10)
        editBtn.showSkeleton(cornerRadius: 10)

    }
    func stopViewAnimation()  {
        titleLbl.hideSkeleton()
        descriptionLbl.hideSkeleton()
        dateLbl.hideSkeleton()
        deleteBtn.hideSkeleton()
        editBtn.hideSkeleton()

    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func deleteBtnTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: Constants.appName, message: StringConstants.sureToDeleteTheAnnouncement, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: StringConstants.yes, style: UIAlertAction.Style.destructive, handler: { action in
            
            let param = [:] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.announcementDetails?.unique_id ?? "")",params: param, HTTPMethod: .delete)
            
            self.callServiceMethod(service: "\(Constants.Urls.deleteAnnouncementUrl)/\(self.uniqueId)",method: .delete, params: param, key: "deleteAnnouncementUrl", headers: headers)
            
        }))
        alert.addAction(UIAlertAction(title: StringConstants.no, style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "CreateAnnouncementVC") as? CreateAnnouncementVC {
            vc.comingFrom = "edit"
            vc.announcementDetails = announcementDetails
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "deleteAnnouncementUrl"{

                        DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        }
                    }else if key == "viewAnnouncementUrl"{
                        self.stopViewAnimation()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {

                            self.announcementDetails = AnnouncementModel(dictionary: dataList)

                            self.titleLbl.text = self.announcementDetails?.title
                            self.descriptionLbl.text = self.announcementDetails?.descriptionValue
                            self.dateLbl.text = "Created on \(self.announcementDetails?.created_at ?? "")"

                            self.editBtn.isHidden = !(self.announcementDetails?.is_editable ?? false)
                            self.deleteBtn.isHidden = !(self.announcementDetails?.is_deletable ?? false)

                        }
                    }
                    
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                
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
}
