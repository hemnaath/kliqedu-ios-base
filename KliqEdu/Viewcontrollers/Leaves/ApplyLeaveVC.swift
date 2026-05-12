//
//  ApplyLeaveVC.swift
//  KliqEdu
//
//  Created by codegama on 08/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkeletonView
import CRRefresh

class ApplyLeaveVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var enddateField: UITextField!
    @IBOutlet weak var startdateField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reasonTextView: UITextView!
    
    var leaveTypeArray = [LeaveTypeModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        reasonTextView.setPlaceholder("  Provide a brief reason for your request")
        reasonTextView.setPaddingTextView(12)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.isSkeletonable = true
        self.collectionView.showAnimatedGradientSkeleton()
        leaveTypesApi()
        
    }
    func leaveTypesApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/leave-types",params: param, HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.leaveTypesUrl,method: .get, params: param, key: "leaveTypesUrl", headers: headers)

    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
      
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "leaveTypesUrl"{
                        
                        let resDataDic = result?["data"] as? NSDictionary
                        
                        self.collectionView.hideSkeleton()
                        
                        let listArray = resDataDic?["holidays"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        self.leaveTypeArray.removeAll()
                        for item in listArray {
                            if let model = LeaveTypeModel(dictionary: item as NSDictionary) {
                                self.leaveTypeArray.append(model)
                            }
                        }
                    
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return leaveTypeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaveTypeCCell", for: indexPath) as? LeaveTypeCCell {
            let dataModel = leaveTypeArray[indexPath.row]
            
            cell.setBorderProperties(borderColor: .systemGray5, borderWidth: 0.8, cornerRadius: 10.0, masksToBounds: true)
            cell.typeLbl.text = dataModel.full_name
            
            // Assign different background colors based on section or item
            switch indexPath.item {
            case 0:
                cell.outerView.backgroundColor = UIColor(hex: "#FFF4F0")
            case 1:
                cell.outerView.backgroundColor = UIColor(hex: "#F1FFF3")
            case 2:
                cell.outerView.backgroundColor = UIColor(hex: "#F5F8FF")
            case 3:
                cell.outerView.backgroundColor = UIColor(hex: "#F7F1FF")
            case 4:
                cell.outerView.backgroundColor = UIColor(hex: "#FFF7D6")
            case 5:
                cell.outerView.backgroundColor = UIColor(hex: "#FFF4F0")
            case 6:
                cell.outerView.backgroundColor = UIColor(hex: "#F1FFF3")
            case 7:
                cell.outerView.backgroundColor = UIColor(hex: "#F5F8FF")
            case 8:
                cell.outerView.backgroundColor = UIColor(hex: "#F7F1FF")
            case 9:
                cell.outerView.backgroundColor = UIColor(hex: "#FFF7D6")
            default:
                cell.outerView.backgroundColor = UIColor(hex: "#FFF4F0")
            }
            return cell
        } else {
            
            return UICollectionViewCell()
        }
    }
}
