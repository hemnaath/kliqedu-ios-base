//
//  CreateAnnouncementVC.swift
//  KliqEdu
//
//  Created by codegama on 29/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkeletonView
import DropDown

class CreateAnnouncementVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var gradeView: UIView!
    @IBOutlet weak var sectionLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var descriptionTextview: UITextView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var titleWarningLbl: UILabel!
    @IBOutlet weak var gradeWarningLbl: UILabel!
    @IBOutlet weak var sectionWarningLbl: UILabel!
    @IBOutlet weak var descriptionWarningLbl: UILabel!

    let gradesDropDown = DropDown()
    let sectionDropDown = DropDown()

    var selectedGradeId = String()
    var selectedSectionId = String()
    var comingFrom = ""
    var announcementDetails = AnnouncementModel(dictionary: [:])

    override func viewDidLoad() {
        super.viewDidLoad()

        titleField.setLeftPaddingPoints(12)
        descriptionTextview.setPlaceholder("  Provide a detailed instruction here")
        descriptionTextview.setPaddingTextView(12)
        titleWarningLbl.hide()
        gradeWarningLbl.hide()
        sectionWarningLbl.hide()
        descriptionWarningLbl.hide()
        titleField.delegate = self
        descriptionTextview.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
       
        gradesApi()
        sectionsApi()
        
        if comingFrom == "edit"{
            self.createBtn.setTitle("Edit Announcement", for: .normal)
            self.titleLbl.text = "Edit Announcement"

            self.titleField.text = announcementDetails?.title
            self.titleField.placeholder = ""
            self.descriptionTextview.text = announcementDetails?.descriptionValue
            self.descriptionTextview.setPlaceholder("")
            self.gradeLbl.text = announcementDetails?.grade_id
            self.sectionLbl.text = announcementDetails?.section_id
            
            self.selectedGradeId = announcementDetails?.grade ?? ""
            self.selectedSectionId = announcementDetails?.section ?? ""
        }else{
            self.createBtn.setTitle("Create Announcement", for: .normal)
            self.titleLbl.text = "Create Announcement"

        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    func gradesApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/grades",params: param, HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.gradesUrl,method: .get, params: param, key: "gradesUrl", headers: headers)
     
    }
    func sectionsApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/sections",params: param, HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.sectionsUrl,method: .get, params: param, key: "sectionsUrl", headers: headers)
     
    }
    func configureGradesDropDown(grades: [[String: Any]]) {
        
        gradesDropDown.anchorView = gradeView
        gradesDropDown.bottomOffset = CGPoint(x: 0, y: gradeView.bounds.height)
        gradesDropDown.direction = .any
        gradesDropDown.backgroundColor = .white
        gradesDropDown.cellHeight = 48
        gradesDropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.FontMedium, size: 15)!
        gradesDropDown.selectionBackgroundColor = .themeLite1
        gradesDropDown.separatorColor = UIColor.systemGray5
        
        // Extract labels for dropdown
        let dropdownValues = grades.map {
            $0["name"] as? String ?? "-"
        }
        
        gradesDropDown.dataSource = dropdownValues
        gradesDropDown.reloadAllComponents()
        
        gradesDropDown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            
            let selectedGradeData = grades[index]
            let label = selectedGradeData["name"] as? String ?? "-"
            let value = selectedGradeData["unique_id"] as? String ?? ""
            
            self.gradeLbl.text = label
            self.gradeWarningLbl.hide()
            self.selectedGradeId = value
            print("Selected grade:", label, value)
        }
    }
    func configureSectionDropDown(sections: [[String: Any]]) {
        
        sectionDropDown.anchorView = sectionView
        sectionDropDown.bottomOffset = CGPoint(x: 0, y: sectionView.bounds.height)
        sectionDropDown.direction = .any
        sectionDropDown.backgroundColor = .white
        sectionDropDown.cellHeight = 48
        sectionDropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.FontMedium, size: 15)!
        sectionDropDown.selectionBackgroundColor = .themeLite1
        sectionDropDown.separatorColor = UIColor.systemGray5
        
        // Extract labels for dropdown
        let dropdownValues = sections.map {
            $0["name"] as? String ?? "-"
        }
        
        sectionDropDown.dataSource = dropdownValues
        sectionDropDown.reloadAllComponents()
        
        sectionDropDown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            
            let selectedGradeData = sections[index]
            let label = selectedGradeData["name"] as? String ?? "-"
            let value = selectedGradeData["unique_id"] as? String ?? ""
            
            self.sectionLbl.text = label
            self.sectionWarningLbl.hide()
            self.selectedSectionId = value
            print("Selected Section:", label, value)
        }
    }
   
    func validateFields() -> Bool {
        var isValid = true

        titleWarningLbl.hide()
        gradeWarningLbl.hide()
        sectionWarningLbl.hide()
        descriptionWarningLbl.hide()

        if (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleWarningLbl.text = "Please enter title"
            titleWarningLbl.unhide()
            isValid = false
        } else if (titleField.text ?? "").count < 3 {
            titleWarningLbl.text = "Title should be minimum 3 characters"
            titleWarningLbl.unhide()
            isValid = false
        }

        if selectedGradeId.isEmpty {
            gradeWarningLbl.text = "Please select grade"
            gradeWarningLbl.unhide()
            isValid = false
        }

        if selectedSectionId.isEmpty {
            sectionWarningLbl.text = "Please select section"
            sectionWarningLbl.unhide()
            isValid = false
        }

        if (descriptionTextview.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || descriptionTextview.text == "  Provide a detailed instruction here" {
            descriptionWarningLbl.text = "Please enter description"
            descriptionWarningLbl.unhide()
            isValid = false
        } else if (descriptionTextview.text ?? "").count < 5 {
            descriptionWarningLbl.text = "Description should be minimum 5 characters"
            descriptionWarningLbl.unhide()
            isValid = false
        }

        return isValid
    }

    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "gradesUrl"{

                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary,
                           let grades = dataList.value(forKey: "grades") as? [[String: Any]] {

                            DispatchQueue.main.async {
                                self.configureGradesDropDown(grades: grades)
                            }
                        }
                    }else if key == "sectionsUrl"{
                        
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary,
                           let sections = dataList.value(forKey: "sections") as? [[String: Any]] {

                            DispatchQueue.main.async {
                                self.configureSectionDropDown(sections: sections)
                            }
                        }
                    }else if key == "createAnnouncementUrl"{
                        
                        self.createBtn?.hideButtonLoading()

                            DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            }
                    }
                    
                } else {
                    self.createBtn?.hideButtonLoading()

                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                self.createBtn?.hideButtonLoading()

               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }

            }
        }) { (error) in
            self.createBtn?.hideButtonLoading()

            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            
            debugPrint(error)
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func gradeBtnTapped(_ sender: Any) {
        if gradesDropDown.dataSource.isEmpty {
            self.showAnimatedToast(message: "No grade found", type: .warning)
            return
        }
        gradesDropDown.show()
        
    }
    @IBAction func sectionBtnTapped(_ sender: Any) {
        if sectionDropDown.dataSource.isEmpty {
            self.showAnimatedToast(message: "No section found", type: .warning)
            return
           }
        sectionDropDown.show()

    }
    @IBAction func createBtnTapped(_ sender: Any) {
        createBtn?.showButtonLoading()
        if !validateFields() {
            createBtn?.hideButtonLoading()
            return
        }

        if comingFrom == "edit"{
            let param = ["title":self.titleField.text ?? "",
                         "description": self.descriptionTextview.text ?? "",
                         "grade_id": selectedGradeId,
                         "section_id": selectedSectionId] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.announcementDetails?.unique_id ?? "")",params: param, HTTPMethod: .patch)

            self.callServiceMethod(service: "\(Constants.Urls.updateAnnouncementUrl)/\(self.announcementDetails?.unique_id ?? "")",method: .patch, params: param, key: "createAnnouncementUrl", headers: headers)
            
        }else{
            let param = ["title":self.titleField.text ?? "",
                         "description": self.descriptionTextview.text ?? "",
                         "grade_id": selectedGradeId,
                         "section_id": selectedSectionId] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/create",params: param, HTTPMethod: .post)
            
            self.callServiceMethod(service: Constants.Urls.createAnnouncementUrl,method: .post, params: param, key: "createAnnouncementUrl", headers: headers)
        }
    }
    
}

extension CreateAnnouncementVC: UITextFieldDelegate, UITextViewDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == titleField {
            titleWarningLbl.hide()
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return true }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 100
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView == descriptionTextview {
            let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if text.count >= 5 {
                descriptionWarningLbl.hide()
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == descriptionTextview {
            descriptionWarningLbl.hide()
        }
    }
}
