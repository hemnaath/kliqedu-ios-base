//
//  EditStudentProfileVC.swift
//  KliqEdu
//
//  Created by codegama on 01/05/26.
//

import UIKit
import DropDown
import Alamofire
import SwiftyJSON
import SkeletonView

class EditStudentProfileVC: UIViewController ,UITextFieldDelegate{

    @IBOutlet weak var firstNameWarningLbl: UILabel!
    @IBOutlet weak var lastNameWarningLbl: UILabel!
    @IBOutlet weak var dobWarningLbl: UILabel!
    @IBOutlet weak var genderWarningLbl: UILabel!
    @IBOutlet weak var bgWarningLbl: UILabel!
    @IBOutlet weak var religionWarningLbl: UILabel!
    @IBOutlet weak var casteWarningLbl: UILabel!
   
    @IBOutlet weak var genderOuterView: UIView!
    @IBOutlet weak var bgOuterView: UIView!
    @IBOutlet weak var bgBtn: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var religionField: UITextField!
    @IBOutlet weak var casteField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    
    var selectedGender = String()
    var selectedBg = String()
    let maxLengths: [Int: Int] = [
        1: 30,   // First Name
        2: 30,   // Last Name
        3: 20,   // Dob
        4: 30,   // Relion
        5: 30   // Caste
       

    ]
    
    let bgdropDown = DropDown()
    let genderdropDown = DropDown()
    var profileDetails: ProfileModel?
    override func viewDidLoad() {
        super.viewDidLoad()
      //  LoadingIndicator.show()

        self.firstNameWarningLbl.hide()
        self.lastNameWarningLbl.hide()
        self.dobWarningLbl.hide()
        self.genderWarningLbl.hide()
        self.bgWarningLbl.hide()
        self.religionWarningLbl.hide()
        self.casteWarningLbl.hide()
       
        self.firstNameField.setLeftPaddingPoints(12)
        self.lastNameField.setLeftPaddingPoints(12)
        self.dobField.setLeftPaddingPoints(12)
        self.religionField.setLeftPaddingPoints(12)
        self.casteField.setLeftPaddingPoints(12)
       
        setupTextFieldDelegates()
        bgdropDown.anchorView = bgOuterView // UIView or UIBarButtonItem
        // The list of items to display. Can be changed dynamically
        bgdropDown.dataSource = [
            "A+",
            "A-",
            "B+",
            "B-",
            "AB+",
            "AB-",
            "O+",
            "O-"
        ]
        bgdropDown.bottomOffset = CGPoint(x: 0, y: bgOuterView.bounds.height)
        // dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        bgdropDown.direction = .bottom
        
        bgdropDown.backgroundColor = .white
        bgdropDown.layer.cornerRadius = 12
        bgdropDown.cellHeight = 48
        bgdropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.FontMedium, size: 15)!
        bgdropDown.selectionBackgroundColor = .themeLite1
        bgdropDown.separatorColor = UIColor.systemGray5
        
        // Action triggered on selection
        bgdropDown.selectionAction = { [weak self] (index, item) in
            self?.bgBtn.setTitle("   \(item)", for: .normal)
            self?.selectedBg = item
            self?.bgWarningLbl.hide()
        }
        
        genderdropDown.anchorView = genderOuterView // UIView or UIBarButtonItem
        // The list of items to display. Can be changed dynamically
        genderdropDown.dataSource = [
            "Male",
            "Female",
            "Others"
        ]
        genderdropDown.bottomOffset = CGPoint(x: 0, y: genderOuterView.bounds.height)
        // dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        genderdropDown.direction = .bottom
        
