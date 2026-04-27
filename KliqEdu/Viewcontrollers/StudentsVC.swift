//
//  StudentsVC.swift
//  KliqEdu
//
//  Created by codegama on 27/03/26.
//

import UIKit
import SkeletonView

class StudentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

  //  @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var filterOuterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterBtn: UIButton!
    
  //  var studentsArray = [BankDetailsModel]()
    var timer = Timer()
    var imageArray = ["s1","s2","s3","s4","s5","s1","s2","s3","s4","s5"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true

        self.view.applyVerticalLigtGradient()
        searchBar.applyDefaultStyle(placeholder: "Search by name or ID")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.filterOuterView.isHidden = true
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "StudentListTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StudentListTCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        tableView.isSkeletonable = true
//        self.tableView.showAnimatedGradientSkeleton()
        
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func filterBtnTapped(_ sender: Any) {
        self.filterOuterView.isHidden = false
    }
    
    @IBAction func filterCloseTapped(_ sender: Any) {
        self.filterOuterView.isHidden = true
    }
    @IBAction func homeTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "HomeworkListVC") as? HomeworkListVC {
            
//            vc.bankId = dataModel.unique_id ?? ""
//            vc.accStatus = dataModel.status_formatted ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func settingsTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC {
            
//            vc.bankId = dataModel.unique_id ?? ""
//            vc.accStatus = dataModel.status_formatted ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      //  let dataModel = bankArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StudentListTCell", for: indexPath as IndexPath) as? StudentListTCell {
            cell.studentPic.image = UIImage(named: imageArray[indexPath.row])

            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let dataModel = bankArray[indexPath.row]
//        
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "StudentInfoVC") as? StudentInfoVC {
            
//            vc.bankId = dataModel.unique_id ?? ""
//            vc.accStatus = dataModel.status_formatted ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
