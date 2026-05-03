//
//  StudentsVC.swift
//  KliqEdu
//
//  Created by codegama on 27/03/26.
//

import UIKit
import SkeletonView
import CRRefresh
import Alamofire
import SwiftyJSON
import SDWebImage

class StudentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterBtn: UIButton!
    
    var studentsArray = [StudentsModel]()
    var timer = Timer()
    
    var allItemsLoaded = false
    var page = 1
    var isLoadingData = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true

        self.view.applyVerticalLigtGradient()
        searchBar.applyDefaultStyle(placeholder: "Search by name or ID")
        
        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "StudentListTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StudentListTCell")
        
        /// Pull to refresh
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            // start refresh
            
            print("refresh")
            self?.getStudentsData()
            
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
        getStudentsData()

        self.emptyView.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        getStudentsData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timer.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
            self.tableView.isSkeletonable = true
            self.tableView.showAnimatedGradientSkeleton()
            self.getStudentsData()
        }
    }
    
    func getStudentsData() {
        
        allItemsLoaded = false
        
        page = 1
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        
        let param = [
            "page": page,
            "search": (self.searchBar.text ?? "").trimString(),
            "grade_id": "",
            "section_id": "",
            "group_id": ""
        ] as [String : Any]
        
        let (headers, _, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param)
        
        self.callServiceMethod(service: Constants.Urls.studentsUrl, method: .post, params: param, key: "studentsUrl", headers: headers)
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
                    
                    if key == "studentsUrl"{
                        self.isLoadingData = false
                        
                        let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = resDataDic?["students"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        if self.page == 1 {
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
        
        return  studentsArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataModel = studentsArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StudentListTCell", for: indexPath as IndexPath) as? StudentListTCell {
           // cell.studentPic.image = UIImage(named: imageArray[indexPath.row])
            cell.studentNameLbl.text = dataModel.full_name
            cell.classLbl.text = dataModel.studentClass
            cell.idNumberLbl.text = dataModel.unique_id
            
            let imageURL = (dataModel.student_picture ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            if !imageURL.isEmpty {
                cell.placeHolderlbl.isHidden = true
                cell.studentPic.isHidden = false
                cell.studentPic.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
            } else {
                cell.studentPic.image = nil
                cell.studentPic.isHidden = true
                cell.placeHolderlbl.isHidden = false
                let fullName = (dataModel.full_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let words = fullName.split(separator: " ")
                let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                cell.placeHolderlbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
            }
            
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let dataModel = studentsArray[indexPath.row]

        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "StudentInfoVC") as? StudentInfoVC {
            
            vc.studentId = dataModel.unique_id ?? ""
//            vc.accStatus = dataModel.status_formatted ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.searchBar.resignFirstResponder()
            
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height
            
            // Check if we should load more data
            if offsetY > contentHeight - height * 2 {
                
                if !isLoadingData && !allItemsLoaded {
                    let param = ["page":page] as [String : Any]
                    
                    let (headers, _, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param)
                    
                    self.callServiceMethod(service: Constants.Urls.studentsUrl, method: .post, params: param, key: "studentsUrl", headers: headers)
                }
            }
        }
}
// MARK: - UITableViewDataSource
extension StudentsVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
            return "StudentListTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