        genderdropDown.backgroundColor = .white
        genderdropDown.layer.cornerRadius = 12
        genderdropDown.cellHeight = 48
        genderdropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.FontMedium, size: 15)!
        genderdropDown.selectionBackgroundColor = .themeLite1
        genderdropDown.separatorColor = UIColor.systemGray5
        
        // Action triggered on selection
        genderdropDown.selectionAction = { [weak self] (index, item) in
            self?.genderBtn.setTitle("   \(item)", for: .normal)
            switch item {
            case "Male":
                self?.selectedGender = "1"
            case "Female":
                self?.selectedGender = "2"
            default:
                self?.selectedGender = "3"
            }
            self?.genderWarningLbl.hide()
        }
        
        dobField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        
        let fromToolbar = UIToolbar()
        fromToolbar.sizeToFit()
        let fromDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDobDatePicker))
        fromToolbar.setItems([UIBarButtonItem.flexibleSpace(), fromDone], animated: false)
        dobField.inputView = datePicker
        dobField.inputAccessoryView = fromToolbar
        
        // Calculate the date 18 years back from today
        let calendar = Calendar.current
        let currentDate = Date()
        if let date18YearsAgo = calendar.date(byAdding: .year, value: -18, to: currentDate) {
            // Set the default date to the date picker
            datePicker.setDate(date18YearsAgo, animated: false)
            datePicker.maximumDate = date18YearsAgo
        }
        
    }
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone.current
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
        datePicker.maximumDate = Date()
        
        return datePicker
    }()
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dobField.text = dateFormatter.string(from: sender.date)
        self.dobWarningLbl.hide()
    }
    @objc func doneDobDatePicker() {
        self.dobWarningLbl.hide()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"

        let selectedDate = datePicker.date
        dobField.text = dateFormatter.string(from: selectedDate)

        dobField.resignFirstResponder() // Dismiss the picker
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    func setupTextFieldDelegates() {

        firstNameField.delegate = self
        lastNameField.delegate = self
        religionField.delegate = self
        dobField.delegate = self
        casteField.delegate = self

        firstNameField.tag = 1
        lastNameField.tag = 2
        dobField.tag = 3
        religionField.tag = 4
        casteField.tag = 5
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     //   LoadingIndicator.show()
        self.view.showAnimatedSkeleton()
        profileApi()
    }

    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func bgBtnAction(_ sender: Any) {
        bgdropDown.show()
    }
    @IBAction func genderBtnAction(_ sender: Any) {
        genderdropDown.show()

    }
    func profileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/student-profile",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.studentProfileUrl,method: .get, params: param, key: "profileUrl", headers: headers)
    }
    @IBAction func submitBtnTapped(_ sender: Any) {
        var isValid = true
        
        if selectedBg == "" {
            bgWarningLbl.unhide()
            isValid = false
        } else {
            bgWarningLbl.hide()
        }
        
        if selectedGender == "" {
            genderWarningLbl.unhide()
            isValid = false
        } else {
            genderWarningLbl.hide()
        }
        
        if let error = ValidationClass.validateName(Field: firstNameField.text ?? "", minValue: 2 , maxValue: 25, fieldName: "First name") {
            firstNameWarningLbl.text = error
            firstNameWarningLbl.unhide()
            isValid = false
        } else {
            firstNameWarningLbl.hide()
        }
        
        if let error = ValidationClass.validateName(Field: lastNameField.text ?? "", minValue: 1 , maxValue: 25, fieldName: "Last name") {
            lastNameWarningLbl.unhide()
            lastNameWarningLbl.text = error
            isValid = false
        } else {
            lastNameWarningLbl.hide()
        }
        
        if dobField.text ?? "" == ""{
            isValid = false
            
            self.dobWarningLbl.unhide()
            self.dobWarningLbl.text = StringConstants.selectDob
        }else{
            self.dobWarningLbl.hide()
        }
        
        if let error = ValidationClass.validateReligion(religionField.text ?? "") {
            religionWarningLbl.text = error
            religionWarningLbl.unhide()
            isValid = false
        } else {
            religionWarningLbl.hide()
        }
        
        
        if let error = ValidationClass.validateCaste(religionField.text ?? "") {
            casteWarningLbl.text = error
            casteWarningLbl.unhide()
            isValid = false
        } else {
            casteWarningLbl.hide()
        }
        
        if isValid {
         
                self.submitBtn?.showButtonLoading()
                
                updateAddress()
            }
        }
    func updateAddress() {
        let displayDate = dobField.text ?? ""
        let apiDob = ValidationClass.convertDateFormatToAPIDate(displayDate)
        let param: [String: Any] = [
            "firstname": firstNameField.text ?? "",
            "lastname": lastNameField.text ?? "",
            "blood_group": selectedBg,
            "gender": selectedGender,
            "dob": apiDob,
            "religion": religionField.text ?? "",
            "caste": casteField.text ?? ""
        ]
                
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/student-profile",params: param,HTTPMethod: .patch)
        
        self.callServiceMethod(service: Constants.Urls.studentProfileUrl,method: .patch, params: param, key: "updateprofileUrl", headers: headers)
        
    }
    //sets up the UI
    func setupUI () {
        
        firstNameField.text = profileDetails?.firstname ?? ""
        lastNameField.text = profileDetails?.lastname ?? ""
        dobField.text = profileDetails?.dob ?? ""
        religionField.text = profileDetails?.religion ?? ""
        casteField.text = profileDetails?.caste ?? ""

        selectedBg = profileDetails?.blood_group ?? ""
        bgBtn.setTitle(selectedBg.isEmpty ? "Select Blood Group" : "   \(selectedBg)", for: .normal)

        let gender = profileDetails?.gender ?? ""

        switch gender.lowercased() {
        case "male", "1":
            selectedGender = "1"
            genderBtn.setTitle("   Male", for: .normal)

        case "female", "2":
            selectedGender = "2"
            genderBtn.setTitle("   Female", for: .normal)

        default:
            selectedGender = "3"
            genderBtn.setTitle("   Others", for: .normal)
        }
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
                          //  LoadingIndicator.hide()
                            self.view.hideSkeleton()
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

extension EditStudentProfileVC {

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

        case firstNameField:
            if let error = ValidationClass.validateName(Field: updatedText, minValue: 2, maxValue: 25, fieldName: "First name") {
                firstNameWarningLbl.text = error
                firstNameWarningLbl.unhide()
            } else {
                firstNameWarningLbl.hide()
            }

        case lastNameField:
            if let error = ValidationClass.validateName(Field: updatedText, minValue: 1, maxValue: 25, fieldName: "Last name") {
                lastNameWarningLbl.text = error
                lastNameWarningLbl.unhide()
            } else {
                lastNameWarningLbl.hide()
            }

        case religionField:
            if let error = ValidationClass.validateReligion(updatedText) {
                religionWarningLbl.text = error
                religionWarningLbl.unhide()
            } else {
                religionWarningLbl.hide()
            }
            
        case casteField:
            if let error = ValidationClass.validateCaste(updatedText) {
                casteWarningLbl.text = error
                casteWarningLbl.unhide()
            } else {
                casteWarningLbl.hide()
            }

        default:
            break
        }

        return updatedText.count <= maxLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        switch textField {

        case firstNameField:

            if let error = ValidationClass.validateName(Field: firstNameField.text ?? "", minValue: 2, maxValue: 25, fieldName: "First name") {
                firstNameWarningLbl.text = error
                firstNameWarningLbl.unhide()
                return false
            }

            firstNameWarningLbl.hide()
            lastNameField.becomeFirstResponder()

        case lastNameField:

            if let error = ValidationClass.validateName(Field: lastNameField.text ?? "", minValue: 1, maxValue: 25, fieldName: "Last name") {
                lastNameWarningLbl.text = error
                lastNameWarningLbl.unhide()
                return false
            }

            lastNameWarningLbl.hide()
            religionField.becomeFirstResponder()

        case religionField:

            if let error = ValidationClass.validateReligion(religionField.text ?? "") {
                religionWarningLbl.text = error
                religionWarningLbl.unhide()
                return false
            }

            religionWarningLbl.hide()
            casteField.becomeFirstResponder()

        case casteField:

            casteField.resignFirstResponder()

        default:
            textField.resignFirstResponder()
        }

        return true
    }
}
