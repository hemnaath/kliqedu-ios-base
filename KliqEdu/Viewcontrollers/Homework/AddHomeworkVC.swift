//
//  AddHomeworkVC.swift
//  KliqEdu
//
//  Created by codegama on 13/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkeletonView
import DropDown
class AddHomeworkVC: UIViewController {

    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var attachmentOuterview: UIView!
    @IBOutlet weak var descriptionTextview: UITextView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var titleWarningLbl: UILabel!
    @IBOutlet weak var gradeWarningLbl: UILabel!
    @IBOutlet weak var sectionWarningLbl: UILabel!
    @IBOutlet weak var groupWarningLbl: UILabel!
    @IBOutlet weak var subjectWarningLbl: UILabel!
    @IBOutlet weak var descriptionWarningLbl: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var gradeView: UIView!
    
    @IBOutlet weak var groupLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var sectionLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
    
    let gradesDropDown = DropDown()
    let sectionDropDown = DropDown()
    let groupDropDown = DropDown()
    let subjectDropDown = DropDown()

    var selectedGradeId = String()
    var selectedSectionId = String()
    var selectedGroupId = String()
    var selectedSubjectId = String()

    var comingFrom = ""
    var homeworkDetails = HomeWorkModel(dictionary: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.setLeftPaddingPoints(12)
        descriptionTextview.setPlaceholder("  Provide a detailed instruction here")
        descriptionTextview.setPaddingTextView(12)
        titleWarningLbl.hide()
        gradeWarningLbl.hide()
        sectionWarningLbl.hide()
        groupWarningLbl.hide()
        subjectWarningLbl.hide()
        descriptionWarningLbl.hide()
        
        attachmentOuterview.hide()

        titleField.delegate = self
        descriptionTextview.delegate = self
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        attachmentOuterview.addDashedBorder(borderColor: .theme, cornerRadius: 10)
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
       
        gradesApi()
        sectionsApi()
        groupsApi()
        subjectApi()
        
        if comingFrom == "edit"{
            self.createBtn.setTitle("Edit Homework", for: .normal)
            self.titleLbl.text = "Edit Homework"

            self.titleField.text = homeworkDetails?.title
            self.titleField.placeholder = ""
            self.descriptionTextview.text = homeworkDetails?.descriptionValue
            self.descriptionTextview.setPlaceholder("")
            self.gradeLbl.text = homeworkDetails?.grade_name
            self.sectionLbl.text = homeworkDetails?.section_name
            self.groupLbl.text = homeworkDetails?.group_name
            self.subjectLbl.text = homeworkDetails?.subject_name
            
            self.selectedGradeId = homeworkDetails?.grade_id ?? ""
            self.selectedSectionId = homeworkDetails?.section_id ?? ""
            self.selectedGroupId = homeworkDetails?.group_id ?? ""
            self.selectedSubjectId = homeworkDetails?.subject_id ?? ""

        }else{
            self.createBtn.setTitle("Create Homework", for: .normal)
            self.titleLbl.text = "Create Homework"

        }
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
    func groupsApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/groups",params: param, HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.groupsUrl,method: .get, params: param, key: "groupsUrl", headers: headers)
     
    }
    func subjectApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/subjects",params: param, HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.subjectsUrl,method: .get, params: param, key: "subjectsUrl", headers: headers)
     
    }
    func configureGradesDropDown(grades: [[String: Any]]) {
        
        gradesDropDown.anchorView = gradeView
        gradesDropDown.bottomOffset = CGPoint(x: 0, y: gradeView.bounds.height)
        gradesDropDown.direction = .any
        gradesDropDown.backgroundColor = .white
        gradesDropDown.cellHeight = 48
        gradesDropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.RedHatDisplayMedium, size: 15)!
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
        sectionDropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.RedHatDisplayMedium, size: 15)!
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
   
    func configureGroupDropDown(groups: [[String: Any]]) {
        
        groupDropDown.anchorView = groupView
        groupDropDown.bottomOffset = CGPoint(x: 0, y: groupView.bounds.height)
        groupDropDown.direction = .any
        groupDropDown.backgroundColor = .white
        groupDropDown.cellHeight = 48
        groupDropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.RedHatDisplayMedium, size: 15)!
        groupDropDown.selectionBackgroundColor = .themeLite1
        groupDropDown.separatorColor = UIColor.systemGray5
        
        let dropdownValues = groups.map {
            $0["name"] as? String ?? "-"
        }
        
        groupDropDown.dataSource = dropdownValues
        groupDropDown.reloadAllComponents()
        
        groupDropDown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            
            let selectedGroupData = groups[index]
            let label = selectedGroupData["name"] as? String ?? "-"
            let value = selectedGroupData["unique_id"] as? String ?? ""
            
            self.groupLbl.text = label
            self.groupWarningLbl.hide()
            self.selectedGroupId = value
            print("Selected Group:", label, value)
        }
    }

    func configureSubjectDropDown(subjects: [[String: Any]]) {
        
        subjectDropDown.anchorView = subjectView
        subjectDropDown.bottomOffset = CGPoint(x: 0, y: subjectView.bounds.height)
        subjectDropDown.direction = .any
        subjectDropDown.backgroundColor = .white
        subjectDropDown.cellHeight = 48
        subjectDropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.RedHatDisplayMedium, size: 15)!
        subjectDropDown.selectionBackgroundColor = .themeLite1
        subjectDropDown.separatorColor = UIColor.systemGray5
        
        let dropdownValues = subjects.map {
            $0["name"] as? String ?? "-"
        }
        
        subjectDropDown.dataSource = dropdownValues
        subjectDropDown.reloadAllComponents()
        
        subjectDropDown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            
            let selectedSubjectData = subjects[index]
            let label = selectedSubjectData["name"] as? String ?? "-"
            let value = selectedSubjectData["unique_id"] as? String ?? ""
            
            self.subjectLbl.text = label
            self.subjectWarningLbl.hide()
            self.selectedSubjectId = value
            print("Selected Subject:", label, value)
        }
    }
    func validateFields() -> Bool {
        var isValid = true

        titleWarningLbl.hide()
        gradeWarningLbl.hide()
        sectionWarningLbl.hide()
        groupWarningLbl.hide()
        subjectWarningLbl.hide()
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
            gradeWarningLbl.unhide()
            isValid = false
        }

        if selectedSectionId.isEmpty {
            sectionWarningLbl.unhide()
            isValid = false
        }

        if selectedGroupId.isEmpty {
            groupWarningLbl.text = "Please select group"
            groupWarningLbl.unhide()
            isValid = false
        }

        if selectedSubjectId.isEmpty {
            subjectWarningLbl.text = "Please select subject"
            subjectWarningLbl.unhide()
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
                    }else if key == "groupsUrl"{
                        
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary,
                           let groups = dataList.value(forKey: "groups") as? [[String: Any]] {

                            DispatchQueue.main.async {
                                self.configureGroupDropDown(groups: groups)
                            }
                        }
                    }else if key == "subjectsUrl"{
                        
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary,
                           let subjects = dataList.value(forKey: "subjects") as? [[String: Any]] {

                            DispatchQueue.main.async {
                                self.configureSubjectDropDown(subjects: subjects)
                            }
                        }
                    }else if key == "updateHomeworkUrl"{
                        
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
                
                let errorCode: Int = result!["error_code"] as? Int ?? 0
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
        gradesDropDown.show()

    }
    @IBAction func sectionBtnTapped(_ sender: Any) {
        sectionDropDown.show()

    }
    @IBAction func groupBtnTapped(_ sender: Any) {
        groupDropDown.show()

    }
    @IBAction func subjectBtnTapped(_ sender: Any) {
        subjectDropDown.show()

    }
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
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
                         "section_id": selectedSectionId,
                         "group_id": selectedGroupId,
                         "subject_id": selectedSubjectId,
                         "date": getCurrentDate()] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.homeworkDetails?.unique_id ?? "")",params: param, HTTPMethod: .patch)

            self.callServiceMethod(service: "\(Constants.Urls.updateHomeworkUrl)/\(self.homeworkDetails?.unique_id ?? "")",method: .patch, params: param, key: "updateHomeworkUrl", headers: headers)
            
        }else{
            let param = ["title":self.titleField.text ?? "",
                         "description": self.descriptionTextview.text ?? "",
                         "grade_id": selectedGradeId,
                         "section_id": selectedSectionId,
                         "group_id": selectedGroupId,
                         "subject_id": selectedSubjectId,
                         "date": getCurrentDate()] as [String : Any]
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/create",params: param, HTTPMethod: .post)
            
            self.callServiceMethod(service: Constants.Urls.createHomeworkUrl,method: .post, params: param, key: "updateHomeworkUrl", headers: headers)
        }
    }
}

extension AddHomeworkVC: UITextFieldDelegate, UITextViewDelegate {
    
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
