//
//  ProfileVC.swift
//  KliqEdu
//
//  Created by codegama on 27/03/26.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON

class ProfileVC: UIViewController {

    @IBOutlet weak var placeHolderNameLbl: UILabel!
    @IBOutlet weak var empIdLbl: UILabel!
    @IBOutlet weak var deptLbl: UILabel!
    @IBOutlet weak var joinedDateLbl: UILabel!
    @IBOutlet weak var totalExpLbl: UILabel!
    @IBOutlet weak var qualificationLbl: UILabel!
    
    @IBOutlet weak var dobLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var bgLbl: UILabel!
    @IBOutlet weak var religionLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var emgNumLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var fatherNameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    
    @IBOutlet weak var positionLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!

    @IBOutlet weak var personalView: UIView!
    @IBOutlet weak var empView: UIView!
    @IBOutlet weak var empDetailsBtn: UIButton!
    @IBOutlet weak var personalDetailsBtn: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileContainerView: UIView!
    
    var profileDetails: ProfileModel?
    var selectedImage1 = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        self.positionLbl.layer.cornerRadius = 17.5
        self.positionLbl.layer.masksToBounds = true
        self.placeHolderNameLbl.layer.cornerRadius = 25
        self.placeHolderNameLbl.layer.masksToBounds = true
        
        empDetailsBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        personalDetailsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.personalView.isHidden = true
        self.empView.isHidden = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(labelAction(gesture:)))
        profileContainerView.isUserInteractionEnabled = true
        profileContainerView.addGestureRecognizer(tap)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startViewAnimation()
        profileApi()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func empDetailsBtnTapped(_ sender: Any) {
        empDetailsBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        personalDetailsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        self.personalView.isHidden = true
        self.empView.isHidden = false
    }
    @IBAction func personalDetailsBtnTapped(_ sender: Any) {
        empDetailsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        personalDetailsBtn.setTitleAndBgColor(titleColor: .theme, bgColor: .white)
        self.personalView.isHidden = false
        self.empView.isHidden = true
    }
    func startViewAnimation()  {
        profilePicture.showSkeleton(cornerRadius: 25)
        placeHolderNameLbl.showSkeleton(cornerRadius: 25)
        empIdLbl.showSkeleton(cornerRadius: 0)
       // nameLbl.showSkeleton(cornerRadius: 0)
        deptLbl.showSkeleton(cornerRadius: 0)
        joinedDateLbl.showSkeleton(cornerRadius: 0)
        totalExpLbl.showSkeleton(cornerRadius: 0)
        qualificationLbl.showSkeleton(cornerRadius: 0)

    }
    func stopViewAnimation()  {
        profilePicture.hideSkeleton()
        placeHolderNameLbl.hideSkeleton()
       // nameLbl.hideSkeleton()
        empIdLbl.hideSkeleton()
        deptLbl.hideSkeleton()
        joinedDateLbl.hideSkeleton()
        totalExpLbl.hideSkeleton()
        qualificationLbl.hideSkeleton()

    }

    func profileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/profile",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.profileUrl,method: .get, params: param, key: "profileUrl", headers: headers)
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
        let param = ["module":"teacher_profile",
                     "unique_id": profileDetails?.unique_id ?? "",
                     "action":"delete"] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/file",params: param,HTTPMethod: .post)

        self.callServiceMethod(service: Constants.Urls.teacherUploadFileUrl,method: .post, params: param, key: "removeProfilePicUrl", headers: headers)

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

        let orderedParams: [(String, Any)] = [
            ("module", "teacher_profile"),
            ("unique_id", profileDetails?.unique_id ?? ""),
            ("action", "update")]

        // Convert tuple array to dictionary for signature
        let params = Dictionary(uniqueKeysWithValues: orderedParams)

        let (headers, _) = APIHelper.createHeadersAndSignature(
            endpoint: "/file",
            params: params,
            HTTPMethod: .post
        )

        AlamofireHC.requestUploadWithImage(
            Constants.Urls.teacherUploadFileUrl,
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

                        self.profileApi()
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
                    
                    if key == "profileUrl"{
                        self.stopViewAnimation()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            
                            self.profileDetails = ProfileModel(dictionary: dataList)
                            
                            let firstName = self.profileDetails?.firstname ?? ""
                            let lastName = self.profileDetails?.lastname ?? ""
                            
                            self.nameLbl.text = "\((firstName).firstUppercased) \((lastName).firstUppercased)"
                            self.positionLbl.text = self.profileDetails?.position
                            
                            self.qualificationLbl.text = self.profileDetails?.qualification ?? "-"
                            self.joinedDateLbl.text = self.profileDetails?.join_date ?? "-"
                            self.deptLbl.text = self.profileDetails?.department ?? "-"
                            self.empIdLbl.text = self.profileDetails?.unique_id ?? "-"

                            self.totalExpLbl.text = "\(self.profileDetails?.total_experience ?? "") Years"
                            
                            self.dobLbl.text = self.profileDetails?.dob ?? "-"
                            self.genderLbl.text = self.profileDetails?.gender ?? "-"
                            self.bgLbl.text = self.profileDetails?.blood_group ?? "-"
                            self.religionLbl.text = self.profileDetails?.religion ?? "-"
                            self.mobileLbl.text = self.profileDetails?.mobile ?? "-"
                            self.emgNumLbl.text = self.profileDetails?.emergency_contact ?? "-"
                            self.emailLbl.text = self.profileDetails?.email ?? "-"
                            self.fatherNameLbl.text = (self.profileDetails?.father_name ?? "-")?.firstUppercased
                            self.addressLbl.text = self.profileDetails?.address ?? "-"
                            
                            if let imageStr = self.profileDetails?.picture {
                                self.profilePicture.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: "profile_placeholder"))
                            }
                            let imageUrl = self.profileDetails?.picture ?? ""
                            let fullName1 = "\(firstName) \(lastName)"

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
                    }else if key == "removeProfilePicUrl"{
                        
                        self.profileApi()
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
