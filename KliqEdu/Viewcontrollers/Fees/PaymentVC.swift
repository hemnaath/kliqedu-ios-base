//
//  PaymentVC.swift
//  KliqEdu
//
//  Created by codegama on 21/05/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class PaymentVC: UIViewController {
    @IBOutlet weak var qrCodeOuterView: UIView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var paymentPicture: UIImageView!
    @IBOutlet weak var imageClearBtn: UIButton!
    @IBOutlet weak var selectPictureTextLbl: UILabel!
    
    var feeDetails = FeesModel(dictionary: [:])

    var selectedImage1 = UIImage()
    var isFileAdded = Bool()
    var decryptedupiUrl1 = String()
    
    var comingFrom = String()
    
    override func viewDidLoad() {
        
        self.imageClearBtn.isHidden = true
        self.qrCodeOuterView.isHidden = true
        self.amountLbl.text = "\(self.feeDetails?.remaining_amount ?? "")"

        upiUrlApi()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    func upiUrlApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(feeDetails?.unique_id ?? "")",params: param, HTTPMethod: .get)
      
        self.callServiceMethod(service: "\(Constants.Urls.upiIntentUrl)/\(feeDetails?.unique_id ?? "")",method: .get, params: param, key: "upiIntentUrl", headers: headers)
    }
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let outputImage = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledImage = outputImage.transformed(by: transform)

                let qrImage = UIImage(ciImage: scaledImage)

                return addLogoToQRCode(qrImage)
            }
        }
        
        return nil
    }
    func addLogoToQRCode(_ qrImage: UIImage) -> UIImage? {

        guard let logo = UIImage(named: "kliqedu logo") else {
            return qrImage
        }

        let size = qrImage.size

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        qrImage.draw(in: CGRect(origin: .zero, size: size))

        let logoSize = size.width * 0.22

        let logoRect = CGRect(
            x: (size.width - logoSize) / 2,
            y: (size.height - logoSize) / 2,
            width: logoSize,
            height: logoSize
        )

        let bgRect = logoRect.insetBy(dx: -8, dy: -8)

        let bgPath = UIBezierPath(
            roundedRect: bgRect,
            cornerRadius: 15
        )

        UIColor.white.setFill()
        bgPath.fill()

        logo.draw(in: logoRect)

        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func qrCloseTapped(_ sender: Any) {
        self.qrCodeOuterView.isHidden = true

    }
    @IBAction func upiBtnTapped(_ sender: Any) {
       
        self.showUPIChooser(backendUPIURL: decryptedupiUrl1)

    }
    
    @IBAction func scanPayBtnTapped(_ sender: Any) {
        self.qrCodeOuterView.isHidden = false
        
    }
    @IBAction func submitBtnTapped(_ sender: Any) {
        if isFileAdded == true{
            submitBtn?.showButtonLoading()
            
            self.uploadProfileImage(image: self.selectedImage1)
        }else{
            showAnimatedToast(message: "Please upload a payment screenshot",type: .warning)
        }
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "upiIntentUrl"{
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {

                            let upiUrl = dataList.value(forKey: "upi_url") as? String ?? ""
                            
                            if let decryptedupiUrl = APIHelper.decryptSaltKey(
                                encryptedSaltKey: upiUrl,
                                encryptionKey: Constants.encryptionKey
                            ) {
                                
                                print("upi_url intent:", decryptedupiUrl)
                                
                                self.decryptedupiUrl1 = decryptedupiUrl
                                if let qrImage = self.generateQRCode(from: decryptedupiUrl) {
                                    print("QR Code Generated:", qrImage)
                                    
                                    self.qrImage.image = qrImage
                                    
                                }
                            }
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
    @IBAction func uploadPaymentPicture(_ sender: Any) {
        let alert = UIAlertController(title: StringConstants.chooseImage, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: StringConstants.camera, style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: StringConstants.gallery, style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: StringConstants.cancel, style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            //            alert.popoverPresentationController?.sourceView = self.backView
            //            alert.popoverPresentationController?.sourceRect = self.backView.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
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
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            print("Error: \(info)")
            return
        }
        self.paymentPicture.image = selectedImage
        self.selectPictureTextLbl.text = "File uploaded"
        self.imageClearBtn.isHidden = false
        
        self.selectedImage1 = selectedImage
        isFileAdded = true
        
        self.dismiss(animated: true, completion: nil)
        
        self.view.endEditing(true)
    }
    @IBAction func uploadedImageClearBtnTapped(_ sender: Any) {
        self.selectPictureTextLbl.text = "Select a picture"
        self.paymentPicture.image = UIImage(named: "photo")
        self.imageClearBtn.isHidden = true
        isFileAdded = false
        
    }
    func uploadProfileImage(image: UIImage) {

        let orderedParams: [(String, Any)]
        if feeDetails?.status == "Failed" {
            orderedParams = [
                ("module", "fees"),
                ("unique_id", feeDetails?.unique_id ?? ""),
                ("action", "update")]
        }else{
            orderedParams = [
                ("module", "fees"),
                ("unique_id", feeDetails?.unique_id ?? ""),
                ("action", "add")]
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
                self.submitBtn.hideButtonLoading()

                if resultcheck {

                    if let responseDict = result as NSDictionary?,
                       let _ = responseDict.value(forKey: "data") as? NSDictionary {

                        self.navigationController?.popViewController(animated: true)
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
                self.submitBtn.hideButtonLoading()

                self.showAnimatedToast(
                    message: StringConstants.pleaseTryAgain,
                    type: .error
                )
            }
        )
    }
    func showUPIChooser(backendUPIURL: String) {

        let apps = UPIManager.shared.installedUPIApps()

        guard !apps.isEmpty else {
            self.showAnimatedToast(message: "No UPI apps found on this device")
            return
        }

        let alert = UIAlertController(
            title: "Pay Using",
            message: nil,
            preferredStyle: .actionSheet
        )

        for app in apps {
            alert.addAction(UIAlertAction(title: app.name, style: .default) { _ in
                UPIManager.shared.openUPI(
                    app: app,
                    backendUPIURL: backendUPIURL
                )
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
}
