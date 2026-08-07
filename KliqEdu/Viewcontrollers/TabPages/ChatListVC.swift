//
//  ChatListVC.swift
//  KliqEdu
//
//  Created by codegama on 13/07/26.
//

import UIKit

class ChatListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var startChatBtn: UIButton!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var allChatsBtn: UIButton!
    @IBOutlet weak var othersBtn: UIButton!
    
    var chatArray = ["Ramesh","Priya","Hema","Ragul","Karthick","Vishnu kumar jeevan","Monisha"]
    var subjectArray = ["Science","Maths","English","Hindi","Maths","English","Hindi"]
    var msgArray = ["Hi Mam","Please note the homework","Bye...","Welcome sir","Good morning","Life","Basics"]
    
    var gradeArray = ["Grade 10","Grade 9","Grade 8","Grade 5","Grade 3","Grade 4","Grade 10"]
    var selectedTeacherIndex: Int?
    var chatSection = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.applyDefaultStyle(placeholder: "Search by name")
        tableView.delegate = self
        tableView.dataSource = self
        self.emptyView.isHidden = true
        let nib = UINib(nibName: "ChatListTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ChatListTCell")
        
        let nib1 = UINib(nibName: "SelectTeacherTCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "SelectTeacherTCell")
        self.startChatBtn.hide()
        tableViewBottom.constant = 0

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func allChatsBtnTapped(_ sender: Any) {
        allChatsBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        othersBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        chatSection = "all"
        selectedTeacherIndex = nil
        tableView.reloadData()
        self.startChatBtn.hide()
        tableViewBottom.constant = 0
    }
    @IBAction func othersBtnTapped(_ sender: Any) {
        allChatsBtn.setTitleAndBgColor(titleColor: .darkGray, bgColor: .clear)
        othersBtn.setTitleAndBgColor(titleColor: .white, bgColor: .theme)
        chatSection = "teacher"
        selectedTeacherIndex = nil
        tableView.reloadData()
        self.startChatBtn.unhide()
        tableViewBottom.constant = 100
    }
    @IBAction func startChatBtnTapped(_ sender: Any) {
        guard chatSection == "teacher", selectedTeacherIndex != nil else { return }

        let sb = UIStoryboard(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chatSection == "teacher" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTeacherTCell", for: indexPath) as! SelectTeacherTCell
            cell.nameLbl.text = chatArray[indexPath.row]
            cell.subjectLbl.text = subjectArray[indexPath.row]
            cell.msgLbl.text = gradeArray[indexPath.row]

            let selected = selectedTeacherIndex == indexPath.row
            let imageName = selected ? "largecircle.fill.circle" : "circle"
            cell.checkBoxBtn.setImage(UIImage(systemName: imageName), for: .normal)
            cell.checkBoxBtn.tintColor = .theme
            cell.selectionStyle = .none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTCell", for: indexPath) as! ChatListTCell
        cell.nameLbl.text = chatArray[indexPath.row]
        cell.subjectLbl.text = subjectArray[indexPath.row]
        cell.msgLbl.text = msgArray[indexPath.row]
        cell.dateLbl.text = "09:30 AM"
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if chatSection == "teacher" {
            selectedTeacherIndex = indexPath.row
            tableView.reloadData()
            return
        }

        let sb = UIStoryboard(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
