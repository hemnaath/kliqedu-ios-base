//
//  ParentProfileVC.swift
//  KliqEdu
//
//  Created by codegama on 12/05/26.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON
import SkeletonView

class ParentProfileVC: UIViewController {

    // Parent

    @IBOutlet weak var fathernameLbl: UILabel!
    @IBOutlet weak var mothernameLbl: UILabel!
    @IBOutlet weak var fatheroccupationLbl: UILabel!
    @IBOutlet weak var motheroccupationLbl: UILabel!
    @IBOutlet weak var fatherMobileLbl: UILabel!
    @IBOutlet weak var motherMobileLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!

    // Student
    @IBOutlet weak var dobLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var bgLbl: UILabel!
    @IBOutlet weak var religionLbl: UILabel!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var casteLbl: UILabel!
    
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var placeHolderNameLbl: UILabel!
    @IBOutlet weak var profileContainerView: UIView!

    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var studentBtn: UIButton!
    @IBOutlet weak var parentBtn: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    
    var studentProfileDetails: ParentProfileModel?
    var parentProfileDetails: ParentProfileModel?
    
    var selectedTab = String()
    var selectedImage1 = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        self.gradeLbl.layer.cornerRadius = 17.5
        self.gradeLbl.layer.masksToBounds = true
        self.placeHolderNameLbl.layer.cornerRadius = 25
        self.placeHolderNameLbl.layer.masksToBounds = true
        
        studentBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        parentBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.parentView.isHidden = true
        self.studentView.isHidden = false
        
        self.selectedTab = "student"
        let tap = UITapGestureRecognizer(target: self, action: #selector(labelAction(gesture:)))
        profileContainerView.isUserInteractionEnabled = true
        profileContainerView.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.showSkeleton(cornerRadius: 25)
        studentprofileApi()
        parentprofileApi()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func studentBtnTapped(_ sender: Any) {
        self.selectedTab = "student"

        studentBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        parentBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.parentView.isHidden = true
        self.studentView.isHidden = false
        self.nameLbl.unhide()
        self.gradeLbl.unhide()
        self.studentSetup()

    }
    @IBAction func parentBtnTapped(_ sender: Any) {
        self.selectedTab = "parent"

        studentBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        parentBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        self.parentView.isHidden = false
        self.studentView.isHidden = true
        
        self.nameLbl.hide()
        self.gradeLbl.hide()
        self.parentSetup()
    }
    @IBAction func editProfileTapped(_ sender: Any) {
        if selectedTab == "student"{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "EditStudentProfileVC") as? EditStudentProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "EditParentProfileVc") as? EditParentProfileVc {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func studentprofileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/student-profile",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.studentProfileUrl,method: .get, params: param, key: "studentProfileUrl", headers: headers)
    }
    func parentprofileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/parent-profile",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.parentProfileUrl,method: .get, params: param, key: "parentProfileUrl", headers: headers)
    }
    
    func studentSetup(){
        let firstName = self.studentProfileDetails?.firstname ?? ""
        let lastName = self.studentProfileDetails?.lastname ?? ""
        
        self.nameLbl.text = "\((firstName).firstUppercased) \((lastName).firstUppercased)"

        let section = (studentProfileDetails?.section ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if section.isEmpty {
            self.gradeLbl.text = "Grade: \(studentProfileDetails?.grade ?? "")"
        } else {
            self.gradeLbl.text = "Grade: \(studentProfileDetails?.grade ?? "") - \(section)"
        }
        
        self.dobLbl.text = self.studentProfileDetails?.dob ?? "-"
        self.genderLbl.text = self.studentProfileDetails?.gender ?? "-"
        self.bgLbl.text = self.studentProfileDetails?.blood_group ?? "-"
        self.religionLbl.text = self.studentProfileDetails?.religion ?? "-"
        self.casteLbl.text = self.studentProfileDetails?.caste ?? "-"
        self.rollNoLbl.text = self.studentProfileDetails?.roll_number ?? "-"
        
        if let imageStr = self.studentProfileDetails?.picture {
            self.profilePicture.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: "profile_placeholder"))
        }
        
