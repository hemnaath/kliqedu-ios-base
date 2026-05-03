//
//  TeachersListVC.swift
//  KliqEdu
//
//  Created by codegama on 28/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkeletonView
import CRRefresh
import SDWebImage

class TeachersListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!

    var teachersArray: [TeachersModel] = []
    
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
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true

        self.view.applyVerticalLigtGradient()
        
        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "TeachersTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TeachersTCell")
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        /// Pull to refresh
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            // start refresh
            
            print("refresh")
            self?.getTeachersListApi()
            
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
        getTeachersListApi()

        self.emptyView.isHidden = true
    }
   
    func getTeachersListApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param)
        
        self.callServiceMethod(service: Constants.Urls.teachersListUrl,method: .get, params: param, key: "teachersListUrl", headers: headers)
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
                    
                    if key == "teachersListUrl"{
                        
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
            
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            debugPrint(error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  teachersArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataModel = teachersArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TeachersTCell", for: indexPath as IndexPath) as? TeachersTCell {
            cell.nameLbl.text = dataModel.full_name
            cell.subjectLbl.text = "  \(dataModel.subject ?? "")  "
            cell.emailLbl.text = dataModel.email
            let subjects = Array(subjectColorMap.keys).sorted()
            let subject = subjects[indexPath.row % subjects.count]
            let color = subjectColorMap[subject] ?? .black
            let bgColor = subjectBgColorMap[subject] ?? UIColor.clear
            
            cell.subjectLbl.textColor = color
            cell.subjectLbl.backgroundColor = bgColor
            
            let imageURL = (dataModel.teacher_picture ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            if !imageURL.isEmpty {
                cell.placeHolderNameLbl.isHidden = true
                cell.teacherPicture.isHidden = false
                cell.teacherPicture.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
            } else {
                cell.teacherPicture.image = nil
                cell.teacherPicture.isHidden = true
                cell.placeHolderNameLbl.isHidden = false
                let fullName = (dataModel.full_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let words = fullName.split(separator: " ")
                let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                cell.placeHolderNameLbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
            }
            
            cell.callBtn.tag = indexPath.row
            cell.callBtn.addTarget(self, action: #selector(self.callBtnTapped(sender:)), for: .touchUpInside)
            
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
    @objc func callBtnTapped(sender: UIButton!) {
        let dataModel = teachersArray[(sender as AnyObject).tag]
        
        let mobile = dataModel.mobile?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if mobile.isEmpty {
            self.showAnimatedToast(message: "Mobile number not available", type: .warning)
            return
        }

        let alert = UIAlertController(title: "Call", message: mobile, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { _ in
            if let url = URL(string: "tel://\(mobile)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))

        self.present(alert, animated: true)
       
    }

}
// MARK: - UITableViewDataSource
extension TeachersListVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
            return "TeachersTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
