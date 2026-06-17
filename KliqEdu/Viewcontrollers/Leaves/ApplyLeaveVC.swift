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
import DropDown

class ApplyLeaveVC: UIViewController {

    @IBOutlet weak var leaveModeView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateWarningLbl: UILabel!
    @IBOutlet weak var leaveTypeWarningLbl: UILabel!
    @IBOutlet weak var descWarningLbl: UILabel!
    @IBOutlet weak var leaveTypeView: UIView!
    @IBOutlet weak var leaveTypeLbl: UILabel!

    @IBOutlet weak var halfdayBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var toDateField: UITextField!
    @IBOutlet weak var fromDateField: UITextField!
    
    var leaveTypeArray = [LeaveTypeModel]()
    var halfDay = 0
    var fromDateData = String()
    var toDateData = String()
    var selectedLeaveTypeId = String()
    var comingFrom = ""
    var leaveDetails = LeaveModel(dictionary: [:])
    let leaveTypesDropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        reasonTextView.setPlaceholder("  Provide a brief reason for your request")
        reasonTextView.setPaddingTextView(12)
        reasonTextView.delegate = self
        fromDateField.delegate = self
        toDateField.delegate = self
        configureLeaveTypesDropDown(types: [])
        dateWarningLbl.hide()
        leaveTypeWarningLbl.hide()
        descWarningLbl.hide()
        leaveModeView.hide()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        leaveTypesApi()
        fromDateField.inputView = fromDatePicker
        fromDatePicker.addTarget(self, action: #selector(handleFromDatePicker(sender:)), for: .valueChanged)
        fromDatePicker.preferredDatePickerStyle = .inline

        
        toDateField.inputView = todatePicker
        todatePicker.addTarget(self, action: #selector(handleToDatePicker(sender:)), for: .valueChanged)
        todatePicker.preferredDatePickerStyle = .inline
        
        let fromToolbar = UIToolbar()
        fromToolbar.sizeToFit()
        let fromDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneFromDatePicker))
        fromToolbar.setItems([UIBarButtonItem.flexibleSpace(), fromDone], animated: false)
        fromDateField.inputView = fromDatePicker
        fromDateField.inputAccessoryView = fromToolbar

