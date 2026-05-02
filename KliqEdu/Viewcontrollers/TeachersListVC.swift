//
//  TeachersListVC.swift
//  KliqEdu
//
//  Created by codegama on 28/04/26.
//

import UIKit

class TeachersListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var imageArray = ["t1","t2","t3","t4","t5","t1","t2","t3","t4","t5"]
    var teachersNameArray = ["Annie Johnson","John Smith","Katherin Michel","Miller david","Ken Thomson","Annie Johnson","John Smith","Katherin Michel","Miller david","Ken Thomson"]
    
    var subjectArray = [
        "Mathematics",
        "English",
        "Science",
        "Social Studies",
        "Geography",
        "English",
        "Mathematics",
        "Science",
        "English",
        "Mathematics"
    ]
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
        searchBar.applyDefaultStyle(placeholder: "Search by name")
        
        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "TeachersTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TeachersTCell")
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TeachersTCell", for: indexPath as IndexPath) as? TeachersTCell {
            cell.teacherPicture.image = UIImage(named: imageArray[indexPath.row])
            cell.nameLbl.text = teachersNameArray[indexPath.row]
            cell.subjectLbl.text = "  \(subjectArray[indexPath.row])  "
            let subject = subjectArray[indexPath.row]
            let color = subjectColorMap[subject] ?? .black
            cell.subjectLbl.textColor = color
            cell.subjectLbl.backgroundColor = subjectBgColorMap[subject]
            
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
    
}
