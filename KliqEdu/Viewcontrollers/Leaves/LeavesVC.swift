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

      @IBOutlet weak var emptyView: UIView!
      @IBOutlet weak var tableView: UITableView!
      @IBOutlet weak var filterBtn: UIButton!
    
    @IBOutlet weak var addLeaveBtn: UIButton!
    @IBOutlet weak var myLeavesBtn: UIButton!
    @IBOutlet weak var studentLeaveBtn: UIButton!
        
    // 🟠 Pending, 🟢 Approved, 🔴 Rejected
    var statusTitleColor = [
        UIColor.systemOrange, UIColor.systemGreen, UIColor.systemRed,
        UIColor.systemOrange, UIColor.systemGreen, UIColor.systemRed,
        UIColor.systemOrange, UIColor.systemGreen, UIColor.systemRed,
        UIColor.systemGreen]
    
    // Light background versions
    var statusBgcolor = [
        UIColor.systemOrange.withAlphaComponent(0.1),
        UIColor.systemGreen.withAlphaComponent(0.1),
        UIColor.systemRed.withAlphaComponent(0.1),
        
        UIColor.systemOrange.withAlphaComponent(0.1),
        UIColor.systemGreen.withAlphaComponent(0.1),
        UIColor.systemRed.withAlphaComponent(0.1),
        
        UIColor.systemOrange.withAlphaComponent(0.1),
        UIColor.systemGreen.withAlphaComponent(0.1),
        UIColor.systemRed.withAlphaComponent(0.1),
        
        UIColor.systemGreen.withAlphaComponent(0.1)]
    
    
    var leaveSection = ""
    
    var teacherLeaveArray = [LeaveModel]()
    var studentLeaveArray = [LeaveModel]()

    var teacherallItemsLoaded = false
    var teacherpage = 1
    var teacherisLoadingData = false
    
    var studentallItemsLoaded = false
    var studentpage = 1
    var studentisLoadingData = false
    
      override func viewDidLoad() {
          super.viewDidLoad()
          self.tabBarController?.tabBar.isHidden = false
          self.navigationController?.isNavigationBarHidden = true

          self.view.applyVerticalLigtGradient()
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
          
          tableView.register(nib, forCellReuseIdentifier: "HomeworkTCell")
          
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
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        getStudentLeaveData()

        self.emptyView.isHidden = true
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
            vc.onDismiss = { [weak self] in
                   self?.tabBarController?.tabBar.isHidden = false
               }
    
            present(vc, animated: true)
        }
    }
    
    @IBAction func studentLeaveBtnTapped(_ sender: Any) {
        studentLeaveBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        myLeavesBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        leaveSection = "student"
        
        tableView.reloadData()
        getStudentLeaveData()
    }
    @IBAction func myLeaveBtnTapped(_ sender: Any) {
        studentLeaveBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        myLeavesBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        leaveSection = "teacher"
        tableView.reloadData()
        getTeacherLeaveData()
    }
    func getTeacherLeaveData() {
        
        teacherallItemsLoaded = false
        teacherpage = 1
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .get)
        
        self.callServiceMethod(service: Constants.Urls.teacherleaveListUrl, method: .get, params: param, key: "teacherleaveListUrl", headers: headers)
        
    }
    func getStudentLeaveData() {
        
        studentallItemsLoaded = false
        studentpage = 1
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .get)
        
        self.callServiceMethod1(service: Constants.Urls.parentleaveListUrl, method: .get, params: param, key: "studentleaveListUrl", headers: headers)
        
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
                        
                      //  let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = result?["data"] as? Array<Dictionary<String,Any>> ?? []

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
                            if self.teacherLeaveArray.count > 0 {
                                self.tableView.isHidden = false
                                self.emptyView.isHidden = true

                            } else {
                                
                                self.tableView.isHidden = true
                                self.emptyView.isHidden = false
                               
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
                
                let errorCode: Int = result!["error_code"] as? Int ?? 0
                let msg = result!["error"] as? String ?? ""
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
                        
                      //  let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = result?["data"] as? Array<Dictionary<String,Any>> ?? []

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
                            if self.studentLeaveArray.count > 0 {
                                self.tableView.isHidden = false
                                self.emptyView.isHidden = true

                            } else {
                                
                                self.tableView.isHidden = true
                                self.emptyView.isHidden = false
                               
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
                
                let errorCode: Int = result!["error_code"] as? Int ?? 0
                let msg = result!["error"] as? String ?? ""
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
        let dataModel = studentLeaveArray[indexPath.row]
        
        if leaveSection == "student" {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveTCell", for: indexPath as IndexPath) as? LeaveTCell {
                cell.leaveImg.sd_setImage(with: URL(string: dataModel.student_picture ?? ""), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
                
                cell.statusLbl.text = dataModel.status ?? ""
                cell.datesLbl.text = "\(dataModel.start_date ?? "") \(dataModel.start_date ?? "")"
                cell.durationLbl.text = "\(dataModel.total_days ?? 0) days"
                cell.nameLbl.text = dataModel.student_name ?? ""
                cell.gradeLbl.text = dataModel.student_grade ?? ""
                cell.idNumberLbl.text = dataModel.student_unique_id ?? ""
                cell.statusLbl.backgroundColor = statusBgcolor[indexPath.row]
                cell.statusLbl.textColor = statusTitleColor[indexPath.row]
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
                
            } else {
                
                return UITableViewCell()
            }
        }else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TeacherLeaveTCell", for: indexPath as IndexPath) as? TeacherLeaveTCell {
                
                cell.categoryOuterView.backgroundColor = statusTitleColor[indexPath.row]
                cell.statusLbl.text = dataModel.status
                cell.statusLbl.backgroundColor = statusBgcolor[indexPath.row]
                cell.statusLbl.textColor = statusTitleColor[indexPath.row]
                cell.categoryLbl.text = dataModel.leave_type
                cell.dateLbl.text = "\(dataModel.start_date ?? "") \(dataModel.end_date ?? "")"
                cell.durationLbl.text = "\(dataModel.total_days ?? 0) days"
                
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
                
            } else {
                
                return UITableViewCell()
            }
        }
        
    }
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  //        let dataModel = bankArray[indexPath.row]
  //
          let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
          if let vc = sb.instantiateViewController(withIdentifier: "LeaveViewVC") as? LeaveViewVC {
              
  //            vc.bankId = dataModel.unique_id ?? ""
  //            vc.accStatus = dataModel.status_formatted ?? ""
              vc.hidesBottomBarWhenPushed = true
              self.navigationController?.pushViewController(vc, animated: true)
          }
      }
  }
