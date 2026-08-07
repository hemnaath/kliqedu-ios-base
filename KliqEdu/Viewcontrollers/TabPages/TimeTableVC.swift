//
//  TimeTableVC.swift
//  KliqEdu
//
//  Created by codegama on 06/08/26.
//

import UIKit

class TimeTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tue: UIButton!
    @IBOutlet weak var wed: UIButton!
    @IBOutlet weak var thu: UIButton!
    @IBOutlet weak var fri: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    struct TimeTableModel {
        let periodNo: String
        let subject: String
        let teacher: String
        let time: String
        let intervalTime: String
        let isBreak: Bool
    }
    var timeTableArray: [TimeTableModel] = [

        TimeTableModel(
            periodNo: "01",
            subject: "Mathematics",
            teacher: "John",
            time: "08:30 AM - 09:15 AM",
            intervalTime: "45 min",
            isBreak: false
        ),

        TimeTableModel(
            periodNo: "02",
            subject: "English",
            teacher: "Mary",
            time: "09:15 AM - 10:00 AM",
            intervalTime: "45 min",
            isBreak: false
        ),

        // Morning Break
        TimeTableModel(
            periodNo: "",
            subject: "Morning Break",
            teacher: "10:00 AM - 10:15 AM",
            time: ".",
            intervalTime: "15 min",
            isBreak: true
        ),

        TimeTableModel(
            periodNo: "03",
            subject: "Science",
            teacher: "David",
            time: "10:15 AM - 11:00 AM",
            intervalTime: "45 min",
            isBreak: false
        ),

        TimeTableModel(
            periodNo: "04",
            subject: "Social Studies",
            teacher: "Peter",
            time: "11:00 AM - 11:45 AM",
            intervalTime: "45 min",
            isBreak: false
        ),

        // Lunch Break
        TimeTableModel(
            periodNo: "",
            subject: "Lunch Break",
            teacher: "11:45 AM - 12:30 PM",
            time: ".",
            intervalTime: "45 min",
            isBreak: true
        ),

        TimeTableModel(
            periodNo: "05",
            subject: "Geography",
            teacher: "Andrew",
            time: "12:30 PM - 01:15 PM",
            intervalTime: "45 min",
            isBreak: false
        ),

        TimeTableModel(
            periodNo: "06",
            subject: "English",
            teacher: "Stanley",
            time: "01:15 PM - 02:00 PM",
            intervalTime: "45 min",
            isBreak: false
        ),

        // Evening Break
        TimeTableModel(
            periodNo: "",
            subject: "Evening Break",
            teacher: "02:00 PM - 02:10 PM",
            time: ".",
            intervalTime: "10 min",
            isBreak: true
        ),

        TimeTableModel(
            periodNo: "07",
            subject: "Mathematics",
            teacher: "Siva",
            time: "02:10 PM - 02:55 PM",
            intervalTime: "45 min",
            isBreak: false
        ),

        TimeTableModel(
            periodNo: "08",
            subject: "Science",
            teacher: "Monisha",
            time: "02:55 PM - 03:40 PM",
            intervalTime: "45 min",
            isBreak: false
        )
    ]
    let subjectColorMap: [String: UIColor] = [
        "Mathematics": .systemBlue,
        "English": .systemGreen,
        "Science": .systemPink,
        "Social Studies": .systemPurple,
        "Geography": .systemTeal
    ]

    let subjectBgColorMap: [String: UIColor] = [
        "Mathematics": UIColor.systemBlue.withAlphaComponent(0.70),
        "English": UIColor.systemGreen.withAlphaComponent(0.70),
        "Science": UIColor.systemPink.withAlphaComponent(0.70),
        "Social Studies": UIColor.systemPurple.withAlphaComponent(0.70),
        "Geography": UIColor.systemTeal.withAlphaComponent(0.70)
    ]
    
    let subjectBgColorMap1: [String: UIColor] = [
        "Mathematics": UIColor.systemBlue.withAlphaComponent(0.15),
        "English": UIColor.systemGreen.withAlphaComponent(0.15),
        "Science": UIColor.systemPink.withAlphaComponent(0.15),
        "Social Studies": UIColor.systemPurple.withAlphaComponent(0.15),
        "Geography": UIColor.systemTeal.withAlphaComponent(0.15)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "TimeTableTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TimeTableTCell")
        
        selectCurrentDay()
    }
    func selectCurrentDay() {

        let weekday = Calendar.current.component(.weekday, from: Date())

        switch weekday {

        case 2: // Monday
            selectDay(monday)

        case 3: // Tuesday
            selectDay(tue)

        case 4: // Wednesday
            selectDay(wed)

        case 5: // Thursday
            selectDay(thu)

        case 6: // Friday
            selectDay(fri)

        default:
            // Saturday & Sunday -> Default to Monday
            selectDay(monday)
        }
    }
    // MARK: - Day Selection

    func resetDayButtons() {

        let buttons = [monday, tue, wed, thu, fri]

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

        // Load timetable based on selected day if needed
        switch sender {
        case monday:
            print("Monday")
        case tue:
            print("Tuesday")
        case wed:
            print("Wednesday")
        case thu:
            print("Thursday")
        case fri:
            print("Friday")
        default:
            break
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
            cell.outerView.backgroundColor = UIColor(hex: "#FCF7F3") // Recommended
            cell.outerView.setBorderProperties(borderColor: .orange, borderWidth: 0.0, cornerRadius: 18, masksToBounds: true)
            cell.breakImage.unhide()
            cell.breakImage.tintColor = .white
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
            cell.teacherNameLbl.text = data.teacher
            cell.timeLbl.text = data.time
            cell.intervelTimeLbl.text = data.intervalTime
            cell.breakImage.hide()
            
            cell.subjectLbl.textColor = subjectColorMap[data.subject] ?? .black
            cell.intervelTimeLbl.textColor = subjectColorMap[data.subject] ?? .black

            cell.innerView.backgroundColor = subjectBgColorMap[data.subject] ?? .clear
            cell.intervelTimeLbl.backgroundColor = subjectBgColorMap1[data.subject] ?? .clear

        }

       
        cell.selectionStyle = .none

        return cell
    }
    
}
