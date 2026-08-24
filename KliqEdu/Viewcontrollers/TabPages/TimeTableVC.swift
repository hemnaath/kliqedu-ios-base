//
//  TimeTableVC.swift
//  KliqEdu
//
//  Created by codegama on 06/08/26.
//

import UIKit
import SkeletonView
import Alamofire
import SwiftyJSON

class TimeTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sat: UIButton!
    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tue: UIButton!
    @IBOutlet weak var wed: UIButton!
    @IBOutlet weak var thu: UIButton!
    @IBOutlet weak var fri: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    struct TimeTableCellModel {
        let periodNo: String
        let subject: String
        let teacher: String
        let class_name: String
        let time: String
        let intervalTime: String
        let isBreak: Bool
    }

    var timeTableArray: [TimeTableCellModel] = []
    var allDaysData: [[String: Any]] = []
    
    var timeTableArray1 = [TimeTableModel]()

    var subjectColorMap: [String: UIColor] = [:]

    let subjectColorPalette: [UIColor] = [
        .systemBlue,
        .systemGreen,
        .systemPink,
        .systemPurple,
        .systemTeal,
        .systemOrange,
        .systemIndigo,
        .systemRed,
        .systemMint,
        .systemCyan,
        .systemBrown
    ]

    func setupSubjectColors() {
        subjectColorMap.removeAll()

        var subjectIndex = 0

        for dayData in allDaysData {

            let cells = dayData["cells"] as? [[String: Any]] ?? []

            for item in cells {

                let type = item["type"] as? String ?? ""

                // Ignore break periods
                if type == "break" {
                    continue
                }

                let subject = (item["subject"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if subject.isEmpty {
                    continue
                }

                let key = subject.lowercased()

                // Only assign a color if this subject doesn't already have one
                if subjectColorMap[key] == nil {

                    subjectColorMap[key] =
                        subjectColorPalette[subjectIndex % subjectColorPalette.count]

                    subjectIndex += 1
                }
            }
        }
    }

    func colorForSubject(_ subject: String) -> UIColor {

        let key = subject
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return subjectColorMap[key] ?? .systemBlue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "TimeTableTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TimeTableTCell")
        
        sat.isHidden = true
        selectCurrentDay()
        getTimetableData()
    }
    
    func getTimetableData() {
        
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
                
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/get",params: param, HTTPMethod: .get)
        
        if roleKey == "teacher"{
            
            self.callServiceMethod(service: Constants.Urls.teacherTimetableUrl, method: .get, params: param, key: "TimetableUrl", headers: headers)
        }else{
            self.callServiceMethod(service: Constants.Urls.studentTimetableUrl, method: .get, params: param, key: "TimetableUrl", headers: headers)

        }
    }
    func loadDay(_ day: String) {

        timeTableArray.removeAll()

        setupSubjectColors()

        guard let dayData = allDaysData.first(where: {
            ($0["day"] as? String) == day
        }) else {
            tableView.reloadData()
            return
        }

        let cells = dayData["cells"] as? [[String: Any]] ?? []

        for item in cells {

            let type = item["type"] as? String ?? ""

            if type == "break" {

                let duration = item["duration_minutes"] as? Int ?? 0
                let start = item["start_time"] as? String ?? ""
                let end = item["end_time"] as? String ?? ""
                
                let model = TimeTableCellModel(
                    periodNo: "",
                    subject: item["name"] as? String ?? "Break",
                    teacher: "\(formatTime(start)) - \(formatTime(end))",
                    class_name: "",
                    time: "",
                    intervalTime: "\(duration) min",
                    isBreak: true
                )

                timeTableArray.append(model)

            } else {

                let start = item["start_time"] as? String ?? ""
                let end = item["end_time"] as? String ?? ""
                let class_name = item["class_name"] as? String ?? ""
                let duration = durationInMinutes(start: start, end: end)

                let model = TimeTableCellModel(
                    periodNo: "\(item["period_number"] as? Int ?? 0)",
                    subject: item["subject"] as? String ?? "Free Period",
                    teacher: item["teacher"] as? String ?? "-",
                    class_name: class_name,
                    time: "\(formatTime(start)) - \(formatTime(end))",
                    intervalTime: "\(duration) min",
                    isBreak: false
                )
                
                timeTableArray.append(model)
            }
        }

        tableView.reloadData()
    }
    func durationInMinutes(start: String, end: String) -> Int {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let startDate = formatter.date(from: start),
              let endDate = formatter.date(from: end) else {
            return 0
        }

        return max(0, Int(endDate.timeIntervalSince(startDate) / 60))
    }
    func formatTime(_ value: String) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let date = formatter.date(from: value) else {
            return value
        }

        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
      
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "TimetableUrl" {

                        self.tableView.hideSkeleton()

                        if let data = result?["data"] as? [String: Any] {

                            self.allDaysData = data["grid_rows"] as? [[String: Any]] ?? []

                            let hasSaturday = self.allDaysData.contains {
                                ($0["day"] as? String)?.caseInsensitiveCompare("Saturday") == .orderedSame
                            }

                            self.sat.isHidden = !hasSaturday

                            self.selectCurrentDay()

                            DispatchQueue.main.async {
                                self.tableView.isHidden = self.allDaysData.isEmpty
                                self.tableView.reloadData()
                            }

                        } else {

                            self.sat.isHidden = true
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                if errorCode == 217{
                    self.tableView.isHidden = true
                    //self.emptyView.isHidden = false
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
    
    func selectCurrentDay() {

        let weekday = Calendar.current.component(.weekday, from: Date())

        switch weekday {

        case 2:
            selectDay(monday)
            loadDay("Monday")

        case 3:
            selectDay(tue)
            loadDay("Tuesday")

        case 4:
            selectDay(wed)
            loadDay("Wednesday")

        case 5:
            selectDay(thu)
            loadDay("Thursday")

        case 6:
            selectDay(fri)
            loadDay("Friday")

        case 7:
            if !sat.isHidden {
                selectDay(sat)
                loadDay("Saturday")
            } else {
                selectDay(monday)
                loadDay("Monday")
            }

        default:
            selectDay(monday)
            loadDay("Monday")
        }
    }
    // MARK: - Day Selection

    func resetDayButtons() {

        let buttons = [monday, tue, wed, thu, fri, sat]

        buttons.forEach { button in
            button?.backgroundColor = .white
            button?.setTitleColor(.darkGray, for: .normal)
            button?.layer.cornerRadius = 20
            button?.clipsToBounds = true
        }
    }

    func selectDay(_ button: UIButton) {

        resetDayButtons()

        button.backgroundColor = UIColor.themeColor // Theme color
        button.setTitleColor(.white, for: .normal)
    }
    @IBAction func dayButtonTapped(_ sender: UIButton) {

        selectDay(sender)

        if sender == monday {

            loadDay("Monday")

        } else if sender == tue {

            loadDay("Tuesday")

        } else if sender == wed {

            loadDay("Wednesday")

        } else if sender == thu {

            loadDay("Thursday")

        } else if sender == fri {

            loadDay("Friday")

        } else if sender == sat {

            loadDay("Saturday")
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeTableArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTableTCell", for: indexPath) as? TimeTableTCell else {
            return UITableViewCell()
        }

        let data = timeTableArray[indexPath.row]

        if data.isBreak {
            cell.periodNumberLbl.text = ""
            cell.teacherNameLbl.text = data.teacher
            cell.subjectLbl.text = data.subject
            cell.timeLbl.text = data.time
            cell.intervelTimeLbl.text = data.intervalTime

            cell.breakImage.unhide()

            cell.innerView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.5)
            cell.subjectLbl.textColor = .systemOrange
            cell.outerView.backgroundColor = UIColor(hex: "#FCF7F3")
            cell.outerView.setBorderProperties(borderColor: .orange, borderWidth: 0.0, cornerRadius: 18, masksToBounds: true)
            cell.breakImage.unhide()
            cell.breakImage.tintColor = .white
            cell.intervelTimeLbl.textColor = .systemOrange
            cell.intervelTimeLbl.backgroundColor =
            UIColor.systemOrange.withAlphaComponent(0.15)
            
            switch data.subject {

            case "Morning Break":
                cell.breakImage.image = UIImage(systemName: "sun.max.fill")

            case "Lunch Break":
                cell.breakImage.image = UIImage(systemName: "fork.knife.circle.fill")

            case "Evening Break":
                cell.breakImage.image = UIImage(systemName: "cup.and.saucer.fill")

            default:
                cell.breakImage.image = UIImage(systemName: "pause.circle.fill")
            }

           
        } else {
            
            cell.periodNumberLbl.text = data.periodNo
            cell.subjectLbl.text = data.subject
            if roleKey == "teacher"{
                cell.teacherNameLbl.text = "Grade \(data.class_name)"

            }else{
                cell.teacherNameLbl.text = data.teacher
            }
            cell.timeLbl.text = data.time
            cell.intervelTimeLbl.text = data.intervalTime

            cell.breakImage.hide()

            let subjectColor = colorForSubject(data.subject)

            cell.subjectLbl.textColor = subjectColor
            cell.intervelTimeLbl.textColor = subjectColor

            cell.innerView.backgroundColor =
                subjectColor.withAlphaComponent(0.70)

            cell.intervelTimeLbl.backgroundColor =
                subjectColor.withAlphaComponent(0.15)
        }

       
        cell.selectionStyle = .none

        return cell
    }
    
}
// MARK: - UITableViewDataSource
extension TimeTableVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            
            return "TimeTableTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
