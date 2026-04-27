//
//  HolidaysVC.swift
//  KliqEdu
//
//  Created by codegama on 10/04/26.
//

import UIKit

class HolidaysVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dateArray = [
        "01","14","26",
        "15",
        "04","21","26","31",
        "03","14","15",
        "01","27",
        "26",
        "15","28",
        "04","14",
        "02","20",
        "08","24",
        "25"
    ]

    var monthArray = [
        "Jan","Jan","Jan",
        "Feb",
        "Mar","Mar","Mar","Mar",
        "Apr","Apr","Apr",
        "May","May",
        "Jun",
        "Aug","Aug",
        "Sep","Sep",
        "Oct","Oct",
        "Nov","Nov",
        "Dec"
    ]

    var titleArray = [
        "New Year",
        "Pongal / Makar Sankranti",
        "Republic Day",

        "Maha Shivaratri",

        "Holi",
        "Eid-ul-Fitr",
        "Ram Navami",
        "Mahavir Jayanti",

        "Good Friday",
        "Ambedkar Jayanti",
        "Bihu",

        "Labour Day",
        "Bakrid",

        "Muharram",

        "Independence Day",
        "Raksha Bandhan",

        "Janmashtami",
        "Ganesh Chaturthi",

        "Gandhi Jayanti",
        "Dussehra",

        "Diwali",
        "Guru Nanak Jayanti",

        "Christmas"
    ]

    var dayArray = [
        "Thursday","Wednesday","Monday",
        "Sunday",
        "Wednesday","Saturday","Thursday","Tuesday",
        "Friday","Tuesday","Wednesday",
        "Friday","Wednesday",
        "Friday",
        "Saturday","Friday",
        "Friday","Monday",
        "Friday","Tuesday",
        "Saturday","Tuesday",
        "Friday"
    ]

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
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 23
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      //  let dataModel = bankArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HolidaysCell", for: indexPath as IndexPath) as? HolidaysCell {
            cell.dateLbl.text = dateArray[indexPath.row]
            cell.monthLbl.text = monthArray[indexPath.row]
            cell.titleLbl.text = titleArray[indexPath.row]
            cell.dayLbl.text = dayArray[indexPath.row]

            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
   

}
