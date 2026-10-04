//
//  DashboardVC.swift
//  KliqEdu
//
//  Created by codegama on 26/03/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkeletonView
import SDWebImage

class DashboardVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var placeHolderNameLbl: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var goodMorningLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var quoteLbl: UILabel!
    @IBOutlet weak var quoteAuthorLbl: UILabel!
    
    @IBOutlet weak var studentsCard: UIView!
    @IBOutlet weak var noticesCard: UIView!
    @IBOutlet weak var holidaysCard: UIView!
    @IBOutlet weak var feesCard: UIView!
    @IBOutlet weak var teachersCard: UIView!
    @IBOutlet weak var studentInfoCard: UIView!
    @IBOutlet weak var visitorPassCard: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var bottomStackView: UIStackView!

    // Workload & subjects (teacher only)
    @IBOutlet weak var workloadContainer: UIView!
    @IBOutlet weak var totalHoursLbl: UILabel!
    @IBOutlet weak var workloadProgressView: UIProgressView!
    @IBOutlet weak var teachingHoursLbl: UILabel!
    @IBOutlet weak var teachingPercentLbl: UILabel!
    @IBOutlet weak var operationalHoursLbl: UILabel!
    @IBOutlet weak var operationalPercentLbl: UILabel!
    @IBOutlet weak var classTeacherView: UIView!
    @IBOutlet weak var classTeacherLbl: UILabel!
    @IBOutlet weak var subjectsCountLbl: UILabel!
    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    @IBOutlet weak var noSubjectsLbl: UILabel!

    var profileDetails: ProfileModel?
    var announcementArray = [AnnouncementModel]()
    var teacherWorkload: TeacherWorkload?

    /// Skeleton is shown only until the first successful load; later visits refresh in the background.
    private var hasLoadedDashboard = false
    private var isProfileLoading = false

    /// Same role rule everywhere on this screen: anything that isn't a parent gets the teacher dashboard.
    private var isTeacher: Bool { roleKey != "parent" }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false

        self.placeHolderNameLbl.layer.cornerRadius = 21
        self.placeHolderNameLbl.layer.masksToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(labelAction(gesture:)))
        profileContainerView.isUserInteractionEnabled = true
        profileContainerView.addGestureRecognizer(tap)

        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "NotificationsTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NotificationsTCell")
        tableView.isSkeletonable = true

        self.quoteLbl.adjustsFontSizeToFitWidth = true
        self.quoteLbl.minimumScaleFactor = 0.8
        self.quoteLbl.numberOfLines = 4
        self.quoteLbl.lineBreakMode = .byTruncatingTail
        self.quoteLbl.baselineAdjustment = .alignCenters
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        
        userID = defaults.value(forKey: Constants.Keys.userIdKey) as? Int ?? 0
        api_Key = defaults.value(forKey: Constants.Keys.apiKey) as? String ?? ""
        salt_Key = defaults.value(forKey: Constants.Keys.saltKey) as? String ?? ""
        token = defaults.value(forKey: Constants.Keys.accessTokenKey) as? String ?? ""
        roleKey = defaults.value(forKey: Constants.Keys.roleKey) as? String ?? ""

        updateGreetingText()

        self.studentsCard.isHidden = !isTeacher
        self.feesCard.isHidden = isTeacher
        self.teachersCard.isHidden = isTeacher
        self.visitorPassCard.isHidden = isTeacher
        self.workloadContainer.isHidden = !isTeacher

        if !hasLoadedDashboard {
            self.emptyView.isHidden = true
            self.view.showSkeleton(cornerRadius: 0)
            self.tableView.showAnimatedGradientSkeleton()
        }

        self.dashboardApi()
        if isTeacher {
            self.teacherProfileApi()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func updateGreetingText() {

        let hour = Calendar.current.component(.hour, from: Date())
        print("Current Hour:", hour)

        switch hour {
        case 5..<12:
            goodMorningLbl.text = "Good Morning"
        case 12..<17:
            goodMorningLbl.text = "Good Afternoon"
        case 17..<21:
            goodMorningLbl.text = "Good Evening"
        default:
            goodMorningLbl.text = "Good Night"
        }

        print("Greeting:", goodMorningLbl.text ?? "")
    }
   
    func dashboardApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/get",params: param,HTTPMethod: .get)
        
        if isTeacher {
            self.callServiceMethod(service: Constants.Urls.teacherDashboardUrl,method: .get, params: param, key: "dashboardUrl", headers: headers)

        }else{
            self.callServiceMethod(service: Constants.Urls.parentDashboardUrl,method: .get, params: param, key: "dashboardUrl", headers: headers)
        }
    }
    func teacherProfileApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/profile",params: param,HTTPMethod: .get)

        isProfileLoading = true
        self.callServiceMethod(service: Constants.Urls.profileUrl,method: .get, params: param, key: "profileUrl", headers: headers)
    }
    @objc func labelAction(gesture: UITapGestureRecognizer){
        if isTeacher {
            
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.settingsSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ParentProfileVC") as? ParentProfileVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @IBAction func chatBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ChatListVC") as? ChatListVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func studentsBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.studentPermissionKey) as? Bool ?? false
        
        if permission {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "StudentsVC") as? StudentsVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func noticesBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.announcementsPermissionKey) as? Bool ?? false

        if permission {
            
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ActivitiesVC") as? ActivitiesVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func holidaysBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.holidayPermissionKey) as? Bool ?? false
        
        if permission {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "HolidaysVC") as? HolidaysVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func feesBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.feesPermissionKey) as? Bool ?? false
        
        if permission {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "FeesListVC") as? FeesListVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func teachersBtnTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.teacherPermissionKey) as? Bool ?? false
        
        if permission {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "TeachersListVC") as? TeachersListVC {
                
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    @IBAction func visitorPassBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "VisitorPassListVC") as? VisitorPassListVC {
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func timeTableBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "TimeTableVC") as? TimeTableVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func viewAllAnnouncementTapped(_ sender: Any) {
        let permission = defaults.value(forKey: Constants.Keys.announcementsPermissionKey) as? Bool ?? false

        if permission {
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ActivitiesVC") as? ActivitiesVC {

                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.showAnimatedToast(message: "You don't have permission to access this page",type: .warning)
        }
    }
    //API calls
    /// Ends the loading state for one request, whether it succeeded or not.
    /// The dashboard and profile calls run in parallel, so each only hides its own part of the skeleton.
    func finishLoading(key: String) {
        if key == "dashboardUrl" {
            self.view.hideSkeleton()
            self.tableView.hideSkeleton()
            // Keep the workload card in its loading state until the profile response arrives.
            if isTeacher && isProfileLoading && teacherWorkload == nil {
                self.workloadContainer.showAnimatedGradientSkeleton()
            }
            if announcementArray.isEmpty {
                self.tableView.isHidden = true
                self.emptyView.isHidden = false
            }
        } else if key == "profileUrl" {
            isProfileLoading = false
            self.workloadContainer.hideSkeleton()
        }
    }

    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {

        // AlamofireHC returns without calling back when offline, which would leave the skeleton running.
        guard NetworkManager.shared.isConnected else {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            finishLoading(key: key)
            return
        }

        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in

            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {

                if let responseDict = result as NSDictionary? {

                    if key == "dashboardUrl"{
                        // Hide the skeleton before setting data: SkeletonView restores the
                        // pre-skeleton label text when it hides, which would overwrite new values.
                        self.finishLoading(key: key)
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            self.hasLoadedDashboard = true

                            self.quoteLbl.text = dataList.value(forKey: "quote") as? String
                            self.quoteAuthorLbl.text = "- \(dataList.value(forKey: "author") as? String ?? "")"
                            self.nameLbl.text = (dataList.value(forKey: "full_name") as? String)?.firstUppercased
                            let fullName1 = "\(dataList.value(forKey: "full_name") as? String ?? "")"

                            let imageUrl = dataList.value(forKey: "picture") as? String ?? ""

                            if !imageUrl.isEmpty {
                                self.placeHolderNameLbl.isHidden = true
                                self.profilePic.isHidden = false
                                self.profilePic.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "male.png"), options: .refreshCached, completed: nil)
                            } else {
                                self.profilePic.image = nil
                                self.profilePic.isHidden = true
                                self.placeHolderNameLbl.isHidden = false
                                let fullName = (fullName1).trimmingCharacters(in: .whitespacesAndNewlines)
                                let words = fullName.split(separator: " ")
                                let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                                let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                                self.placeHolderNameLbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
                            }

                            let listArray = dataList["announcementData"] as? Array<Dictionary<String,Any>> ?? []
                            
                            // Only clear the array if `skip` is 0, otherwise append
                                self.announcementArray.removeAll()
                            
                            for item in listArray {
                                if let model = AnnouncementModel(dictionary: item as NSDictionary) {
                                    self.announcementArray.append(model)
                                }
                            }
                            
                            self.tableView.isHidden = self.announcementArray.isEmpty
                            self.emptyView.isHidden = !self.announcementArray.isEmpty
                            self.tableView.reloadData()
                        }
                    }else if key == "profileUrl"{
                        self.finishLoading(key: key)
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {
                            
                            self.profileDetails = ProfileModel(dictionary: dataList)
                            
                            let uniqueId = dataList["unique_id"] as? String ?? ""
                            defaults.set(uniqueId, forKey: Constants.Keys.userUniqueIdKey)
                            // Teacher's own name, sent as `sender_name` in chat (login only stores children's names).
                            defaults.set(dataList["firstname"] as? String ?? "", forKey: Constants.Keys.firstNameKey)
                            defaults.set(dataList["lastname"] as? String ?? "", forKey: Constants.Keys.lastNameKey)
                            defaults.synchronize()

                            self.configureWorkload(workload: TeacherWorkload(dictionary: dataList))
                        }
                    }
                } else {
                    self.finishLoading(key: key)
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                self.finishLoading(key: key)

                let errorCode: Int = result?["status_code"] as? Int ?? 0
                let msg = result?["message"] as? String ?? StringConstants.somethingWentWrong

               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {

                    self.performLogout(Vc: self)
                } else {

                    self.showAnimatedToast(message: msg,type: .warning)

                }

            }
        }) { (error) in
            self.finishLoading(key: key)
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)

            debugPrint(error)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  announcementArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataModel = announcementArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTCell", for: indexPath as IndexPath) as? NotificationsTCell {

            cell.titleLbl.text = dataModel.title
            cell.descriptionLbl.text = dataModel.descriptionValue
            cell.dateLbl.text = "  \(dataModel.created_at ?? "")  "
            cell.descriptionLbl.addInterlineSpacing(spacingValue: 5, alignment: .left)

            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Skeleton placeholder rows can be tapped before the data arrives.
        guard announcementArray.indices.contains(indexPath.row) else { return }
        let dataModel = announcementArray[indexPath.row]

        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "AnnouncementDetailsVC") as? AnnouncementDetailsVC {
            
            vc.announcementDetails = dataModel
            vc.uniqueId = dataModel.unique_id ?? ""
//            vc.accStatus = dataModel.status_formatted ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
// MARK: - UITableViewDataSource
extension DashboardVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
            return "NotificationsTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}

// MARK: - Workload & subjects (teacher only)

extension DashboardVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func configureWorkload(workload: TeacherWorkload) {
        self.teacherWorkload = workload
        
        totalHoursLbl.text = formattedHours(workload.totalHours)
        workloadProgressView.setProgress(Float(min(max(workload.teachingPercentage / 100, 0), 1)), animated: false)
        
        teachingHoursLbl.text = "\(formattedHours(workload.teachingHours)) hrs"
        teachingPercentLbl.text = "\(Int(workload.teachingPercentage.rounded()))%"
        operationalHoursLbl.text = "\(formattedHours(workload.operationalHours)) hrs"
        operationalPercentLbl.text = "\(Int(workload.operationalPercentage.rounded()))%"
        
        classTeacherView.isHidden = !workload.isClassTeacher
        classTeacherLbl.text = workload.classTeacherText
        
        let count = workload.allocations.count
        subjectsCountLbl.text = count == 1 ? "1 subject" : "My Subjects (\(count))"
        noSubjectsLbl.isHidden = count > 0
        subjectsCollectionView.isHidden = count == 0
        subjectsCollectionView.reloadData()
    }
    
    func formattedHours(_ hours: Double) -> String {
        hours.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(hours))" : String(format: "%.1f", hours)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teacherWorkload?.allocations.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectAllocationCCell", for: indexPath) as! SubjectAllocationCCell
        if let workload = teacherWorkload {
            let allocation = workload.allocations[indexPath.item]
            cell.configureCellWith(allocation: allocation, isClassTeacherClass: workload.isClassTeacherClass(allocation))
        }
        return cell
    }
}
