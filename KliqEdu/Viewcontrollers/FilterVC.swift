//
//  FilterVC.swift
//  KliqEdu
//
//  Created by codegama on 01/05/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkeletonView

class FilterVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var gradeBadge: UILabel!
    @IBOutlet weak var sectionBadge: UILabel!
    @IBOutlet weak var groupBadge: UILabel!
    @IBOutlet weak var statusBadge: UILabel!
    @IBOutlet weak var dateBadge: UILabel!

    @IBOutlet weak var gradeView: UIView!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var dateOuterView: UIStackView!
    
    @IBOutlet weak var gradeBtn: UIButton!
    @IBOutlet weak var sectionBtn: UIButton!
    @IBOutlet weak var groupBtn: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tablviewOuterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    
    // MARK: - Variables
    
    var gradeArray = [GradeSectionModel]()
    var sectionListArray = [GradeSectionModel]()
    var groupListArray = [GradeSectionModel]()

    var selectedType = "Grade"
    
    let statusArray = ["Pending", "Success", "Failed"]
    
    var selectedGrade = ""
    var selectedSection = ""
    var selectedGroup = ""
    var selectedStatus = ""
    var selectedGradeId = ""
    var selectedSectionId = ""
    var selectedGroupId = ""
    var onDismiss: (() -> Void)?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.view.backgroundColor = .clear
        emptyView.isHidden = true
        tableView.isHidden = false
        dateOuterView.isHidden = true

        self.delay(bySeconds: 0.25) { [weak self] in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.5)
            }
        }
        gradesApi()
        sectionsApi()
        groupsApi()
        tableView.separatorStyle = .none
        let nib = UINib(nibName: "FilterTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FilterTCell")
        
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
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "gradesUrl" {

                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary,
                           let grades = dataList.value(forKey: "grades") as? [[String: Any]] {

                            self.gradeArray.removeAll()

                            for item in grades {
                                let model = GradeSectionModel(dictionary: item as NSDictionary)
                                self.gradeArray.append(model!)
                            }

                            DispatchQueue.main.async {
                                if self.selectedType == "Grade" {
                                    self.updateEmptyView()
                                    self.tableView.reloadData()
                                }
                            }
                        }

                    } else if key == "sectionsUrl" {

                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary,
                           let sections = dataList.value(forKey: "sections") as? [[String: Any]] {

                            self.sectionListArray.removeAll()

                            for item in sections {
                                let model = GradeSectionModel(dictionary: item as NSDictionary)
                                self.sectionListArray.append(model!)
                            }

                            DispatchQueue.main.async {
                                if self.selectedType == "Section" {
                                    self.updateEmptyView()
                                    self.tableView.reloadData()
                                }
                            }
                        }

                    } else if key == "groupsUrl" {

                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary,
                           let groups = dataList.value(forKey: "groups") as? [[String: Any]] {

                            self.groupListArray.removeAll()

                            for item in groups {
                                let model = GradeSectionModel(dictionary: item as NSDictionary)
                                self.groupListArray.append(model!)
                            }

                            DispatchQueue.main.async {
                                if self.selectedType == "Group" {
                                    self.updateEmptyView()
                                }
                                self.tableView.reloadData()
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
    // MARK: - Setup UI
    
    func setupUI() {
        
        updateButtons()
        
    }
    
    // MARK: - Update Button UI
    
    func updateButtons() {
        
        let buttons = [gradeBtn, sectionBtn, groupBtn, statusBtn, dateBtn]
        let buttonBgView = [gradeView, sectionView, groupView, statusView, dateView]

        buttons.forEach {
            $0?.setTitleColor(.black, for: .normal)
        }
        
        buttonBgView.forEach {
            $0?.backgroundColor = .themeLite
        }

        // Hide all badges first
        [gradeBadge, sectionBadge, groupBadge, statusBadge, dateBadge].forEach {
            $0?.isHidden = true
        }

        switch selectedType {
        case "Grade":
            gradeView.backgroundColor = .white
            gradeBadge.isHidden = false
            selectedButton(gradeBtn)
        case "Section":
            sectionView.backgroundColor = .white
            sectionBadge.isHidden = false
            selectedButton(sectionBtn)
        case "Group":
            groupView.backgroundColor = .white
            groupBadge.isHidden = false
            selectedButton(groupBtn)
        case "Status":
            statusView.backgroundColor = .white
            statusBadge.isHidden = false
            selectedButton(statusBtn)
        case "Date":
            dateView.backgroundColor = .white
            dateBadge.isHidden = false
            selectedButton(dateBtn)
        default:
            break
        }
    }
    
    func selectedButton(_ button: UIButton) {
                
        button.setTitleColor(.theme, for: .normal)
        
    }
    
    // MARK: - Current Array
    
    func currentArray() -> [GradeSectionModel] {

        switch selectedType {

        case "Grade":
            return gradeArray

        case "Section":
            return sectionListArray
        
        case "Group":
            return groupListArray

        case "Status":
            return statusArray.map {
                let dict: NSDictionary = ["name": $0, "unique_id": $0]
                return GradeSectionModel(dictionary: dict)!
            }

        default:
            return []
        }
    }
    
    func updateEmptyView() {

        let hasData = !currentArray().isEmpty

        emptyView.isHidden = hasData
        tableView.isHidden = !hasData
    }

    // MARK: - Button Actions
    
    @IBAction func gradeTapped(_ sender: UIButton) {
        selectedType = "Grade"
        updateButtons()
        updateEmptyView()
        tableView.reloadData()
    }
    
    @IBAction func sectionTapped(_ sender: UIButton) {
        selectedType = "Section"
        updateButtons()
        updateEmptyView()
        tableView.reloadData()
    }
    
    @IBAction func groupTapped(_ sender: UIButton) {
        selectedType = "Group"
        updateButtons()
        updateEmptyView()
        tableView.reloadData()
    }
    
    @IBAction func statusTapped(_ sender: UIButton) {
        selectedType = "Status"
        updateButtons()
        updateEmptyView()
        tableView.reloadData()
    }
    
    @IBAction func clearTapped(_ sender: UIButton) {
        
        selectedGrade = ""
        selectedSection = ""
        selectedGroup = ""
        selectedStatus = ""
        selectedGradeId = ""
        selectedSectionId = ""
        selectedGroupId = ""
        
        tableView.reloadData()
    }
    
    @IBAction func applyTapped(_ sender: UIButton) {
        
        print("Selected Grade:", selectedGrade)
        print("Selected Section:", selectedSection)
        print("Selected Group:", selectedGroup)
        print("Selected Group Id:", selectedGroupId)
        print("Selected Status:", selectedStatus)
        
        dismiss(animated: true)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.onDismiss?()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss?()
    }
}

// MARK: - UITableView Delegate/DataSource

extension FilterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return currentArray().count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTCell", for: indexPath as IndexPath) as? FilterTCell {
            
            let dataModel = currentArray()[indexPath.row]

            let value = dataModel.name ?? ""

            switch selectedType {

            case "Grade":
                cell.titleLbl?.text = "Grade \(value)"

            case "Section":
                cell.titleLbl?.text = "Sec \(value)"
            
            case "Group":
                cell.titleLbl?.text = "\(value)"

            case "Status":
                cell.titleLbl?.text = "\(value)"

            default:
                break
            }
            cell.selectionStyle = .none
            
            cell.checkBoxBtn.isUserInteractionEnabled = false
            
            // Selected image
            
            if isSelected(value: value) {
                
                cell.checkBoxBtn.isSelected = true
                                
            } else {
                
                cell.checkBoxBtn.isSelected = false
                
            }
            
            return cell
        }else {
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let dataModel = currentArray()[indexPath.row]
        let value = dataModel.name ?? ""
        
        switch selectedType {

        case "Grade":

            if selectedGrade == value {
                selectedGrade = ""
                selectedGradeId = ""
            } else {
                selectedGrade = value
                selectedGradeId = dataModel.unique_id ?? ""
            }

        case "Section":

            if selectedSection == value {
                selectedSection = ""
                selectedSectionId = ""
            } else {
                selectedSection = value
                selectedSectionId = dataModel.unique_id ?? ""
            }
        
        case "Group":

            if selectedGroupId == dataModel.unique_id ?? "" {
                selectedGroup = ""
                selectedGroupId = ""
            } else {
                selectedGroup = value
                selectedGroupId = dataModel.unique_id ?? ""
            }

        case "Status":

            if selectedStatus == value {
                selectedStatus = ""
            } else {
                selectedStatus = value
            }

        default:
            break
        }
        
        tableView.reloadData()
    }
    // MARK: - Selected Check
    
    func isSelected(value: String) -> Bool {
        
        switch selectedType {
            
        case "Grade":
            
            return selectedGrade == value
            
        case "Section":
            
            return selectedSection == value
        
        case "Group":

            return selectedGroup == value

        case "Status":
            
            return selectedStatus == value
            
        default:
            
            return false
            
        }
        
    }
}
// MARK: - UITableViewDataSource
extension FilterVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
            return "FilterTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 5
    }
}