        let imageUrl = self.studentProfileDetails?.picture ?? ""
        let fullName1 = "\((firstName).firstUppercased) \((lastName).firstUppercased)"
        
        if !imageUrl.isEmpty {
            self.placeHolderNameLbl.isHidden = true
            self.profilePicture.isHidden = false
            self.profilePicture.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
        } else {
            self.profilePicture.image = nil
            self.profilePicture.isHidden = true
            self.placeHolderNameLbl.isHidden = false
            let fullName = (fullName1).trimmingCharacters(in: .whitespacesAndNewlines)
            let words = fullName.split(separator: " ")
            let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
            let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
            self.placeHolderNameLbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
        }
        
    }
    func parentSetup(){
        
        self.fathernameLbl.text = (self.parentProfileDetails?.father_name ?? "N/A").firstUppercased
        self.mothernameLbl.text = (self.parentProfileDetails?.mother_name ?? "N/A").firstUppercased

        let fatherOccupation = (self.parentProfileDetails?.father_occupation ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let motherOccupation = (self.parentProfileDetails?.mother_occupation ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        self.fatheroccupationLbl.text = fatherOccupation.isEmpty ? "N/A" : fatherOccupation
        self.motheroccupationLbl.text = motherOccupation.isEmpty ? "N/A" : motherOccupation

        self.fatherMobileLbl.text = self.parentProfileDetails?.father_mobile ?? "N/A"
        self.motherMobileLbl.text = self.parentProfileDetails?.mother_mobile ?? "N/A"

        self.emailLbl.text = self.parentProfileDetails?.email ?? "N/A"
        self.addressLbl.text = self.parentProfileDetails?.address ?? "N/A"
        
        
        if let imageStr = self.parentProfileDetails?.picture {
            self.profilePicture.sd_setImage(
                with: URL(string: imageStr),
                placeholderImage: UIImage(named: "profile_placeholder")
            )
        }
        let imageUrl = self.parentProfileDetails?.picture ?? ""
        let fullName1 = "\(self.parentProfileDetails?.father_name ?? "")"
        
        if !imageUrl.isEmpty {
            self.placeHolderNameLbl.isHidden = true
            self.profilePicture.isHidden = false
            self.profilePicture.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
        } else {
            self.profilePicture.image = nil
            self.profilePicture.isHidden = true
            self.placeHolderNameLbl.isHidden = false
            let fullName = (fullName1).trimmingCharacters(in: .whitespacesAndNewlines)
            let words = fullName.split(separator: " ")
            let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
            let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
            self.placeHolderNameLbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
        }
        
    }
    @objc func labelAction(gesture: UITapGestureRecognizer){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "   Change Profile Photo", style: .default) { _ in
            self.choosePictureType()
        }
        cameraAction.setValue(UIImage(systemName: "camera.fill"), forKey: "image") // Add SF Symbol image
        cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

        let galleryAction = UIAlertAction(title: "   Remove Profile Photo", style: .default) { _ in
            self.removeProfilePic()
        }
        galleryAction.setValue(UIImage(systemName: "xmark.bin.fill"), forKey: "image") // Add SF Symbol image
        galleryAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

        let cancelAction = UIAlertAction(title: StringConstants.cancel, style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func choosePictureType() {
        let alert = UIAlertController(title: StringConstants.chooseImage, message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: StringConstants.camera, style: .default) { _ in
            self.openCamera()
        }
        cameraAction.setValue(UIImage(systemName: "camera"), forKey: "image") // Add SF Symbol image

        let galleryAction = UIAlertAction(title: StringConstants.gallery, style: .default) { _ in
            self.openGallery()
        }
        galleryAction.setValue(UIImage(systemName: "photo.on.rectangle"), forKey: "image") // Add SF Symbol image

        let cancelAction = UIAlertAction(title: StringConstants.cancel, style: .cancel, handler: nil)

        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
    func openCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            
            let alert  = UIAlertController(title: StringConstants.warning, message: StringConstants.youDontHaveCamera, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: StringConstants.ok, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            
            let alert  = UIAlertController(title: StringConstants.warning, message: StringConstants.youDontHavePerissionToAccessGallery, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: StringConstants.ok, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func removeProfilePic() {
        
        if selectedTab == "student"{
            
            let param = ["module":"student_profile",
                         "unique_id": defaults.value(forKey: Constants.Keys.userUniqueIdKey) ?? "",
                         "action":"delete"] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/file",params: param,HTTPMethod: .post)
            
            self.callServiceMethod(service: Constants.Urls.parentUploadFileUrl,method: .post, params: param, key: "removeProfilePicUrl", headers: headers)
        }else{
            let param = ["module":"parent_profile",
                         "unique_id": parentProfileDetails?.unique_id ?? "",
                         "action":"delete"] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/file",params: param,HTTPMethod: .post)
            
            self.callServiceMethod(service: Constants.Urls.parentUploadFileUrl,method: .post, params: param, key: "removeProfilePicUrl", headers: headers)
            
        }

    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[.editedImage] as? UIImage else {
            print("Error: \(info)")
            return
        }

        self.profilePicture.image = selectedImage
        self.selectedImage1 = selectedImage

        self.uploadProfileImage(image: selectedImage)

        self.dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
    func uploadProfileImage(image: UIImage) {

        let orderedParams: [(String, Any)]
        if selectedTab == "student"{
            
            orderedParams  = [
                ("module", "student_profile"),
                ("unique_id", defaults.value(forKey: Constants.Keys.userUniqueIdKey) ?? ""),
                ("action", "update")]
            
        }else{
            orderedParams  = [
                ("module", "parent_profile"),
                ("unique_id", parentProfileDetails?.unique_id ?? ""),
                ("action", "update")]
        }
        // Convert tuple array to dictionary for signature
        let params = Dictionary(uniqueKeysWithValues: orderedParams)

        let (headers, _) = APIHelper.createHeadersAndSignature(
            endpoint: "/file",
            params: params,
            HTTPMethod: .post
        )

        AlamofireHC.requestUploadWithImage(
            Constants.Urls.parentUploadFileUrl,
            image: image,
            orderedParams: orderedParams,
            imageParam: "file",
            headers: headers,
            method: .post,
            success: { response in

                let result = response.dictionaryObject
                let resultcheck = result?["success"] as? Bool ?? false

                if resultcheck {

                    if let responseDict = result as NSDictionary?,
                       let _ = responseDict.value(forKey: "data") as? NSDictionary {

                        if self.selectedTab == "student"{
                            self.studentprofileApi()
                        }else{
                            self.parentprofileApi()

                        }
                    }

                } else {

                    let errorCode: Int = result?["status_code"] as? Int ?? 0
                    let msg = result?["message"] as? String ?? ""

                    if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {

                        self.performLogout(Vc: self)

                    } else {

                        self.showAnimatedToast(message: msg, type: .warning)
                    }
                }

            },
            failure: { error in

                self.showAnimatedToast(
                    message: StringConstants.pleaseTryAgain,
                    type: .error
                )
            }
        )
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "studentProfileUrl"{

                        self.view.hideSkeleton()

                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            
                            self.studentProfileDetails = ParentProfileModel(dictionary: dataList)
                            
                            self.studentSetup()
                        }
                    }else if key == "parentProfileUrl" {
                        
                        self.view.hideSkeleton()

                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {

                            self.parentProfileDetails = ParentProfileModel(dictionary: dataList)

                         //   self.parentSetup()

                        }
                    }else if key == "removeProfilePicUrl" {
                        if self.selectedTab == "student"{
                            self.studentprofileApi()
                        }else{
                            self.parentprofileApi()

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
