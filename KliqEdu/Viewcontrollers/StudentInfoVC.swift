//
//  StudentInfoVC.swift
//  KliqEdu
//
//  Created by codegama on 06/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class StudentInfoVC: UIViewController {

    @IBOutlet weak var placeHolderNameLbl: UILabel!
    @IBOutlet weak var studentPicture: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var idLbl1: UILabel!
    @IBOutlet weak var rollNumberLbl: UILabel!
    @IBOutlet weak var admissionDateLbl: UILabel!
    @IBOutlet weak var gradeLbl1: UILabel!
    
    @IBOutlet weak var dobLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var bgLbl: UILabel!
    @IBOutlet weak var religionLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var fatherNameLbl: UILabel!
    @IBOutlet weak var motherNameLbl: UILabel!
    @IBOutlet weak var fatherOccupationLbl: UILabel!
    @IBOutlet weak var motherOccupationLbl: UILabel!
    
    var comingFrom = ""
    var studentId: String = ""
    var fatherMobile: String = ""
    var motherMobile: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        self.idLbl.layer.cornerRadius = 15
        self.idLbl.layer.masksToBounds = true
        self.gradeLbl.layer.cornerRadius = 15
        self.gradeLbl.layer.masksToBounds = true
        self.placeHolderNameLbl.layer.cornerRadius = 25
        self.placeHolderNameLbl.layer.masksToBounds = true
        
        if comingFrom == "home"{
            self.editBtn.unhide()
        }else{
            self.editBtn.hide()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startViewAnimation()
        getStudentInfoApi()
    }
    func startViewAnimation()  {
        studentPicture.showSkeleton(cornerRadius: 10)
        nameLbl.hideSkeleton()
        gradeLbl.showSkeleton(cornerRadius: 10)
        idLbl.showSkeleton(cornerRadius: 10)
        idLbl1.showSkeleton(cornerRadius: 10)
        rollNumberLbl.showSkeleton(cornerRadius: 10)
        admissionDateLbl.showSkeleton(cornerRadius: 10)
        dobLbl.showSkeleton(cornerRadius: 10)
        genderLbl.showSkeleton(cornerRadius: 10)
        bgLbl.showSkeleton(cornerRadius: 10)
        religionLbl.showSkeleton(cornerRadius: 10)
        addressLbl.showSkeleton(cornerRadius: 10)
        fatherNameLbl.showSkeleton(cornerRadius: 10)
        motherNameLbl.showSkeleton(cornerRadius: 10)

    }
    func stopViewAnimation()  {
        studentPicture.hideSkeleton()
        nameLbl.hideSkeleton()
        gradeLbl.hideSkeleton()
        idLbl.hideSkeleton()
        idLbl1.hideSkeleton()
        rollNumberLbl.hideSkeleton()
        admissionDateLbl.hideSkeleton()
        dobLbl.hideSkeleton()
        genderLbl.hideSkeleton()
        bgLbl.hideSkeleton()
        religionLbl.hideSkeleton()
        addressLbl.hideSkeleton()
        fatherNameLbl.hideSkeleton()
        motherNameLbl.hideSkeleton()
    }
    func getStudentInfoApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(studentId)",params: param, HTTPMethod: .get)
      
            self.callServiceMethod(service: "\(Constants.Urls.studentInfoUrl)/\(studentId)",method: .get, params: param, key: "studentInfoUrl", headers: headers)
    }
    @IBAction func editBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "EditStudentProfileVC") as? EditStudentProfileVC {

            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func fatherCallBtnTapped(_ sender: Any) {
        let mobile = fatherMobile.trimmingCharacters(in: .whitespacesAndNewlines)

        if mobile.isEmpty {
            self.showAnimatedToast(message: "Father mobile number not available", type: .warning)
            return
        }

        let alert = UIAlertController(title: "Call Father", message: mobile, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { _ in
            if let url = URL(string: "tel://\(mobile)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))

        self.present(alert, animated: true)
    }
    @IBAction func motherCallBtnTapped(_ sender: Any) {
        let mobile = motherMobile.trimmingCharacters(in: .whitespacesAndNewlines)

        if mobile.isEmpty {
            self.showAnimatedToast(message: "Mother mobile number not available", type: .warning)
            return
        }

        let alert = UIAlertController(title: "Call Mother", message: mobile, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { _ in
            if let url = URL(string: "tel://\(mobile)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))

        self.present(alert, animated: true)
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "studentInfoUrl"{
                        self.stopViewAnimation()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {

                               let firstName = dataList["firstname"] as? String ?? ""
                               let lastName = dataList["lastname"] as? String ?? ""
                               let fullName = "\(firstName) \(lastName)"

                               self.nameLbl.text = fullName
                               self.gradeLbl.text = dataList["grade_formatted"] as? String ?? "-"
                               self.gradeLbl1.text = dataList["grade_formatted"] as? String ?? "-"
                               self.idLbl.text = dataList["unique_id"] as? String ?? "-"
                               self.idLbl1.text = dataList["unique_id"] as? String ?? "-"
                               self.rollNumberLbl.text = dataList["group"] as? String ?? "-"
                               self.admissionDateLbl.text = dataList["join_date"] as? String ?? "-"
                               self.dobLbl.text = dataList["dob"] as? String ?? "-"
                               self.genderLbl.text = dataList["gender"] as? String ?? "-"
                               self.bgLbl.text = dataList["blood_group"] as? String ?? "-"
                               self.religionLbl.text = dataList["religion"] as? String ?? "-"
                               self.addressLbl.text = dataList["parent_address"] as? String ?? "-"
                               self.fatherNameLbl.text = dataList["father_name"] as? String ?? "-"
                               self.motherNameLbl.text = dataList["mother_name"] as? String ?? "-"
                               self.fatherMobile = dataList["father_mobile"] as? String ?? ""
                               self.motherMobile = dataList["mother_mobile"] as? String ?? ""
                                self.fatherOccupationLbl.text = "Father / \(dataList["father_occupation"] as? String ?? "-")"
                                self.motherOccupationLbl.text = "Mother / \(dataList["mother_occupation"] as? String ?? "-")"

                               let imageUrl = dataList["student_picture"] as? String ?? ""

                               if imageUrl != "" {

                                   self.studentPicture.sd_setImage(with: URL(string: imageUrl),placeholderImage: UIImage(named: "profile_placeholder")
                                   )
                               } else {
                                   self.studentPicture.image = UIImage(named: "profile_placeholder")
                               }
                          //  let imageURL = (imageURL).trimmingCharacters(in: .whitespacesAndNewlines)

                            if !imageUrl.isEmpty {
                                self.placeHolderNameLbl.isHidden = true
                                self.studentPicture.isHidden = false
                                self.studentPicture.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
                            } else {
                                self.studentPicture.image = nil
                                self.studentPicture.isHidden = true
                                self.placeHolderNameLbl.isHidden = false
                                let fullName = (fullName).trimmingCharacters(in: .whitespacesAndNewlines)
                                let words = fullName.split(separator: " ")
                                let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                                let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                                self.placeHolderNameLbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
                            }

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
