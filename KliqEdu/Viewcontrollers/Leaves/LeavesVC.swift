//
//  LeavesVC.swift
//  KliqEdu
//
//  Created by codegama on 06/04/26.
//

import UIKit
import SkeletonView

class LeavesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //  @IBOutlet weak var emptyView: UIView!
      @IBOutlet weak var filterOuterView: UIView!
      @IBOutlet weak var tableView: UITableView!
      @IBOutlet weak var filterBtn: UIButton!
    
    @IBOutlet weak var addLeaveBtn: UIButton!
    @IBOutlet weak var myLeavesBtn: UIButton!
    @IBOutlet weak var studentLeaveBtn: UIButton!
    
    //  var studentsArray = [BankDetailsModel]()
      var timer = Timer()
      var imageArray = ["s1","s2","s3","s4","s5","s1","s2","s3","s4","s5"]
    var statusArray = ["Pending","Approved","Rejected","Pending","Approved","Rejected","Pending","Approved","Rejected","Approved"]

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
    
      override func viewDidLoad() {
          super.viewDidLoad()
          self.tabBarController?.tabBar.isHidden = false
          self.navigationController?.isNavigationBarHidden = true

          self.view.applyVerticalLigtGradient()
          addLeaveBtn.dropShadow()
          
          tableView.delegate = self
          tableView.dataSource = self
          self.filterOuterView.isHidden = true
          //self.emptyView.isHidden = true
          let nib = UINib(nibName: "LeaveTCell", bundle: nil)
          tableView.register(nib, forCellReuseIdentifier: "LeaveTCell")
          
          studentLeaveBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
          myLeavesBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
          
          
      }
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          
  //        tableView.isSkeletonable = true
  //        self.tableView.showAnimatedGradientSkeleton()
          
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
          self.filterOuterView.isHidden = false
      }
      
      @IBAction func filterCloseTapped(_ sender: Any) {
          self.filterOuterView.isHidden = true
      }
    @IBAction func studentLeaveBtnTapped(_ sender: Any) {
        studentLeaveBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        myLeavesBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        
    }
    @IBAction func myLeaveBtnTapped(_ sender: Any) {
        studentLeaveBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        myLeavesBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          
          return 10
      }
     
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
        //  let dataModel = bankArray[indexPath.row]
          if let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveTCell", for: indexPath as IndexPath) as? LeaveTCell {
              cell.leaveImg.image = UIImage(named: imageArray[indexPath.row])
              cell.statusLbl.text = statusArray[indexPath.row]
              cell.statusLbl.backgroundColor = statusBgcolor[indexPath.row]
              cell.statusLbl.textColor = statusTitleColor[indexPath.row]
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
          if let vc = sb.instantiateViewController(withIdentifier: "LeaveViewVC") as? LeaveViewVC {
              
  //            vc.bankId = dataModel.unique_id ?? ""
  //            vc.accStatus = dataModel.status_formatted ?? ""
              vc.hidesBottomBarWhenPushed = true
              self.navigationController?.pushViewController(vc, animated: true)
          }
      }
  }
