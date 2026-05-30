//
//  EditParentProfileVc.swift
//  KliqEdu
//
//  Created by codegama on 13/05/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class EditParentProfileVc: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var fatherNameWarningLbl: UILabel!
    @IBOutlet weak var motherNameWarningLbl: UILabel!
    @IBOutlet weak var fatherMobileWarningLbl: UILabel!
    @IBOutlet weak var motherMobileWarningLbl: UILabel!
    @IBOutlet weak var fatherOccupationWarningLbl: UILabel!
    @IBOutlet weak var motherOccupationWarningLbl: UILabel!
    @IBOutlet weak var addressWarningLbl: UILabel!

    @IBOutlet weak var fatherNameField: UITextField!
    @IBOutlet weak var motherNameField: UITextField!
    @IBOutlet weak var fatherMobileField: UITextField!
    @IBOutlet weak var motherMobileField: UITextField!
    @IBOutlet weak var fatherOccupationField: UITextField!
    @IBOutlet weak var motherOccupationField: UITextField!
    @IBOutlet weak var addressField: UITextField!

    @IBOutlet weak var submitBtn: UIButton!
    
    let maxLengths: [Int: Int] = [
        1: 30,   // First Name
        2: 30,   // Last Name
        3: 30,   // Dob
        4: 30,   // Relion
        5: 30,   // Caste
        6: 30,   // Caste
        7: 250   // Caste

    ]
    
    var profileDetails: ProfileModel?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fatherNameWarningLbl.hide()
        self.motherNameWarningLbl.hide()
        self.fatherMobileWarningLbl.hide()
        self.motherMobileWarningLbl.hide()
        self.fatherOccupationWarningLbl.hide()
        self.motherOccupationWarningLbl.hide()
        self.addressWarningLbl.hide()

        self.fatherNameField.setLeftPaddingPoints(12)
        self.motherNameField.setLeftPaddingPoints(12)
        self.fatherMobileField.setLeftPaddingPoints(12)
        self.motherMobileField.setLeftPaddingPoints(12)
        self.fatherOccupationField.setLeftPaddingPoints(12)
        self.motherOccupationField.setLeftPaddingPoints(12)
        self.addressField.setLeftPaddingPoints(12)

        setupTextFieldDelegates()

    }
    func setupTextFieldDelegates() {

        fatherNameField.delegate = self
        motherNameField.delegate = self
        fatherMobileField.delegate = self
        motherMobileField.delegate = self
        fatherOccupationField.delegate = self
        motherOccupationField.delegate = self
        addressField.delegate = self

        fatherNameField.tag = 1
        motherNameField.tag = 2
        fatherMobileField.tag = 3
        motherMobileField.tag = 4
        fatherOccupationField.tag = 5
        motherOccupationField.tag = 6
        addressField.tag = 7

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoadingIndicator.show()

        profileApi()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    func profileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/parent-profile",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.parentProfileUrl,method: .get, params: param, key: "profileUrl", headers: headers)
    }
    @IBAction func submitBtnTapped(_ sender: Any) {

        var isValid = true

        if let error = ValidationClass.validateName(Field: fatherNameField.text ?? "", minValue: 2, maxValue: 30, fieldName: "Father name") {
            fatherNameWarningLbl.text = error
            fatherNameWarningLbl.unhide()
            isValid = false
        } else {
            fatherNameWarningLbl.hide()
        }

        if let error = ValidationClass.validateName(Field: motherNameField.text ?? "", minValue: 2, maxValue: 30, fieldName: "Mother name") {
            motherNameWarningLbl.text = error
            motherNameWarningLbl.unhide()
            isValid = false
        } else {
            motherNameWarningLbl.hide()
        }

        if let error = ValidationClass.validateMobileNumber(fatherMobileField.text ?? "") {
            fatherMobileWarningLbl.text = error
            fatherMobileWarningLbl.unhide()
            isValid = false
        } else {
            fatherMobileWarningLbl.hide()
        }

        if let error = ValidationClass.validateMobileNumber(motherMobileField.text ?? "") {
            motherMobileWarningLbl.text = error
            motherMobileWarningLbl.unhide()
            isValid = false
        } else {
            motherMobileWarningLbl.hide()
        }

        if let error = ValidationClass.validateName(Field: fatherOccupationField.text ?? "", minValue: 2, maxValue: 30, fieldName: "Father occupation") {
            fatherOccupationWarningLbl.text = error
            fatherOccupationWarningLbl.unhide()
            isValid = false
        } else {
            fatherOccupationWarningLbl.hide()
        }

        if let error = ValidationClass.validateName(Field: motherOccupationField.text ?? "", minValue: 2, maxValue: 30, fieldName: "Mother occupation") {
            motherOccupationWarningLbl.text = error
            motherOccupationWarningLbl.unhide()
            isValid = false
        } else {
            motherOccupationWarningLbl.hide()
        }

        if let error = ValidationClass.validateAddress(addressField.text ?? "") {
            addressWarningLbl.text = error
            addressWarningLbl.unhide()
            isValid = false
        } else {
            addressWarningLbl.hide()
        }

        if isValid {
            self.submitBtn.showButtonLoading()
            updateAddress()
        }
    }
    func updateAddress() {

        let param: [String: Any] = [
            "father_name": fatherNameField.text ?? "",
            "mother_name": motherNameField.text ?? "",
            "father_mobile": fatherMobileField.text ?? "",
            "mother_mobile": motherMobileField.text ?? "",
            "father_occupation": fatherOccupationField.text ?? "",
            "mother_occupation": motherOccupationField.text ?? "",
            "address": addressField.text ?? ""
        ]

        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/parent-profile",params: param,HTTPMethod: .patch)

        self.callServiceMethod(service: Constants.Urls.parentProfileUrl,method: .patch, params: param, key: "updateprofileUrl", headers: headers)
    }
    //sets up the UI
    func setupUI () {

        fatherNameField.text = profileDetails?.father_name ?? ""
        motherNameField.text = profileDetails?.mother_name ?? ""
        fatherMobileField.text = profileDetails?.father_mobile ?? ""
        motherMobileField.text = profileDetails?.mother_mobile ?? ""
        fatherOccupationField.text = profileDetails?.father_occupation ?? ""
        motherOccupationField.text = profileDetails?.mother_occupation ?? ""
        addressField.text = profileDetails?.address ?? ""
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "profileUrl"{

                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            LoadingIndicator.hide()

                            self.profileDetails = ProfileModel(dictionary: dataList)
                            
                            DispatchQueue.main.async {
                                self.setupUI()
                            }
                        }
                    }else if key == "updateprofileUrl"{
                        
                        self.navigationController?.popViewController(animated: true)
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

extension EditParentProfileVc {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        let maxLength = maxLengths[textField.tag] ?? Int.max

        switch textField {

        case fatherNameField:
            if let error = ValidationClass.validateName(Field: updatedText, minValue: 2, maxValue: 30, fieldName: "Father name") {
                fatherNameWarningLbl.text = error
                fatherNameWarningLbl.unhide()
            } else {
                fatherNameWarningLbl.hide()
            }

        case motherNameField:
            if let error = ValidationClass.validateName(Field: updatedText, minValue: 2, maxValue: 30, fieldName: "Mother name") {
                motherNameWarningLbl.text = error
                motherNameWarningLbl.unhide()
            } else {
                motherNameWarningLbl.hide()
            }

        case fatherMobileField:
            if let error = ValidationClass.validateMobileNumber(updatedText) {
                fatherMobileWarningLbl.text = error
                fatherMobileWarningLbl.unhide()
            } else {
                fatherMobileWarningLbl.hide()
            }

        case motherMobileField:
            if let error = ValidationClass.validateMobileNumber(updatedText) {
                motherMobileWarningLbl.text = error
                motherMobileWarningLbl.unhide()
            } else {
                motherMobileWarningLbl.hide()
            }

        case fatherOccupationField:
            if let error = ValidationClass.validateName(Field: updatedText, minValue: 2, maxValue: 30, fieldName: "Father occupation") {
                fatherOccupationWarningLbl.text = error
                fatherOccupationWarningLbl.unhide()
            } else {
                fatherOccupationWarningLbl.hide()
            }

        case motherOccupationField:
            if let error = ValidationClass.validateName(Field: updatedText, minValue: 2, maxValue: 30, fieldName: "Mother occupation") {
                motherOccupationWarningLbl.text = error
                motherOccupationWarningLbl.unhide()
            } else {
                motherOccupationWarningLbl.hide()
            }

        case addressField:
            if let error = ValidationClass.validateAddress(updatedText) {
                addressWarningLbl.text = error
                addressWarningLbl.unhide()
            } else {
                addressWarningLbl.hide()
            }

        default:
            break
        }

        return updatedText.count <= maxLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        switch textField {

        case fatherNameField:
            fatherNameField.resignFirstResponder()
            motherNameField.becomeFirstResponder()

        case motherNameField:
            motherNameField.resignFirstResponder()
            fatherMobileField.becomeFirstResponder()

        case fatherMobileField:
            fatherMobileField.resignFirstResponder()
            motherMobileField.becomeFirstResponder()

        case motherMobileField:
            motherMobileField.resignFirstResponder()
            fatherOccupationField.becomeFirstResponder()

        case fatherOccupationField:
            fatherOccupationField.resignFirstResponder()
            motherOccupationField.becomeFirstResponder()

        case motherOccupationField:
            motherOccupationField.resignFirstResponder()
            addressField.becomeFirstResponder()

        case addressField:
            addressField.resignFirstResponder()

        default:
            textField.resignFirstResponder()
        }

        return true
    }
}
