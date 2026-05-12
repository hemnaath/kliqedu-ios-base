//
//  HolidaysVC.swift
//  KliqEdu
//
//  Created by codegama on 10/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkeletonView
import CRRefresh

class HolidaysVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate  {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var holidaysArray: [HolidaysModel] = []
    
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true

        searchBar.applyDefaultStyle(placeholder: "Search holidays")
        
        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "HolidaysCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HolidaysCell")
        
        /// Pull to refresh
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            // start refresh
            
            print("refresh")
            self?.holidaysApi()
            
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
        holidaysApi()
       // navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        self.emptyView.isHidden = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        holidaysApi()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timer.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.tableView.isSkeletonable = true
            self.tableView.showAnimatedGradientSkeleton()
            self.holidaysApi()
        }
    }
    func holidaysApi(){
        
        let param = ["search": (self.searchBar.text ?? "").trimString()] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param, HTTPMethod: .post)
        
        if roleKey == "teacher"{
            self.callServiceMethod(service: Constants.Urls.teacherHolidaysUrl,method: .post, params: param, key: "holidaysUrl", headers: headers)

        }else{
            self.callServiceMethod(service: Constants.Urls.parentHolidaysUrl,method: .post, params: param, key: "holidaysUrl", headers: headers)
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
      
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "holidaysUrl"{
                        
                        let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = resDataDic?["holidays"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        self.holidaysArray.removeAll()
                        for item in listArray {
                            if let model = HolidaysModel(dictionary: item as NSDictionary) {
                                self.holidaysArray.append(model)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if self.holidaysArray.count > 0 {
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
            
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            debugPrint(error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  holidaysArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataModel = holidaysArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HolidaysCell", for: indexPath as IndexPath) as? HolidaysCell {
            cell.dateLbl.text = dataModel.date
            cell.monthLbl.text = String(dataModel.month?.prefix(3) ?? "")
            cell.titleLbl.text = dataModel.name
            cell.dayLbl.text = dataModel.day

            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }

}
// MARK: - UITableViewDataSource
extension HolidaysVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
            return "HolidaysCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
