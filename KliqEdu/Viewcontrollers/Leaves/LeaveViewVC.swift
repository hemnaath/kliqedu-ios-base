//
//  LeaveViewVC.swift
//  KliqEdu
//
//  Created by codegama on 07/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class LeaveViewVC: UIViewController {

    @IBOutlet weak var placeHolderNameLbl: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var idNumberLbl: UILabel!
    @IBOutlet weak var fromTodateLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var editDeleteBtnView: UIStackView!
    @IBOutlet weak var rejectApproveBtnView: UIStackView!

    @IBOutlet weak var leaveTypeLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    
    @IBOutlet weak var approveRejectView: UIStackView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!

    var leaveDetails = LeaveModel(dictionary: [:])
    var uniqeId: String?
    var comingFrom = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        self.gradeLbl.layer.cornerRadius = 10
        self.gradeLbl.layer.masksToBounds = true
        self.statusLbl.layer.cornerRadius = 10
        self.statusLbl.layer.masksToBounds = true
        self.placeHolderNameLbl.layer.cornerRadius = 10
        self.placeHolderNameLbl.layer.masksToBounds = true
        
        self.statusLbl.tintColor = .systemOrange
        self.statusLbl.backgroundColor = .white

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch roleKey {
        case "parent":
            self.approveRejectView.hide()

        case "teacher":
            self.approveRejectView.unhide()

        default:
            self.approveRejectView.hide()
        }
        
        if comingFrom == "teacher"{
            self.approveRejectView.hide()
            startViewAnimation()
            getLeaveInfoApi()
        }else{
            if roleKey == "parent"{
                startViewAnimation()
                getLeaveInfoApi()
            }else{
                self.approveRejectView.unhide()
                self.editDeleteBtnView.hide()

                self.nameLbl.text = self.leaveDetails?.student_name ?? ""
                self.idNumberLbl.text = self.leaveDetails?.student_unique_id ?? ""
                self.gradeLbl.text = self.leaveDetails?.student_grade ?? ""
                
                let imageUrl = self.leaveDetails?.student_picture ?? ""
                
                if !imageUrl.isEmpty {
                    self.placeHolderNameLbl.isHidden = true
                    self.profilePic.isHidden = false
                    self.profilePic.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
                } else {
                    self.profilePic.image = nil
                    self.profilePic.isHidden = true
                    self.placeHolderNameLbl.isHidden = false
                    let fullName = (self.leaveDetails?.student_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let words = fullName.split(separator: " ")
                    let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                    let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                    self.placeHolderNameLbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
                }
                self.leaveTypeLbl.text = self.leaveDetails?.leave_type ?? ""
                self.fromTodateLbl.text = "\(self.leaveDetails?.start_date ?? "") - \(self.leaveDetails?.end_date ?? "")"

                self.dateLbl.text = "Submitted on \(self.leaveDetails?.created_at ?? "")"
                self.descLbl.text = self.leaveDetails?.reason ?? ""

                let status = (self.leaveDetails?.status ?? "").lowercased()

                self.statusLbl.text = self.leaveDetails?.status ?? ""

                switch status {
                case "approved":
                    self.statusLbl.textColor = .systemGreen

                case "rejected":
                    self.statusLbl.textColor = .systemRed

                default:
                    self.statusLbl.textColor = .systemOrange
                }
            }

        }
        
        
    }
    func getLeaveInfoApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(uniqeId ?? "")",params: param, HTTPMethod: .get)
            
        switch roleKey {
        case "parent":
            self.callServiceMethod(service: "\(Constants.Urls.parentleaveViewUrl)/\(uniqeId ?? "")",method: .get, params: param, key: "viewleaveUrl", headers: headers)

        case "teacher":
            self.callServiceMethod(service: "\(Constants.Urls.teacherleaveViewUrl)/\(uniqeId ?? "")",method: .get, params: param, key: "viewleaveUrl", headers: headers)

        default:
            break
        }
    }
    func startViewAnimation()  {
        nameLbl.showSkeleton(cornerRadius: 10)
        descLbl.showSkeleton(cornerRadius: 10)
        dateLbl.showSkeleton(cornerRadius: 10)
        fromTodateLbl.showSkeleton(cornerRadius: 10)
        leaveTypeLbl.showSkeleton(cornerRadius: 10)
        gradeLbl.showSkeleton(cornerRadius: 10)
        idNumberLbl.showSkeleton(cornerRadius: 10)
        statusLbl.showSkeleton(cornerRadius: 10)
        placeHolderNameLbl.showSkeleton(cornerRadius: 10)

    }
    func stopViewAnimation()  {
        nameLbl.hideSkeleton()
        descLbl.hideSkeleton()
        dateLbl.hideSkeleton()
        fromTodateLbl.hideSkeleton()
        leaveTypeLbl.hideSkeleton()
        gradeLbl.hideSkeleton()
        idNumberLbl.hideSkeleton()
        statusLbl.hideSkeleton()
        placeHolderNameLbl.hideSkeleton()

    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func approveBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: Constants.appName, message: StringConstants.sureToApproveTheleave, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: StringConstants.yes, style: UIAlertAction.Style.destructive, handler: { action in
            
            let param = ["status":"1"] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.leaveDetails?.unique_id ?? "")",params: param, HTTPMethod: .patch)
            
            self.callServiceMethod(service: "\(Constants.Urls.teacherleaveStutusUrl)/\(self.leaveDetails?.unique_id ?? "")",method: .patch, params: param, key: "statusLeaveUrl", headers: headers)

        }))
        alert.addAction(UIAlertAction(title: StringConstants.no, style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func reject(_ sender: Any) {
        let alert = UIAlertController(title: Constants.appName, message: StringConstants.sureToRejectTheleave, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: StringConstants.yes, style: UIAlertAction.Style.destructive, handler: { action in
            
            let param = ["status":"2"] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.leaveDetails?.unique_id ?? "")",params: param, HTTPMethod: .patch)
            
            self.callServiceMethod(service: "\(Constants.Urls.teacherleaveStutusUrl)/\(self.leaveDetails?.unique_id ?? "")",method: .patch, params: param, key: "statusLeaveUrl", headers: headers)
            
        }))
        alert.addAction(UIAlertAction(title: StringConstants.no, style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func deleteBtn(_ sender: Any) {
        let alert = UIAlertController(title: Constants.appName, message: StringConstants.sureToDeleteTheleave, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: StringConstants.yes, style: UIAlertAction.Style.destructive, handler: { action in
            
            let param = [:] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.leaveDetails?.unique_id ?? "")",params: param, HTTPMethod: .delete)
            switch roleKey {
            case "parent":
                self.callServiceMethod(service: "\(Constants.Urls.parentdeleteLeaveUrl)/\(self.leaveDetails?.unique_id ?? "")",method: .delete, params: param, key: "statusLeaveUrl", headers: headers)

            case "teacher":
                self.callServiceMethod(service: "\(Constants.Urls.teacherdeleteLeaveUrl)/\(self.leaveDetails?.unique_id ?? "")",method: .delete, params: param, key: "statusLeaveUrl", headers: headers)

            default:
                break
            }
            
        }))
        alert.addAction(UIAlertAction(title: StringConstants.no, style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func editBtn(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ApplyLeaveVC") as? ApplyLeaveVC {
            vc.comingFrom = "edit"
            vc.leaveDetails = leaveDetails
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
                    
                    if key == "statusLeaveUrl"{

                        DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        }
                    }else if key == "viewleaveUrl"{
                        self.stopViewAnimation()

                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {

                            self.leaveDetails = LeaveModel(dictionary: dataList)

                            if roleKey == "teacher" {
                                self.nameLbl.text = self.leaveDetails?.teacher_name ?? ""
                                self.idNumberLbl.text = self.leaveDetails?.teacher_unique_id ?? ""
                                self.gradeLbl.text = self.leaveDetails?.teacher_department ?? ""
                                
                                let imageUrl = dataList["teacher_picture"] as? String ?? ""

                                if !imageUrl.isEmpty {
                                    self.placeHolderNameLbl.isHidden = true
                                    self.profilePic.isHidden = false
                                    self.profilePic.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
                                } else {
                                    self.profilePic.image = nil
                                    self.profilePic.isHidden = true
                                    self.placeHolderNameLbl.isHidden = false
                                    let fullName = (self.leaveDetails?.teacher_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                                    let words = fullName.split(separator: " ")
                                    let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                                    let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                                    self.placeHolderNameLbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
                                }
                            } else {
                                self.nameLbl.text = self.leaveDetails?.student_name ?? ""
                                self.idNumberLbl.text = self.leaveDetails?.student_unique_id ?? ""
                                self.gradeLbl.text = self.leaveDetails?.student_grade ?? ""

                                let imageUrl = dataList["student_picture"] as? String ?? ""

                                if !imageUrl.isEmpty {
                                    self.placeHolderNameLbl.isHidden = true
                                    self.profilePic.isHidden = false
                                    self.profilePic.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
                                } else {
                                    self.profilePic.image = nil
                                    self.profilePic.isHidden = true
                                    self.placeHolderNameLbl.isHidden = false
                                    let fullName = (self.leaveDetails?.student_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                                    let words = fullName.split(separator: " ")
                                    let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                                    let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                                    self.placeHolderNameLbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
                                }
                            }

                            self.leaveTypeLbl.text = self.leaveDetails?.leave_type ?? ""
                            self.fromTodateLbl.text = "\(self.leaveDetails?.start_date ?? "") - \(self.leaveDetails?.end_date ?? "")"

                            self.dateLbl.text = "Submitted on \(self.leaveDetails?.created_at ?? "")"
                            self.descLbl.text = self.leaveDetails?.reason ?? ""

                            let status = (self.leaveDetails?.status ?? "").lowercased()

                            self.statusLbl.text = self.leaveDetails?.status ?? ""

                            switch status {
                            case "approved":
                                self.statusLbl.textColor = .systemGreen

                            case "rejected":
                                self.statusLbl.textColor = .systemRed

                            default:
                                self.statusLbl.textColor = .systemOrange
                            }

                            self.editBtn.isHidden = !(self.leaveDetails?.is_editable ?? false)
                            self.deleteBtn.isHidden = !(self.leaveDetails?.is_deletable ?? false)
                            self.editDeleteBtnView.isHidden = !(self.leaveDetails?.is_editable ?? false) && !(self.leaveDetails?.is_deletable ?? false)
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