        let toToolbar = UIToolbar()
        toToolbar.sizeToFit()
        let toDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneToDatePicker))
        toToolbar.setItems([UIBarButtonItem.flexibleSpace(), toDone], animated: false)
        toDateField.inputView = todatePicker
        toDateField.inputAccessoryView = toToolbar
        
        if comingFrom == "edit"{
            self.titleLbl.text = "Update leave request"

            self.reasonTextView.text = leaveDetails?.reason
            self.reasonTextView.setPlaceholder("")
            self.leaveTypeLbl.text = leaveDetails?.leave_type
            self.selectedLeaveTypeId = leaveDetails?.unique_id ?? ""

            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "dd MMM yyyy"

            let apiFormatter = DateFormatter()
            apiFormatter.dateFormat = "yyyy-MM-dd"

            if let startDate = inputFormatter.date(from: leaveDetails?.start_date ?? "") {
                self.fromDateData = apiFormatter.string(from: startDate)
            }

            if let endDate = inputFormatter.date(from: leaveDetails?.end_date ?? "") {
                self.toDateData = apiFormatter.string(from: endDate)
            }

            self.fromDateField.text = ValidationClass.convertDateFormat(from: self.fromDateData)
            self.toDateField.text = ValidationClass.convertDateFormat(from: self.toDateData)

            if (leaveDetails?.is_half_day ?? 0) == 1 {
                self.halfDay = 1
                self.halfdayBtn.isSelected = true
            } else {
                self.halfDay = 0
                self.halfdayBtn.isSelected = false
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            if let fromDate = dateFormatter.date(from: self.fromDateData) {
                self.fromDatePicker.date = fromDate
            }

            if let toDate = dateFormatter.date(from: self.toDateData) {
                self.todatePicker.date = toDate
            }

       //     self.calculateLeaveDuration()
        }else{

            self.titleLbl.text = "Apply Leave"

        }
    }
    private lazy var fromDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone.current
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
        
        return datePicker
    }()
    
    @objc func handleFromDatePicker(sender: UIDatePicker) {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
        fromDateField.text = ValidationClass.convertDateFormat(from: dateFormatter.string(from: sender.date))
        fromDateData = dateFormatter.string(from: sender.date)
        dateWarningLbl.hide()
      //  calculateLeaveDuration()

     }
    
    private lazy var todatePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone.current
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
        
        return datePicker
    }()
    
    @objc func handleToDatePicker(sender: UIDatePicker) {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
        toDateField.text = ValidationClass.convertDateFormat(from: dateFormatter.string(from: sender.date))
        toDateData = dateFormatter.string(from: sender.date)
        dateWarningLbl.hide()
      //  calculateLeaveDuration()

     }
    @objc func doneToDatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let selectedDate = todatePicker.date
        toDateField.text = ValidationClass.convertDateFormat(from: dateFormatter.string(from: selectedDate))
        toDateData = dateFormatter.string(from: selectedDate)
        if !fromDateData.isEmpty && fromDateData > toDateData {
            dateWarningLbl.text = "From date should not be greater than to date"
            dateWarningLbl.unhide()
            leaveModeView.hide()
        } else {
            dateWarningLbl.hide()

            if !fromDateData.isEmpty && fromDateData == toDateData {
                leaveModeView.unhide()
            } else {
                leaveModeView.hide()
            }
        }

       // calculateLeaveDuration()

        toDateField.resignFirstResponder() // Dismiss the picker
    }
    @objc func doneFromDatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let selectedDate = fromDatePicker.date
        
        fromDateField.text = ValidationClass.convertDateFormat(from: dateFormatter.string(from: selectedDate))
        fromDateData = dateFormatter.string(from: selectedDate)
        if !toDateData.isEmpty && fromDateData > toDateData {
            dateWarningLbl.text = "From date should not be greater than to date"
            dateWarningLbl.unhide()
            leaveModeView.hide()
        } else {
            dateWarningLbl.hide()

            if !toDateData.isEmpty && fromDateData == toDateData {
                leaveModeView.unhide()
            } else {
                leaveModeView.hide()
            }
        }

      //  calculateLeaveDuration()

        fromDateField.resignFirstResponder() // Dismiss the picker
    }
    func leaveTypesApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/leave-types",params: param, HTTPMethod: .get)
        
        if roleKey == "teacher"{
            
            self.callServiceMethod(service: Constants.Urls.teacherleaveTypesUrl,method: .get, params: param, key: "leaveTypesUrl", headers: headers)
            
        }else{
            self.callServiceMethod(service: Constants.Urls.parentleaveTypesUrl,method: .get, params: param, key: "leaveTypesUrl", headers: headers)

        }

    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func leaveTypeBtnTapped(_ sender: Any) {
        leaveTypesDropDown.show()
    }
    @IBAction func halfDay(_ sender: Any) {
        self.halfdayBtn.isSelected.toggle()
        halfDay = self.halfdayBtn.isSelected ? 1 : 0
       // calculateLeaveDuration()
    }
    @IBAction func submitBtnTapped(_ sender: Any) {
     
        submitBtn?.showButtonLoading()
        if !validateFields() {
            submitBtn?.hideButtonLoading()
            return
        }

        if comingFrom == "edit"{
            if roleKey == "parent"{
                
                let param: [String: Any] = [
                    "leave_type_id": selectedLeaveTypeId,
                    "start_date": fromDateData,
                    "end_date": toDateData,
                    "reason": reasonTextView.text ?? ""
                ]
                
                let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.leaveDetails?.unique_id ?? "")",params: param, HTTPMethod: .patch)
                
                self.callServiceMethod(service: "\(Constants.Urls.parentupdateLeaveUrl)/\(self.leaveDetails?.unique_id ?? "")",method: .patch, params: param, key: "createLeaveUrl", headers: headers)
            }else{
                
                let param: [String: Any] = [
                    "leave_type_id": selectedLeaveTypeId,
                    "start_date": fromDateData,
                    "end_date": toDateData,
                    "reason": reasonTextView.text ?? ""
                ]
                
                let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.leaveDetails?.unique_id ?? "")",params: param, HTTPMethod: .patch)
                
                self.callServiceMethod(service: "\(Constants.Urls.teacherupdateLeaveUrl)/\(self.leaveDetails?.unique_id ?? "")",method: .patch, params: param, key: "createLeaveUrl", headers: headers)
            }
            
        }else{
            if roleKey == "parent"{
                let param: [String: Any] = [
                    "leave_type_id": selectedLeaveTypeId,
                    "start_date": fromDateData,
                    "end_date": toDateData,
                    "is_half_day": halfDay,
                    "reason": reasonTextView.text ?? ""
                ]
                let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/apply",params: param, HTTPMethod: .post)
                
                self.callServiceMethod(service: Constants.Urls.parentcreateLeaveUrl,method: .post, params: param, key: "createLeaveUrl", headers: headers)
            }else{
                let param: [String: Any] = [
                    "leave_type_id": selectedLeaveTypeId,
                    "start_date": fromDateData,
                    "end_date": toDateData,
                    "is_half_day": halfDay,
                    "reason": reasonTextView.text ?? ""
                ]
                let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/apply",params: param, HTTPMethod: .post)
                
                self.callServiceMethod(service: Constants.Urls.teachercreateLeaveUrl,method: .post, params: param, key: "createLeaveUrl", headers: headers)
            }
        }
    }
    func validateFields() -> Bool {
        var isValid = true

        dateWarningLbl.hide()
        leaveTypeWarningLbl.hide()
        descWarningLbl.hide()

        if fromDateData.isEmpty || toDateData.isEmpty {
            dateWarningLbl.text = "Please select from and to date"
            dateWarningLbl.unhide()
            isValid = false
        }

        if fromDateData > toDateData {
            dateWarningLbl.text = "From date should not be greater than to date"
            dateWarningLbl.unhide()
            isValid = false
        }

        if selectedLeaveTypeId.isEmpty {
            leaveTypeWarningLbl.text = "Please select leave type"
            leaveTypeWarningLbl.unhide()
            isValid = false
        }

        let trimmedReason = (reasonTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedReason.isEmpty || reasonTextView.text == "  Provide a brief reason for your request" {
            descWarningLbl.text = "Please enter reason"
            descWarningLbl.unhide()
            isValid = false
        } else if trimmedReason.count < 5 {
            descWarningLbl.text = "Reason should be minimum 5 characters"
            descWarningLbl.unhide()
            isValid = false
        }

        return isValid
    }
    
    func configureLeaveTypesDropDown(types: [[String: Any]]) {
        
        leaveTypesDropDown.anchorView = leaveTypeView
        leaveTypesDropDown.bottomOffset = CGPoint(x: 0, y: leaveTypeView.bounds.height)
        leaveTypesDropDown.direction = .any
        leaveTypesDropDown.backgroundColor = .white
        leaveTypesDropDown.cellHeight = 48
        leaveTypesDropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.FontMedium, size: 15)!
        leaveTypesDropDown.selectionBackgroundColor = .themeLite1
        leaveTypesDropDown.separatorColor = UIColor.systemGray5
        
        // Extract labels for dropdown
        let dropdownValues = types.map {
            $0["name"] as? String ?? "-"
        }
        
        leaveTypesDropDown.dataSource = dropdownValues
        leaveTypesDropDown.reloadAllComponents()
        
        leaveTypesDropDown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            
            let selectedGradeData = types[index]
            let label = selectedGradeData["name"] as? String ?? "-"
            let value = selectedGradeData["unique_id"] as? String ?? ""
            
            self.leaveTypeLbl.text = label
            self.leaveTypeWarningLbl.hide()
            self.selectedLeaveTypeId = value
            print("Selected grade:", label, value)
        }
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
                                                
                        let listArray = resDataDic?["leave_types"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        self.leaveTypeArray.removeAll()
                        for item in listArray {
                            if let model = LeaveTypeModel(dictionary: item as NSDictionary) {
                                self.leaveTypeArray.append(model)
                            }
                        }
                        let leaveTypesDictArray = self.leaveTypeArray.map {
                            [
                                "name": $0.name ?? "",
                                "unique_id": $0.unique_id ?? ""
                            ]
                        }

                        self.configureLeaveTypesDropDown(types: leaveTypesDictArray)

                        if self.comingFrom == "edit" {
                            if let leaveTypeName = self.leaveDetails?.leave_type {
                                if let matchedLeaveType = self.leaveTypeArray.first(where: { ($0.name ?? "") == leaveTypeName }) {
                                    self.selectedLeaveTypeId = matchedLeaveType.unique_id ?? ""
                                    self.leaveTypeLbl.text = matchedLeaveType.name
                                }
                            }
                        }
                    }else if key == "createLeaveUrl"{
                        
                        self.submitBtn?.hideButtonLoading()

                            DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                self.submitBtn?.hideButtonLoading()

                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                
               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }

            }
        }) { (error) in
            self.submitBtn?.hideButtonLoading()

            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            debugPrint(error)
        }
    }
   
}
extension ApplyLeaveVC: UITextViewDelegate, UITextFieldDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == reasonTextView {
            descWarningLbl.hide()

            if textView.text == "  Provide a brief reason for your request" {
                textView.text = ""
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView == reasonTextView {
            let trimmedText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmedText.isEmpty {
                descWarningLbl.text = "Please enter reason"
                descWarningLbl.unhide()
            } else if trimmedText.count < 5 {
                descWarningLbl.text = "Reason should be minimum 5 characters"
                descWarningLbl.unhide()
            } else {
                descWarningLbl.hide()
            }
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == reasonTextView {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return true }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            return updatedText.count <= 500
        }
        return true
    }
}
