//
//  HomeworkViewVC.swift
//  KliqEdu
//
//  Created by codegama on 13/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomeworkViewVC: UIViewController {

    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
//    @IBOutlet weak var createdByLbl: UILabel!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var attachmentNameLbl: UILabel!
    @IBOutlet weak var attachmentImg: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!

    var homeworkDetails = HomeWorkModel(dictionary: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.subjectLbl.layer.cornerRadius = 10
        self.subjectLbl.layer.masksToBounds = true

        self.gradeLbl.layer.cornerRadius = 10
        self.gradeLbl.layer.masksToBounds = true

        self.attachmentView.layer.cornerRadius = 12
        self.attachmentView.layer.borderWidth = 1
        self.attachmentView.layer.borderColor = UIColor.systemGray5.cgColor

        self.titleLbl.text = homeworkDetails?.title
        self.descriptionLbl.text = homeworkDetails?.descriptionValue
        self.subjectLbl.text = homeworkDetails?.subject
        self.dateLbl.text = homeworkDetails?.date
        self.gradeLbl.text = "Grade \(homeworkDetails?.grade ?? "") \(homeworkDetails?.section ?? "")"
      //  self.sectionLbl.text = homeworkDetails?.section ?? "All"
     //   self.createdByLbl.text = homeworkDetails?.created_by

        if let file = homeworkDetails?.file, !file.isEmpty {
            self.attachmentView.isHidden = false
            self.attachmentNameLbl.text = (file as NSString).lastPathComponent
            self.attachmentImg.image = UIImage(systemName: "doc.fill")
        } else {
            self.attachmentView.isHidden = true
        }

        self.editBtn.isHidden = !(homeworkDetails?.is_editable ?? false)
        self.deleteBtn.isHidden = !(homeworkDetails?.is_deletable ?? false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startViewAnimation()
        getHomeworkInfoApi()
    }
    func getHomeworkInfoApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(homeworkDetails?.unique_id ?? "")",params: param, HTTPMethod: .get)
            
        self.callServiceMethod(service: "\(Constants.Urls.viewHomeworkUrl)/\(homeworkDetails?.unique_id ?? "")",method: .get, params: param, key: "viewHomeworkUrl", headers: headers)
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

    @IBAction func editBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "AddHomeworkVC") as? AddHomeworkVC {
            vc.comingFrom = "edit"
            vc.homeworkDetails = homeworkDetails
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func deleteBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: Constants.appName, message: StringConstants.sureToDeleteTheHomework, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: StringConstants.yes, style: UIAlertAction.Style.destructive, handler: { action in
            
            let param = [:] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.homeworkDetails?.unique_id ?? "")",params: param, HTTPMethod: .delete)
            
            self.callServiceMethod(service: "\(Constants.Urls.deleteHomeworkUrl)/\(self.homeworkDetails?.unique_id ?? "")",method: .delete, params: param, key: "deleteHomeworkUrl", headers: headers)
            
        }))
        alert.addAction(UIAlertAction(title: StringConstants.no, style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func attachmentBtnTapped(_ sender: Any) {
        print("Open Attachment")
    }

    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "deleteHomeworkUrl"{

                        DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        }
                    }else if key == "viewHomeworkUrl"{
                        self.stopViewAnimation()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {

                            self.homeworkDetails = HomeWorkModel(dictionary: dataList)

                            self.titleLbl.text = self.homeworkDetails?.title?.firstUppercased
                            self.descriptionLbl.text = self.homeworkDetails?.descriptionValue?.firstUppercased
                            self.dateLbl.text = " Added on \(self.homeworkDetails?.created_at ?? "")"
                            self.editBtn.isHidden = !(self.homeworkDetails?.is_editable ?? false)
                            self.deleteBtn.isHidden = !(self.homeworkDetails?.is_deletable ?? false)
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                
                let errorCode: Int = result!["error_code"] as? Int ?? 0
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
