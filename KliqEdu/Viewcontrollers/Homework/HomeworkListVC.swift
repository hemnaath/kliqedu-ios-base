//
//  HomeworkListVC.swift
//  KliqEdu
//
//  Created by codegama on 13/04/26.
//

import UIKit

class HomeworkListVC: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var createHomeworkBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var titleArray = [
        "Complete algebra worksheet on linear equations",
        "Read chapter 5 and write summary notes",
        "Practice grammar exercises from workbook",
        "Solve word problems on fractions and decimals",
        "Prepare diagram of human respiratory system",
        "Write essay on climate change and its impact",
        "Revise multiplication tables and basic concepts",
        "Draw and label parts of plant cell neatly",
        "Practice past tense verbs and sentence formation",
        "Complete map work on Indian states and capitals"
    ]

    var gradeArray = [
        "Grade 6A",
        "Grade 7B",
        "Grade 5A",
        "Grade 6C",
        "Grade 8D",
        "Grade 6A",
        "Grade 7B",
        "Grade 5A",
        "Grade 6C",
        "Grade 8D"
    ]

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
    
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        searchBar.applyDefaultStyle(placeholder: "Search")
        createHomeworkBtn.dropShadow()

        self.view.applyVerticalLigtGradient()
        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "HomeworkTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HomeworkTCell")
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func createHomeworkTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "AddHomeworkVC") as? AddHomeworkVC {
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      //  let dataModel = bankArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTCell", for: indexPath as IndexPath) as? HomeworkTCell {
            // cell.studentPic.image = UIImage(named: imageArray[indexPath.row])
            cell.titleLbl.text = titleArray[indexPath.row]
            cell.subjectLbl.text = "  \(subjectArray[indexPath.row])  "
            let subject = subjectArray[indexPath.row]
            let color = subjectColorMap[subject] ?? .black
            cell.subjectLbl.textColor = color
            cell.subjectLbl.backgroundColor = subjectBgColorMap[subject]
            cell.gradelbl.text = gradeArray[indexPath.row]
            
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
        if let vc = sb.instantiateViewController(withIdentifier: "HomeworkViewVC") as? HomeworkViewVC {
            
//            vc.bankId = dataModel.unique_id ?? ""
//            vc.accStatus = dataModel.status_formatted ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
