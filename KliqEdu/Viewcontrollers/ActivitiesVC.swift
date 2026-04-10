//
//  ActivitiesVC.swift
//  KliqEdu
//
//  Created by codegama on 27/03/26.
//

import UIKit

class ActivitiesVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        self.view.applyVerticalLigtGradient()
        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "NotificationsTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NotificationsTCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      //  let dataModel = bankArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTCell", for: indexPath as IndexPath) as? NotificationsTCell {
           // cell.studentPic.image = UIImage(named: imageArray[indexPath.row])

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
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }

}
