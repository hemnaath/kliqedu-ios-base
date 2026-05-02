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
      @IBOutlet weak var tableView: UITableView!
      @IBOutlet weak var filterBtn: UIButton!
    
    @IBOutlet weak var addLeaveBtn: UIButton!
    @IBOutlet weak var myLeavesBtn: UIButton!
    @IBOutlet weak var studentLeaveBtn: UIButton!
    
    //  var studentsArray = [BankDetailsModel]()
      var timer = Timer()
      var imageArray = ["s1","s2","s3","s4","s5","s1","s2","s3","s4","s5"]
    var catgImgArray = ["medicalBox","personalLeave","trip","mother","other","medicalBox","personalLeave","trip","mother","other"]

    var statusArray = ["Pending","Approved","Rejected","Pending","Approved","Rejected","Pending","Approved","Rejected","Approved"]
    
    var leaveCategory = ["Sick leave","Personal Leave","Vacation Leave","Casual leave","Other Leave","Sick leave","Personal Leave","Vacation Leave","Casual leave","Other Leave"]

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
    }
    @IBAction func myLeaveBtnTapped(_ sender: Any) {
        studentLeaveBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        myLeavesBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        leaveSection = "teacher"
        tableView.reloadData()

    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          
          return 10
      }
     
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
          if leaveSection == "student" {
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
          }else{
              if let cell = tableView.dequeueReusableCell(withIdentifier: "TeacherLeaveTCell", for: indexPath as IndexPath) as? TeacherLeaveTCell {
                    cell.categoryImage.image = UIImage(named: catgImgArray[indexPath.row])
                  cell.categoryImage.tintColor = statusTitleColor[indexPath.row]

                  cell.categoryOuterView.backgroundColor = statusBgcolor[indexPath.row]
                    cell.statusLbl.text = statusArray[indexPath.row]
                    cell.statusLbl.backgroundColor = statusBgcolor[indexPath.row]
                    cell.statusLbl.textColor = statusTitleColor[indexPath.row]
                    cell.categoryLbl.text = leaveCategory[indexPath.row]
                  
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
