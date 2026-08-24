//
//  ChatListVC.swift
//  KliqEdu
//
//  Created by codegama on 13/07/26.
//

import UIKit
import SkeletonView
import CRRefresh
import Alamofire
import SwiftyJSON
import SDWebImage
import CoreData

class ChatListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var startChatBtn: UIButton!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var allChatsBtn: UIButton!
    @IBOutlet weak var othersBtn: UIButton!
    
    var chatArray = ["Ramesh","Priya","Hema","Ragul","Karthick","Vishnu kumar jeevan","Monisha"]
    var subjectArray = ["Science","Maths","English","Hindi","Maths","English","Hindi"]
    var msgArray = ["Hi Mam","Please note the homework","Bye...","Welcome sir","Good morning","Life","Basics"]
    var selectedTeachers: Set<Int> = []

    var chatSection = ""
    var studentsArray = [StudentsModel]()
    var teachersArray = [TeachersModel]()
    var selectedIndexPath = -1
    var allChatMessages: [SingleChatModel] = []
    var roomChatMessages: [SingleChatModel] = []
    
    var studentsallItemsLoaded = false
    var studentspage = 1
    var studentsisLoadingData = false
    var selecteduniqueId = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        chatSection = "all"
       
        
        searchBar.applyDefaultStyle(placeholder: "Search by name")

        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "ChatListTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ChatListTCell")
        
        let nib1 = UINib(nibName: "SelectTeacherTCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "SelectTeacherTCell")
        
        allChatsBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        othersBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        
        self.startChatBtn.hide()
        self.tableViewBottom.constant = 0
        
        self.emptyView.isHidden = true
        self.tableView.isHidden = false
        self.tableView.isUserInteractionEnabled = true
        
        if roleKey == "teacher"{
            self.othersBtn.setTitle("Parents", for: .normal)
        }else{
            self.othersBtn.setTitle("Teachers", for: .normal)
           
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        allChatMessages = CoreDataManager.shared.getAllMessages()

        var roomMap: [String: SingleChatModel] = [:]

        for message in allChatMessages {
            let room_id = message.room_id ?? ""

            if let existing = roomMap[room_id] {
                if (message.timestamp ?? 0) > (existing.timestamp ?? 0) {
                    roomMap[room_id] = message
                }
            } else {
                roomMap[room_id] = message
            }
        }

        roomChatMessages = roomMap.values.sorted {
            ($0.timestamp ?? 0) > ($1.timestamp ?? 0)
        }

        print("Loaded all messages:", allChatMessages.count)

        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
    func getStudentsData() {
        
        studentsallItemsLoaded = false
        
        studentspage = 1
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        let param = [
            "page": studentspage,
            "search": (self.searchBar.text ?? "").trimString()
        ] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)
        
        self.callServiceMethod(service: Constants.Urls.studentsUrl, method: .post, params: param, key: "studentsUrl", headers: headers)
    }
    func getTeachersListApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param, HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.teachersListUrl,method: .get, params: param, key: "teachersListUrl", headers: headers)
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func allChatsBtnTapped(_ sender: Any) {
        allChatsBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        othersBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        chatSection = "all"
        selectedTeachers.removeAll()
        self.emptyView.isHidden = true
        self.tableView.isHidden = false
        tableView.reloadData()
        
        self.startChatBtn.hide()
        self.tableViewBottom.constant = 0
        
    }
    @IBAction func othersBtnTapped(_ sender: Any) {
        allChatsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        othersBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        chatSection = "others"
        selectedTeachers.removeAll()
        self.emptyView.isHidden = true
        self.tableView.isHidden = false
        tableView.reloadData()
        
        self.startChatBtn.unhide()
        self.tableViewBottom.constant = 100
        
        if roleKey == "teacher"{
            self.othersBtn.setTitle("Parents", for: .normal)

            tableView.isSkeletonable = true
            self.tableView.showAnimatedGradientSkeleton()
            getStudentsData()
        }else{
            self.othersBtn.setTitle("Teachers", for: .normal)

            tableView.isSkeletonable = true
            self.tableView.showAnimatedGradientSkeleton()
            getTeachersListApi()
           
        }
    }
    @IBAction func startChatBtnTapped(_ sender: Any) {

        if chatSection == "others" {
            guard let selectedIndex = selectedTeachers.first else {
                if roleKey == "teacher" {
                    showAnimatedToast(message: "Please select a student", type: .warning)
                } else {
                    showAnimatedToast(message: "Please select a teacher", type: .warning)
                }
                return
            }
        }
        
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
            if roleKey == "teacher" {

                vc.studentsArray = studentsArray[selectedIndexPath]
            } else {
                vc.teachersArray = teachersArray[selectedIndexPath]
            }
            vc.selecteduniqueId = selecteduniqueId
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        guard !self.studentsisLoadingData && !self.studentsallItemsLoaded else { return } // Prevent duplicate requests or requests when all data is loaded
        self.studentsisLoadingData = true
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "studentsUrl"{
                        self.studentsisLoadingData = false
                        
                        let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = resDataDic?["students"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        if self.studentspage == 1 {
                            self.studentsArray.removeAll()
                        }
                        for item in listArray {
                            if let model = StudentsModel(dictionary: item as NSDictionary) {
                                self.studentsArray.append(model)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            
                            if self.studentsArray.count > 0 {
                                
                                self.tableView.isHidden = false
                                self.emptyView.isHidden = true
                                self.searchBar.isHidden = false
                                
                            } else {
                                
                                self.tableView.isHidden = true
                                self.emptyView.isHidden = false
                                
                            }
                            
                            self.tableView.reloadData()
                        }
                 
                        let pagination = resDataDic?["pagination"] as? NSDictionary

                        let currentPage = pagination?["current_page"] as? Int ?? 1
                        let totalPages = pagination?["total_pages"] as? Int ?? 1
                        let totalRecords = pagination?["total_records"] as? Int ?? 0

                        if currentPage >= totalPages {
                            
                            self.studentsallItemsLoaded = true
                            print("All items loaded. Reached last page.")
                            
                        } else {
                            
                            self.studentsallItemsLoaded = false
                            self.studentspage = currentPage + 1
                        }

                        if self.studentsArray.count >= totalRecords && totalRecords > 0 {
                            
                            self.studentsallItemsLoaded = true
                            print("All items loaded. Retrieved all records.")
                        }
                    }else if key == "teachersListUrl"{
                        
                        //    let resDataDic = result?["data"] as? NSDictionary
                            
                            self.tableView.hideSkeleton()
                            
                            let listArray = result?["data"] as? Array<Dictionary<String,Any>> ?? []
                            
                            // Only clear the array if `skip` is 0, otherwise append
                            self.teachersArray.removeAll()
                            for item in listArray {
                                if let model = TeachersModel(dictionary: item as NSDictionary) {
                                    self.teachersArray.append(model)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                if self.teachersArray.count > 0 {
                                    self.tableView.isHidden = false
                                    self.emptyView.isHidden = true

                                } else {
                                    
                                    self.tableView.isHidden = true
                                    self.emptyView.isHidden = false
                                    
                                }
                                self.tableView.reloadData()
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
                    self.searchBar.isHidden = true
                }
               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }

            }
        }) { (error) in
            self.studentsisLoadingData = false
            
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            debugPrint(error)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if chatSection == "all" {
            count = roomChatMessages.count
        } else {
            if roleKey == "teacher"{
                count = studentsArray.count
            }else{
                count = teachersArray.count
            }
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if chatSection == "all" {

            if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTCell", for: indexPath as IndexPath) as? ChatListTCell {

                let data = roomChatMessages[indexPath.row]

                let fullName = "\(data.firstname ?? "") \(data.lastname ?? "")"
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !fullName.isEmpty {
                    cell.nameLbl.text = fullName
                } else if let senderName = data.sender_name,
                          !senderName.isEmpty {
                    cell.nameLbl.text = senderName
                } else {
                    cell.nameLbl.text = data.sender_id ?? ""
                }

                if roleKey == "teacher" {
                    
                    cell.subjectLbl.text = "Grade \(data.grade ?? "") - \(data.section ?? "")"
                    
                } else {
                    
                    cell.subjectLbl.text = "\(data.subject ?? "") Teacher"
                }
                cell.msgLbl.text = data.message
                
                if let timestamp = data.timestamp {
                    let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)

                    let formatter = DateFormatter()
                    formatter.dateFormat = "hh:mm a"   // 09:35 PM

                    cell.dateLbl.text = formatter.string(from: date)
                } else {
                    cell.dateLbl.text = ""
                }
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell

            } else {
                return UITableViewCell()
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTeacherTCell", for: indexPath as IndexPath) as? SelectTeacherTCell {
                if roleKey == "teacher"{
                    
                    let dataModel = studentsArray[indexPath.row]
                    
                    cell.nameLbl.text = dataModel.full_name
                    cell.subjectLbl.text = "Grade \(dataModel.studentClass ?? "")"
                    cell.msgLbl.text = dataModel.unique_id
                    let imageURL = (dataModel.student_picture ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                    if !imageURL.isEmpty {
                        cell.placeHolderlbl.isHidden = true
                        cell.picture.isHidden = false
                        cell.picture.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
                    } else {
                        cell.picture.image = nil
                        cell.picture.isHidden = true
                        cell.placeHolderlbl.isHidden = false
                        let fullName = (dataModel.full_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        let words = fullName.split(separator: " ")
                        let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                        let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                        cell.placeHolderlbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
                    }
                }else{
                    let dataModel = teachersArray[indexPath.row]
                    
                    cell.nameLbl.text = dataModel.full_name
                    cell.subjectLbl.text = "\(dataModel.subject ?? "") Teacher"
                    cell.msgLbl.text = dataModel.email
                    
                    let imageURL = (dataModel.teacher_picture ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                    if !imageURL.isEmpty {
                        cell.placeHolderlbl.isHidden = true
                        cell.picture.isHidden = false
                        cell.picture.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
                    } else {
                        cell.picture.image = nil
                        cell.picture.isHidden = true
                        cell.placeHolderlbl.isHidden = false
                        let fullName = (dataModel.full_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        let words = fullName.split(separator: " ")
                        let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                        let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                        cell.placeHolderlbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
                    }
                }
                cell.checkBoxBtn.tag = indexPath.row
                cell.checkBoxBtn.addTarget(self, action: #selector(checkBoxBtnTapped(_:)), for: .touchUpInside)
                
                let isSelected = selectedTeachers.contains(indexPath.row)
                let imageName = isSelected ? "largecircle.fill.circle" : "circle"
                cell.checkBoxBtn.setImage(UIImage(systemName: imageName), for: .normal)
                cell.checkBoxBtn.tintColor = .theme
                
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell

            } else {
                return UITableViewCell()
            }
        }
    }
    @objc func checkBoxBtnTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        tableView(tableView, didSelectRowAt: indexPath)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if chatSection == "all" {
            let data = roomChatMessages[indexPath.row]

            let sb = UIStoryboard(name: Constants.StoryboardIds.mainSb, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
                
                vc.chatListroomID = data.room_id ?? ""
                vc.comingFrom = "chatList"
                
//                if roleKey == "teacher" {
//                    vc.selecteduniqueId = data.receiver_id ?? ""
//                }else{
//                    vc.selecteduniqueId = data.sender_id ?? ""
//                }

                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
           
        } else {
            if selectedTeachers.contains(indexPath.row) {
                selectedTeachers.removeAll()
                selecteduniqueId = ""
            } else {
                selectedTeachers.removeAll()
                selectedTeachers.insert(indexPath.row)
                selectedIndexPath = indexPath.row

                if roleKey == "teacher" {
                    selecteduniqueId = studentsArray[indexPath.row].unique_id ?? ""
                } else {
                    selecteduniqueId = teachersArray[indexPath.row].unique_id ?? ""
                }
            }

            tableView.reloadData()
            return
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.searchBar.resignFirstResponder()
            
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height
            
            // Check if we should load more data
            if offsetY > contentHeight - height * 2 {
                if roleKey == "teacher" {
                    if !studentsisLoadingData && !studentsallItemsLoaded {
                        let param = [
                            "page": studentspage,
                            "search": (self.searchBar.text ?? "").trimString()
                        ] as [String : Any]
                        
                        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)
                        
                        self.callServiceMethod(service: Constants.Urls.studentsUrl, method: .post, params: param, key: "studentsUrl", headers: headers)
                    }
                }else{
                    
                }
            }
        }
}

extension ChatListVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
            return "SelectTeacherTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
