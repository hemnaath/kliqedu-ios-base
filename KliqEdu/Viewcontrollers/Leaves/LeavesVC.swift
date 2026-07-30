//
//  LeavesVC.swift
//  KliqEdu
//
//  Created by codegama on 06/04/26.
//


import UIKit
import SkeletonView
import CRRefresh
import Alamofire
import SwiftyJSON
import SDWebImage

class LeavesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterBtn: UIButton!
    
    @IBOutlet weak var addLeaveBtn: UIButton!
    @IBOutlet weak var myLeavesBtn: UIButton!
    @IBOutlet weak var studentLeaveBtn: UIButton!
    
    // 🟠 Pending, 🟢 Approved, 🔴 Rejected
    var statusTitleColor = [
        UIColor.systemOrange, UIColor.systemGreen, UIColor.systemRed]
    
    // Light background versions
    var statusBgcolor = [
        UIColor.systemOrange.withAlphaComponent(0.1),
        UIColor.systemGreen.withAlphaComponent(0.1),
        UIColor.systemRed.withAlphaComponent(0.1)]
    
    
    var leaveSection = ""
    
    var teacherLeaveArray = [LeaveModel]()
    var studentLeaveArray = [LeaveModel]()
    
    var teacherallItemsLoaded = false
    var teacherpage = 1
    var teacherisLoadingData = false
    
    var studentallItemsLoaded = false
    var studentpage = 1
    var studentisLoadingData = false
    var filters: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        
        addLeaveBtn.dropShadow()
        leaveSection = "student"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "LeaveTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "LeaveTCell")
        
        let nib1 = UINib(nibName: "TeacherLeaveTCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "TeacherLeaveTCell")
        
        studentLeaveBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        myLeavesBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        self.emptyView.isHidden = true
        self.tableView.isHidden = false

        if roleKey == "parent"{
            self.topView.hide()
            studentallItemsLoaded = false
            studentpage = 1
            self.studentisLoadingData = false
            self.studentLeaveArray.removeAll()

            getStudentLeaveData()
            
        }else{
            studentallItemsLoaded = false
            studentpage = 1
            self.studentisLoadingData = false
            self.studentLeaveArray.removeAll()

            teacherallItemsLoaded = false
            teacherpage = 1
            self.teacherisLoadingData = false
            self.teacherLeaveArray.removeAll()

            self.topView.unhide()

            if leaveSection == "student" {
                self.getTeacherStudentLeaveData()
            } else {
                self.getTeacherLeaveData()
            }
        }
        /// Pull to refresh
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            // start refresh
            
            print("refresh")
            if self?.leaveSection == "student" {
                
                self?.getStudentLeaveData()
            }else{
                self?.getTeacherLeaveData()
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
   
    }
    @IBAction func applyLeaveBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ApplyLeaveVC") as? ApplyLeaveVC {
            
            //            vc.bankId = dataModel.unique_id ?? ""
            //            vc.accStatus = dataModel.status_formatted ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func filterBtnTapped(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = true
        
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "FilterVC") as? FilterVC {
            
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical   // animation
            vc.comingFor = "Leaves"
            vc.appliedFilters = self.filters
            vc.onDismiss = { [weak self] in
                self?.tabBarController?.tabBar.isHidden = false
            }
            vc.onApplyFilter = { filters in
                
                print(filters)

                self.filters = filters

                self.studentallItemsLoaded = false
                self.studentpage = 1
                self.studentisLoadingData = false
                self.studentLeaveArray.removeAll()

                self.teacherallItemsLoaded = false
                self.teacherpage = 1
                self.teacherisLoadingData = false
                self.teacherLeaveArray.removeAll()

                if self.leaveSection == "student" {
                    if roleKey == "parent"{
                        self.getStudentLeaveData()
                    }else{
                        self.getTeacherStudentLeaveData()
                    }
                } else {
                    self.getTeacherLeaveData()
                }

            }
            present(vc, animated: true)
        }
    }
    
    @IBAction func studentLeaveBtnTapped(_ sender: Any) {
        studentLeaveBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        myLeavesBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        leaveSection = "student"
        self.emptyView.isHidden = true
        self.tableView.isHidden = false
        tableView.reloadData()
        studentallItemsLoaded = false
        studentpage = 1
        self.studentisLoadingData = false

        self.getTeacherStudentLeaveData()
        
    }
    @IBAction func myLeaveBtnTapped(_ sender: Any) {
        studentLeaveBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        myLeavesBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        leaveSection = "teacher"
        self.emptyView.isHidden = true
        self.tableView.isHidden = false
        tableView.reloadData()
        teacherallItemsLoaded = false
        teacherpage = 1
        self.teacherisLoadingData = false

        self.getTeacherLeaveData()
    }
    func getTeacherLeaveData() {
       
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        var param: [String: Any] = [
            "page": teacherpage
        ]
        if let status = filters["status"] {
            param["status"] = Int("\(status)") ?? 0
        }
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)
        
        self.callServiceMethod(service: Constants.Urls.teacherleaveListUrl, method: .post, params: param, key: "teacherleaveListUrl", headers: headers)
        
    }
    func getTeacherStudentLeaveData() {
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        var param: [String: Any] = [
            "page": studentpage
        ]
        if let status = filters["status"] {
            param["status"] = Int("\(status)") ?? 0
        }
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)
        
        self.callServiceMethod2(service: Constants.Urls.teacherStudentleaveListUrl, method: .post, params: param, key: "teacherStudentleaveListUrl", headers: headers)
        
    }
    func getStudentLeaveData() {
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        var param: [String: Any] = [
            "page": studentpage
        ]
        if let status = filters["status"] {
            param["status"] = Int("\(status)") ?? 0
        }
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)
        
        self.callServiceMethod1(service: Constants.Urls.parentleaveListUrl, method: .post, params: param, key: "studentleaveListUrl", headers: headers)
        
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        guard !self.teacherisLoadingData && !self.teacherallItemsLoaded else { return } // Prevent duplicate requests or requests when all data is loaded
        self.teacherisLoadingData = true
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "teacherleaveListUrl"{
                        self.teacherisLoadingData = false
                        
                        let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = resDataDic?["leaves"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        if self.teacherpage == 1 {
                            self.teacherLeaveArray.removeAll()
                        }
                        for item in listArray {
                            if let model = LeaveModel(dictionary: item as NSDictionary) {
                                self.teacherLeaveArray.append(model)
                            }
                        }
                        
                        DispatchQueue.main.async {

                            if self.leaveSection == "teacher" {
                                self.emptyView.isHidden = self.teacherLeaveArray.count > 0
                                self.tableView.isHidden = self.teacherLeaveArray.count == 0
                            }

                            self.tableView.reloadData()
                        }
                        // Increment skip value for the next batch of data
                        if listArray.count == 0 {
                            self.teacherallItemsLoaded = true
                            print("All items loaded. No more API calls will be made.")
                        } else {
                            self.teacherpage += 1   // go to next page
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                if errorCode == 217{
                    self.tableView.isHidden = true
                    self.emptyView.isHidden = false
                }
                if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)
                    
                }
                
            }
        }) { (error) in
            self.teacherisLoadingData = false
            
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            debugPrint(error)
        }
    }
    //API calls
    func callServiceMethod1(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        guard !self.studentisLoadingData && !self.studentallItemsLoaded else { return } // Prevent duplicate requests or requests when all data is loaded
        self.studentisLoadingData = true
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "studentleaveListUrl"{
                        self.studentisLoadingData = false
                        
                        let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = resDataDic?["leaves"] as? Array<Dictionary<String,Any>> ?? []

                        // Only clear the array if `skip` is 0, otherwise append
                        if self.studentpage == 1 {
                            self.studentLeaveArray.removeAll()
                        }
                        for item in listArray {
                            if let model = LeaveModel(dictionary: item as NSDictionary) {
                                self.studentLeaveArray.append(model)
                            }
                        }
                        
                        DispatchQueue.main.async {

                            if self.leaveSection == "student" {
                                self.emptyView.isHidden = self.studentLeaveArray.count > 0
                                self.tableView.isHidden = self.studentLeaveArray.count == 0
                            }

                            self.tableView.reloadData()
                        }
                        // Increment skip value for the next batch of data
                        if listArray.count == 0 {
                            self.studentallItemsLoaded = true
                            print("All items loaded. No more API calls will be made.")
                        } else {
                            self.studentpage += 1   // go to next page
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                if errorCode == 217{
                    self.tableView.isHidden = true
                    self.emptyView.isHidden = false
                }
                if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)
                    
                }
            }
        }) { (error) in
            self.studentisLoadingData = false
            
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            debugPrint(error)
        }
    }
    func callServiceMethod2(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        guard !self.studentisLoadingData && !self.studentallItemsLoaded else { return } // Prevent duplicate requests or requests when all data is loaded
        self.studentisLoadingData = true
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "teacherStudentleaveListUrl"{
                        self.studentisLoadingData = false
                        
                        let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = resDataDic?["leaves"] as? Array<Dictionary<String,Any>> ?? []

                        // Only clear the array if `skip` is 0, otherwise append
                        if self.studentpage == 1 {
                            self.studentLeaveArray.removeAll()
                        }
                        for item in listArray {
                            if let model = LeaveModel(dictionary: item as NSDictionary) {
                                self.studentLeaveArray.append(model)
                            }
                        }
                        
                        DispatchQueue.main.async {

                            if self.leaveSection == "student" {
                                self.emptyView.isHidden = self.studentLeaveArray.count > 0
                                self.tableView.isHidden = self.studentLeaveArray.count == 0
                            }

                            self.tableView.reloadData()
                        }
                        // Increment skip value for the next batch of data
                        if listArray.count == 0 {
                            self.studentallItemsLoaded = true
                            print("All items loaded. No more API calls will be made.")
                        } else {
                            self.studentpage += 1   // go to next page
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                if errorCode == 217{
                    self.tableView.isHidden = true
                    self.emptyView.isHidden = false
                }
                if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)
                    
                }
            }
        }) { (error) in
            self.studentisLoadingData = false
            
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            debugPrint(error)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if leaveSection == "student" {
            count = studentLeaveArray.count
        } else {
            count = teacherLeaveArray.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if leaveSection == "student" {
            let dataModel = studentLeaveArray[indexPath.row]

            if let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveTCell", for: indexPath as IndexPath) as? LeaveTCell {
                let imageURL = (dataModel.student_picture ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                if !imageURL.isEmpty {
                    cell.placeHolderlbl.isHidden = true
                    cell.leaveImg.isHidden = false
                    cell.leaveImg.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
                } else {
                    cell.leaveImg.image = nil
                    cell.leaveImg.isHidden = true
                    cell.placeHolderlbl.isHidden = false
                    let fullName = (dataModel.student_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let words = fullName.split(separator: " ")
                    let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                    let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                    cell.placeHolderlbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
                }
                
                cell.statusLbl.text = dataModel.status ?? ""
                cell.datesLbl.text = "\(dataModel.start_date ?? "") - \(dataModel.end_date ?? "")"
                cell.nameLbl.text = (dataModel.student_name ?? "")?.firstUppercased
                cell.gradeLbl.text = "Grade \(dataModel.student_grade ?? "")"
                cell.idNumberLbl.text = dataModel.student_unique_id ?? ""
                
                let totalDays = dataModel.total_days ?? 0.0
                if totalDays == 1 {
                    cell.durationLbl.text = "1 day"
                } else if totalDays.truncatingRemainder(dividingBy: 1) == 0 {
                    cell.durationLbl.text = "\(Int(totalDays)) days"
                } else {
                    cell.durationLbl.text = "\(totalDays) days"
                }
                let status = dataModel.status ?? ""

                var titleColor: UIColor = .systemOrange
                var bgColor: UIColor = UIColor.systemOrange.withAlphaComponent(0.1)

                switch status {
                case "Approved":
                    titleColor = .systemGreen
                    bgColor = UIColor.systemGreen.withAlphaComponent(0.1)
                case "Rejected":
                    titleColor = .systemRed
                    bgColor = UIColor.systemRed.withAlphaComponent(0.1)
                default:
                    titleColor = .systemOrange
                    bgColor = UIColor.systemOrange.withAlphaComponent(0.1)
                }

                cell.statusLbl.backgroundColor = bgColor
                cell.statusLbl.textColor = titleColor
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell

            } else {
                return UITableViewCell()
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TeacherLeaveTCell", for: indexPath as IndexPath) as? TeacherLeaveTCell {
                let dataModel = teacherLeaveArray[indexPath.row]

                let status = dataModel.status ?? ""

                var titleColor: UIColor = .systemOrange
                var bgColor: UIColor = UIColor.systemOrange.withAlphaComponent(0.1)

                switch status {
                case "Approved":
                    titleColor = .systemGreen
                    bgColor = UIColor.systemGreen.withAlphaComponent(0.1)
                case "Rejected":
                    titleColor = .systemRed
                    bgColor = UIColor.systemRed.withAlphaComponent(0.1)
                default:
                    titleColor = .systemOrange
                    bgColor = UIColor.systemOrange.withAlphaComponent(0.1)
                }

                cell.categoryOuterView.backgroundColor = titleColor
                cell.statusLbl.text = dataModel.status
                cell.statusLbl.backgroundColor = bgColor
                cell.statusLbl.textColor = titleColor
                cell.categoryLbl.text = dataModel.leave_type
                cell.dateLbl.text = "\(dataModel.start_date ?? "") - \(dataModel.end_date ?? "")"
                let totalDays = dataModel.total_days ?? 0.0
                if totalDays == 1 {
                    cell.durationLbl.text = "1 day"
                } else if totalDays.truncatingRemainder(dividingBy: 1) == 0 {
                    cell.durationLbl.text = "\(Int(totalDays)) days"
                } else {
                    cell.durationLbl.text = "\(totalDays) days"
                }

                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell

            } else {
                return UITableViewCell()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "LeaveViewVC") as? LeaveViewVC {
            if leaveSection == "student" {
                
                let dataModel = studentLeaveArray[indexPath.row]
                vc.uniqeId = dataModel.unique_id ?? ""
                vc.comingFrom = "parent"
                vc.leaveDetails = dataModel
                
            }else{
                let dataModel = teacherLeaveArray[indexPath.row]
                vc.uniqeId = dataModel.unique_id ?? ""
                vc.comingFrom = "teacher"
            }
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // Check if we should load more data
        if offsetY > contentHeight - height * 2 {
            if leaveSection == "student" {
                
                if !studentisLoadingData && !studentallItemsLoaded {
                    var param: [String: Any] = [
                        "page": studentpage
                    ]
                    if let status = filters["status"] {
                        param["status"] = Int("\(status)") ?? 0
                    }
                    
                    let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)
                    
                    if roleKey == "parent" {
                        self.callServiceMethod1(service: Constants.Urls.parentleaveListUrl, method: .post, params: param, key: "studentleaveListUrl", headers: headers)
                    } else {
                        self.callServiceMethod2(service: Constants.Urls.teacherStudentleaveListUrl, method: .post, params: param, key: "teacherStudentleaveListUrl", headers: headers)
                    }
                }
            }else{
                if !teacherisLoadingData && !teacherallItemsLoaded {
                    var param: [String: Any] = [
                        "page": teacherpage
                    ]
                    if let status = filters["status"] {
                        param["status"] = Int("\(status)") ?? 0
                    }
                    
                    let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)
                    
                    self.callServiceMethod(service: Constants.Urls.teacherleaveListUrl, method: .post, params: param, key: "teacherleaveListUrl", headers: headers)
                }
            }
        }
    }
}
// MARK: - UITableViewDataSource
extension LeavesVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        var cellName = ""
        
        if leaveSection == "student" {
            cellName = "LeaveTCell"
        } else {
            cellName = "TeacherLeaveTCell"
        }
          return cellName
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
