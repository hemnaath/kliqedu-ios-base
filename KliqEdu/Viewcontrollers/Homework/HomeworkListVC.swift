//
//  HomeworkListVC.swift
//  KliqEdu
//
//  Created by codegama on 13/04/26.
//

import UIKit
import SkeletonView
import CRRefresh
import Alamofire
import SwiftyJSON
import SDWebImage
class HomeworkListVC: UIViewController , UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate{

    @IBOutlet weak var createHomeworkBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!

    var homeworkArray = [HomeWorkModel]()
    var timer = Timer()
    
    var allItemsLoaded = false
    var page = 1
    var isLoadingData = false
    
    let subjectColorMap: [String: UIColor] = [
        "Mathematics": UIColor(hex: "#1976D2"),     // Blue
        "English": UIColor(hex: "#388E3C"),         // Green
        "Science": UIColor(hex: "#0097A7"),         // Teal
        "Social Studies": UIColor(hex: "#F57C00"),  // Orange
        "Geography": UIColor(hex: "#8E24AA")        // Purple
    ]
    let subjectBgColorMap: [String: UIColor] = [
        "Mathematics": UIColor(hex: "#E3F2FD"),
        "English": UIColor(hex: "#E8F5E9"),
        "Science": UIColor(hex: "#E0F7FA"),
        "Social Studies": UIColor(hex: "#FFF3E0"),
        "Geography": UIColor(hex: "#F3E5F5")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        searchBar.applyDefaultStyle(placeholder: "Search")
        createHomeworkBtn.dropShadow()

        self.view.applyVerticalLigtGradient()
        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "HomeworkTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HomeworkTCell")
        
        /// Pull to refresh
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            // start refresh
            
            print("refresh")
            self?.getHomeworkData()
            
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
        getHomeworkData()

        self.emptyView.isHidden = true
    }

//    @IBAction func backBtnTapped(_ sender: Any) {
//    
//        self.navigationController?.popViewController(animated: true)
//    }
    @IBAction func createHomeworkTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "AddHomeworkVC") as? AddHomeworkVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        getHomeworkData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timer.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.tableView.isSkeletonable = true
            self.tableView.showAnimatedGradientSkeleton()
            self.getHomeworkData()
        }
    }
    
    func getHomeworkData() {
        
        allItemsLoaded = false
        
        page = 1
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)
        
        if roleKey == "teacher"{
            
            self.callServiceMethod(service: Constants.Urls.teacherHomeworkListUrl, method: .post, params: param, key: "HomeworkUrl", headers: headers)
        }else{
            self.callServiceMethod(service: Constants.Urls.parentHomeworkUrl, method: .post, params: param, key: "HomeworkUrl", headers: headers)

        }
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        guard !self.isLoadingData && !self.allItemsLoaded else { return } // Prevent duplicate requests or requests when all data is loaded
        self.isLoadingData = true
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "HomeworkUrl"{
                        self.isLoadingData = false
                        
                      //  let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = result?["data"] as? Array<Dictionary<String,Any>> ?? []

                        // Only clear the array if `skip` is 0, otherwise append
                        if self.page == 1 {
                            self.homeworkArray.removeAll()
                        }
                        for item in listArray {
                            if let model = HomeWorkModel(dictionary: item as NSDictionary) {
                                self.homeworkArray.append(model)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if self.homeworkArray.count > 0 {
                                self.tableView.isHidden = false
                                self.emptyView.isHidden = true
                                self.searchBar.isHidden = false

                            } else {
                                
                                self.tableView.isHidden = true
                                self.emptyView.isHidden = false
                                if let text = self.searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                                    self.searchBar.isHidden = false
                                }else{
                                    self.searchBar.isHidden = true
                                }
                            }
                            self.tableView.reloadData()
                              
                        }
                        // Increment skip value for the next batch of data
                        if listArray.count == 0 {
                            self.allItemsLoaded = true
                            print("All items loaded. No more API calls will be made.")
                        } else {
                            self.page += 1   // go to next page
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
                    self.searchBar.isHidden = true
                }
               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }

            }
        }) { (error) in
            self.isLoadingData = false
            
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            debugPrint(error)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  homeworkArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataModel = homeworkArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTCell", for: indexPath as IndexPath) as? HomeworkTCell {
            // cell.studentPic.image = UIImage(named: imageArray[indexPath.row])
            cell.titleLbl.text = dataModel.title
            cell.subjectLbl.text = "  \(dataModel.subject ?? "")  "
            let subjects = Array(subjectColorMap.keys).sorted()
            let subject = subjects[indexPath.row % subjects.count]
            let color = subjectColorMap[subject] ?? .black
            cell.subjectLbl.textColor = color
            cell.subjectLbl.backgroundColor = subjectBgColorMap[subject]
            cell.gradelbl.text = "  Grade \(dataModel.grade ?? "")  "
            
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataModel = homeworkArray[indexPath.row]
//
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "HomeworkViewVC") as? HomeworkViewVC {
            
            vc.homeworkDetails = dataModel
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
