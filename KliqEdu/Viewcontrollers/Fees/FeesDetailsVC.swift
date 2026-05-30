//
//  FeesDetailsVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import SwiftyRSA
import CryptoSwift
import SDWebImage

class FeesDetailsVC: UIViewController {
    
    @IBOutlet weak var placeHolderNameLbl: UILabel!
    @IBOutlet weak var studentPic: UIImageView!
    @IBOutlet weak var staudentNameLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
    
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    
    @IBOutlet weak var feesTypeLbl: UILabel!
    @IBOutlet weak var invoiceIdLbl: UILabel!
    @IBOutlet weak var dateTitleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var paymentFileNameLbl: UILabel!
    @IBOutlet weak var paymentFileView: UIView!
    
    var feeDetails = FeesModel(dictionary: [:])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gradeLbl.layer.cornerRadius = 15
        self.gradeLbl.layer.masksToBounds = true
        self.placeHolderNameLbl.layer.cornerRadius = 10
        self.placeHolderNameLbl.layer.masksToBounds = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startViewAnimation()
        getFeesInfoApi()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
    func startViewAnimation()  {
        feesTypeLbl.showSkeleton(cornerRadius: 10)
     //   staudentNameLbl.showSkeleton(cornerRadius: 10)
        gradeLbl.showSkeleton(cornerRadius: 10)
        invoiceIdLbl.showSkeleton(cornerRadius: 10)
        dateLbl.showSkeleton(cornerRadius: 10)
       // amountLbl.showSkeleton(cornerRadius: 10)
        statusLbl.showSkeleton(cornerRadius: 10)
        placeHolderNameLbl.showSkeleton(cornerRadius: 10)

    }
    func stopViewAnimation()  {

        feesTypeLbl.hideSkeleton()
      //  staudentNameLbl.hideSkeleton()
        gradeLbl.hideSkeleton()
        invoiceIdLbl.hideSkeleton()
        dateLbl.hideSkeleton()
      //  amountLbl.hideSkeleton()
        statusLbl.hideSkeleton()
        placeHolderNameLbl.hideSkeleton()

    }

    func setupUi(){
        self.feesTypeLbl.text = self.feeDetails?.fee_type
        self.staudentNameLbl.text = (self.feeDetails?.student_name)?.firstUppercased
        self.gradeLbl.text = "Grade \(self.feeDetails?.student_grade ?? "")"
        self.invoiceIdLbl.text = self.feeDetails?.unique_id ?? ""
        self.dateLbl.text = self.feeDetails?.due_date
        self.amountLbl.text = "\(self.feeDetails?.remaining_amount ?? "")"

        self.statusLbl.text = self.feeDetails?.status
        
        let imageUrl = self.feeDetails?.student_picture ?? ""
        
        if !imageUrl.isEmpty {
            self.placeHolderNameLbl.isHidden = true
            self.studentPic.isHidden = false
            self.studentPic.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
        } else {
            self.studentPic.image = nil
            self.studentPic.isHidden = true
            self.placeHolderNameLbl.isHidden = false
            let fullName = (self.feeDetails?.student_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let words = fullName.split(separator: " ")
            let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
            let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
            self.placeHolderNameLbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
        }
        
        let paymentPicture = feeDetails?.payment_picture?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !paymentPicture.isEmpty && paymentPicture.lowercased() != "null" {
            self.paymentFileView.unhide()
        } else {
//            if feeDetails?.status == "Pending" {
//                self.continueBtn.setTitle("Reupload Payment File", for: .normal)
//            } else {
//                self.continueBtn.setTitle("Continue", for: .normal)
//            }
            self.paymentFileView.hide()
        }
        
        self.paymentFileNameLbl.text = "\(random(digits: 15)).png"

        let status = self.feeDetails?.status ?? ""
        
        switch status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            
        case "pending":
            statusImg.image = UIImage(systemName: "clock.fill")
            statusView.backgroundColor = .systemOrange.withAlphaComponent(0.15)
            statusLbl.textColor = .systemOrange
            statusImg.tintColor = .systemOrange
            self.amountLbl.text = "\(self.feeDetails?.remaining_amount ?? "")"
            self.dateTitleLbl.text = "Due Date"
            
        case "success", "paid":
            statusImg.image = UIImage(systemName: "checkmark.circle.fill")
            statusView.backgroundColor = .systemGreen.withAlphaComponent(0.15)
            statusLbl.textColor = .systemGreen
            statusImg.tintColor = .systemGreen
            self.amountLbl.text = "\(self.feeDetails?.paid_amount ?? "")"
            self.dateTitleLbl.text = "Paid Date"
            self.continueBtn.hide()
        case "failed":
            statusImg.image = UIImage(systemName: "xmark.circle.fill")
            statusView.backgroundColor = .systemRed.withAlphaComponent(0.15)
            statusLbl.textColor = .systemRed
            statusImg.tintColor = .systemRed
            
        case "overdue":
            statusImg.image = UIImage(systemName: "exclamationmark.triangle.fill")
            statusView.backgroundColor = .systemPurple.withAlphaComponent(0.15)
            statusLbl.textColor = .systemPurple
            statusImg.tintColor = .systemPurple
            
        case "partial":
            statusImg.image = UIImage(systemName: "minus.circle.fill")
            statusView.backgroundColor = .systemBlue.withAlphaComponent(0.15)
            statusLbl.textColor = .systemBlue
            statusImg.tintColor = .systemBlue
            
        default:
            statusImg.image = UIImage(systemName: "clock.fill")
        }
    }
    func getFeesInfoApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(feeDetails?.unique_id ?? "")",params: param, HTTPMethod: .get)
            
        self.callServiceMethod(service: "\(Constants.Urls.feesDetailsUrl)/\(feeDetails?.unique_id ?? "")",method: .get, params: param, key: "feesDetailsUrl", headers: headers)

    }
    func random(digits:Int) -> String {
           var number = String()
           for _ in 1...digits {
              number += "\(Int.random(in: 1...9))"
           }
           return number
       }
    @IBAction func continueTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "PaymentVC") as? PaymentVC {
            vc.feeDetails = feeDetails
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func copyBtnTapped(_ sender: Any) {
        UIPasteboard.general.string = self.feeDetails?.unique_id ?? ""
        self.showAnimatedToast(message: "Invoice ID Copied")
    }
    @IBAction func paymentFileTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ImageVC") as? ImageVC {
            vc.pic = feeDetails?.payment_picture ?? ""
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical   // animation
    
            present(vc, animated: true)
        }
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "feesDetailsUrl"{
                        self.stopViewAnimation()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {

                            self.feeDetails = FeesModel(dictionary: dataList)
                            self.setupUi()

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


