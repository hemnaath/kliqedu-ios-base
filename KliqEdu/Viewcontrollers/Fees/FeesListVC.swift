//
//  FeesListVC.swift
//  KliqEdu
//
//  Created by codegama on 19/04/26.
//

import UIKit

class FeesListVC: UIViewController , UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var filterView: UIView!
    
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var titleArray = [
        "Tutition fees for 2025-26",
        "Transport fee",
        "Library and lab fee",
        "Extracurricular fee",
        "Other fee"]

    var amountArray = [
        "₹ 55,000",
        "₹ 10,000",
        "₹ 1,000",
        "₹ 10,000",
        "₹ 8,000"
        ]
    var statusArray = ["Paid","Unpaid","Paid","Unpaid","Paid"]
    var dueArray = ["Paid date:","Due date:","Paid date:","Due date:","Paid date:"]

    // 🟠 Pending, 🟢 Approved, 🔴 Rejected
    var statusTitleColor = [
        UIColor.systemGreen, UIColor.systemRed.withAlphaComponent(0.7),
        UIColor.systemGreen, UIColor.systemRed.withAlphaComponent(0.7),
        UIColor.systemGreen]

    // Light background versions
    var statusBgcolor = [
        UIColor.systemGreen.withAlphaComponent(0.1),
        UIColor.systemRed.withAlphaComponent(0.1),
        
        UIColor.systemGreen.withAlphaComponent(0.1),
        UIColor.systemRed.withAlphaComponent(0.1),
        
        UIColor.systemGreen.withAlphaComponent(0.1),
        ]
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false

        self.filterView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "FeesTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FeesTCell")
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func filterBtnTapped(_ sender: Any) {
        self.filterView.isHidden = false

    }
    
    @IBAction func filterCloseBtnTapped(_ sender: Any) {
        self.filterView.isHidden = true

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      //  let dataModel = bankArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeesTCell", for: indexPath as IndexPath) as? FeesTCell {
            // cell.studentPic.image = UIImage(named: imageArray[indexPath.row])
            cell.titleLbl.text = titleArray[indexPath.row]
            cell.statusLbl.text = "  \(statusArray[indexPath.row])  "
            cell.statusLbl.backgroundColor = statusBgcolor[indexPath.row]
            cell.statusLbl.textColor = statusTitleColor[indexPath.row]
            cell.dueLbl.text = dueArray[indexPath.row]
            cell.amtLbl.text = amountArray[indexPath.row]
            cell.statusView.backgroundColor = statusBgcolor[indexPath.row]
            
            let status = statusArray[indexPath.row]
            if status == "Paid" {

                cell.statusImage.image = UIImage(systemName: "checkmark.circle.fill")

                cell.statusImage.tintColor = .systemGreen

            } else {

                cell.statusImage.image = UIImage(systemName: "xmark.circle.fill")

                cell.statusImage.tintColor = .systemRed.withAlphaComponent(0.7)

            }
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
        if let vc = sb.instantiateViewController(withIdentifier: "FeesDetailsVC") as? FeesDetailsVC {
            
//            vc.bankId = dataModel.unique_id ?? ""
//            vc.accStatus = dataModel.status_formatted ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
