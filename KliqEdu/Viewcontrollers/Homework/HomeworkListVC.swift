//
//  HomeworkListVC.swift
//  KliqEdu
//
//  Created by codegama on 13/04/26.
//

import UIKit
import SkeletonView
import CRRefresh
import Alamofire
import SwiftyJSON
import SDWebImage

struct DateModel {
    
    var dayName: String
    var date: String
    var fullDate: Date
    var isSelected: Bool
}
class HomeworkListVC: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var createHomeworkBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //@IBOutlet weak var bgView: UIView!
    
    // MARK: - Variables
    
    var dateArray = [DateModel]()
    
    var homeworkArray = [HomeWorkModel]()
    var timer = Timer()
    var selectedDate = Date()
    var filters: [String: Any] = [:]

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
        
        createHomeworkBtn.dropShadow()
        
        self.view.applyVerticalLigtGradient()
        tableView.delegate = self
        tableView.dataSource = self
        //self.emptyView.isHidden = true
        let nib = UINib(nibName: "HomeworkTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HomeworkTCell")
        
        /// Pull to refresh
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            // start refresh
            
            print("refresh")
            self?.getHomeworkData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        setupUI()
        
        generateCurrentMonthDates()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()
        getHomeworkData()
        if roleKey == "parent"{
            self.addBtn.isHidden = true
            self.filterBtn.isHidden = true
        }else{
            self.addBtn.isHidden = false
            self.filterBtn.isHidden = false

        }
        self.emptyView.isHidden = true
    }
    
    @IBAction func createHomeworkTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "AddHomeworkVC") as? AddHomeworkVC {
            
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
            vc.comingFor = "Homework"
            vc.appliedFilters = self.filters
            vc.onDismiss = { [weak self] in
                   self?.tabBarController?.tabBar.isHidden = false
               }
            vc.onApplyFilter = { filters in
                
                print(filters)
        
                self.filters = filters
                
                self.getHomeworkData()

            }
            present(vc, animated: true)
        }
    }
    func getHomeworkData() {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let selectedDateString = formatter.string(from: selectedDate)

        if roleKey == "teacher"{
            let param = ["date": selectedDateString,"grade_id": filters["grade_id"] ?? ""] as [String : Any]
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)

            self.callServiceMethod(service: Constants.Urls.teacherHomeworkListUrl, method: .post, params: param, key: "HomeworkUrl", headers: headers)
        }else{
            let param = ["date": selectedDateString] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list",params: param,HTTPMethod: .post)
            self.callServiceMethod(service: Constants.Urls.parentHomeworkUrl, method: .post, params: param, key: "HomeworkUrl", headers: headers)
            
        }
    }
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
      
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "HomeworkUrl"{
                        
                        //  let resDataDic = result?["data"] as? NSDictionary
                        
                        self.tableView.hideSkeleton()
                        
                        let listArray = result?["data"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                            self.homeworkArray.removeAll()
                        
                        for item in listArray {
                            if let model = HomeWorkModel(dictionary: item as NSDictionary) {
                                self.homeworkArray.append(model)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if self.homeworkArray.count > 0 {
                                self.tableView.isHidden = false
                                self.emptyView.isHidden = true
                                
                            } else {
                                
                                self.tableView.isHidden = true
                                self.emptyView.isHidden = false
                                
                            }
                            self.tableView.reloadData()
                            
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
                    self.emptyView.isHidden = false
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  homeworkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataModel = homeworkArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTCell", for: indexPath as IndexPath) as? HomeworkTCell {
            // cell.studentPic.image = UIImage(named: imageArray[indexPath.row])
            cell.titleLbl.text = dataModel.title
            cell.subjectLbl.text = "  \(dataModel.subject ?? "")  "
            let subjects = Array(subjectColorMap.keys).sorted()
            let subject = subjects[indexPath.row % subjects.count]
            let color = subjectColorMap[subject] ?? .black
            cell.subjectLbl.textColor = color
            cell.subjectLbl.backgroundColor = subjectBgColorMap[subject]
            cell.gradelbl.text = "  Grade \(dataModel.grade ?? "") \(dataModel.section ?? "")  "
            cell.dateLbl.text = dataModel.created_at
            
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else {
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataModel = homeworkArray[indexPath.row]
        //
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "HomeworkViewVC") as? HomeworkViewVC {
            
            vc.homeworkDetails = dataModel
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
// MARK: - UITableViewDataSource
extension HomeworkListVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        
        return "HomeworkTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
}
// MARK: - UICollectionView Delegate

extension HomeworkListVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    // MARK: - Setup UI
    
    func setupUI() {
        //  bgView.layer.cornerRadius = 20
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
        }
        collectionView.showsHorizontalScrollIndicator = false
        // Removed monthLbl.text setting; now handled in generateCurrentMonthDates()
    }
    // MARK: - Generate Dates
    func generateCurrentMonthDates() {

        dateArray.removeAll()

        let calendar = Calendar.current

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let startDate = formatter.date(from: "2026-06-01"),
              let endDate = formatter.date(from: "2027-04-30") else {
            return
        }

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"

        var currentDate = startDate
        let today = Date()

        while currentDate <= endDate {

            let dayName = String(dayFormatter.string(from: currentDate).prefix(1))
            let dateString = dateFormatter.string(from: currentDate)

            let isToday = calendar.isDate(currentDate, inSameDayAs: today)

            dateArray.append(DateModel(
                dayName: dayName,
                date: dateString,
                fullDate: currentDate,
                isSelected: isToday
            ))

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        if let todayIndex = dateArray.firstIndex(where: { $0.isSelected }) {
            selectedDate = dateArray[todayIndex].fullDate
        } else if !dateArray.isEmpty {
            dateArray[0].isSelected = true
            selectedDate = dateArray[0].fullDate
        }

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        monthLbl.text = monthFormatter.string(from: selectedDate)

        collectionView.reloadData()

        if let selectedIndex = dateArray.firstIndex(where: { $0.isSelected }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionView.scrollToItem(
                    at: IndexPath(item: selectedIndex, section: 0),
                    at: .centeredHorizontally,
                    animated: false
                )
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        
        return dateArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCCell",for: indexPath) as! DateCCell
        
        let dataModel = dateArray[indexPath.row]

        cell.dayLbl.text = dataModel.dayName
        cell.dateLbl.text = dataModel.date
        
        if dataModel.isSelected {
            
            cell.bgView.backgroundColor = .themeColor
            cell.dayLbl.textColor = .white
            cell.dateLbl.textColor = .white
            
        } else {
            
            cell.bgView.backgroundColor = .clear
            cell.dayLbl.textColor = .darkGray
            cell.dateLbl.textColor = .black
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,didSelectItemAt indexPath: IndexPath) {
        for index in 0..<dateArray.count {
            dateArray[index].isSelected = false
        }
        dateArray[indexPath.row].isSelected = true

        self.selectedDate = dateArray[indexPath.row].fullDate

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLbl.text = formatter.string(from: self.selectedDate)

        collectionView.reloadData()

        self.emptyView.isHidden = true
        self.tableView.isHidden = false

        // Clear old data so skeleton is visible
        self.homeworkArray.removeAll()
        self.tableView.reloadData()

        self.tableView.isSkeletonable = true
        self.tableView.showAnimatedGradientSkeleton()

        DispatchQueue.main.async {
            self.getHomeworkData()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateMonthLabel()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateMonthLabel()
        }
    }

    private func updateMonthLabel() {
        let visibleItems = collectionView.indexPathsForVisibleItems.sorted { $0.item < $1.item }
        let middlePosition = visibleItems.count / 2
        guard visibleItems.indices.contains(middlePosition) else { return }
        let middleIndex = visibleItems[middlePosition]
        let visibleDate = dateArray[middleIndex.item].fullDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLbl.text = formatter.string(from: visibleDate)
    }
}

   
