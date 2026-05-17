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

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateWarningLbl: UILabel!
    @IBOutlet weak var leaveModeWarningLbl: UILabel!
    @IBOutlet weak var leaveTypeWarningLbl: UILabel!
    @IBOutlet weak var descWarningLbl: UILabel!
    
    @IBOutlet weak var halfdayBtn: UIButton!
    @IBOutlet weak var fulldayBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        reasonTextView.setPlaceholder("  Provide a brief reason for your request")
        reasonTextView.setPaddingTextView(12)
        collectionView.delegate = self
        collectionView.dataSource = self
        reasonTextView.delegate = self
        fromDateField.delegate = self
        toDateField.delegate = self

        dateWarningLbl.hide()
        leaveModeWarningLbl.hide()
        leaveTypeWarningLbl.hide()
        descWarningLbl.hide()
        durationView.hide()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.isSkeletonable = true
        self.collectionView.showAnimatedGradientSkeleton()
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

            if let leaveTypeName = leaveDetails?.leave_type {
                if let matchedLeaveType = self.leaveTypeArray.first(where: { ($0.name ?? "") == leaveTypeName }) {
                    self.selectedLeaveTypeId = matchedLeaveType.unique_id ?? ""
                }
            }

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
                self.fulldayBtn.isSelected = false
            } else {
                self.halfDay = 0
                self.halfdayBtn.isSelected = false
                self.fulldayBtn.isSelected = true
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            if let fromDate = dateFormatter.date(from: self.fromDateData) {
                self.fromDatePicker.date = fromDate
            }

            if let toDate = dateFormatter.date(from: self.toDateData) {
                self.todatePicker.date = toDate
            }

            self.collectionView.reloadData()
            self.calculateLeaveDuration()
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
        calculateLeaveDuration()

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
        calculateLeaveDuration()

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
        } else {
            dateWarningLbl.hide()
        }

        calculateLeaveDuration()

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
        } else {
            dateWarningLbl.hide()
        }

        calculateLeaveDuration()

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
    @IBAction func halfDay(_ sender: Any) {
        halfDay = 1
        self.halfdayBtn.isSelected = true
        self.fulldayBtn.isSelected = false
        leaveModeWarningLbl.hide()
        calculateLeaveDuration()
    }
    @IBAction func fullDay(_ sender: Any) {
        halfDay = 0
        self.halfdayBtn.isSelected = false
        self.fulldayBtn.isSelected = true
        leaveModeWarningLbl.hide()
        calculateLeaveDuration()
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
        leaveModeWarningLbl.hide()
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

        if !halfdayBtn.isSelected && !fulldayBtn.isSelected {
            leaveModeWarningLbl.text = "Please select leave mode"
            leaveModeWarningLbl.unhide()
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
    func calculateLeaveDuration() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let fromDate = dateFormatter.date(from: fromDateData),
              let toDate = dateFormatter.date(from: toDateData) else {
            durationView.hide()
            durationLbl.text = "0 Days"
            return
        }

        durationView.unhide()

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: fromDate, to: toDate)
        let totalDays = (components.day ?? 0) + 1

        if totalDays > 0 {
            if (halfDay != 0) {
                durationLbl.text = "\(Double(totalDays) - 0.5) Day"
            } else {
                durationLbl.text = totalDays == 1 ? "1 Day" : "\(totalDays) Days"
            }
        } else {
            durationView.hide()
            durationLbl.text = "0 Days"
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
                        
                        self.collectionView.hideSkeleton()
                        
                        let listArray = resDataDic?["leave_types"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        self.leaveTypeArray.removeAll()
                        for item in listArray {
                            if let model = LeaveTypeModel(dictionary: item as NSDictionary) {
                                self.leaveTypeArray.append(model)
                            }
                        }
                        if self.comingFrom == "edit" {
                            if let leaveTypeName = self.leaveDetails?.leave_type {
                                if let matchedLeaveType = self.leaveTypeArray.first(where: { ($0.name ?? "") == leaveTypeName }) {
                                    self.selectedLeaveTypeId = matchedLeaveType.unique_id ?? ""
                                }
                            }
                        }
                        self.collectionView.reloadData()
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

                let errorCode: Int = result!["error_code"] as? Int ?? 0
                let msg = result!["error"] as? String ?? ""
                
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return leaveTypeArray.count
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 110, height: 100)
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaveTypeCCell", for: indexPath) as? LeaveTypeCCell {
            let dataModel = leaveTypeArray[indexPath.row]
            
            cell.setBorderProperties(borderColor: .systemGray5, borderWidth: 0.8, cornerRadius: 10.0, masksToBounds: true)
            cell.backgroundColor = .white
            cell.typeLbl.textColor = .label
            cell.typeLbl.text = dataModel.name

            if dataModel.unique_id == selectedLeaveTypeId {
                cell.setBorderProperties(borderColor: .theme, borderWidth: 1.5, cornerRadius: 10.0, masksToBounds: true)
                cell.backgroundColor = UIColor.theme.withAlphaComponent(0.1)
                cell.typeLbl.textColor = .theme
            }
            
            return cell
        } else {
            
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dataModel = leaveTypeArray[indexPath.row]
        selectedLeaveTypeId = dataModel.unique_id ?? ""

        leaveTypeWarningLbl.hide()
        collectionView.reloadData()
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
extension ApplyLeaveVC: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        
            return "LeaveTypeCCell"
        
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
}
