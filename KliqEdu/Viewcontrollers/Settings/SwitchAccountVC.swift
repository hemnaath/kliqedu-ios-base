//
//  SwitchAccountVC.swift
//  KliqEdu
//
//  Created by codegama on 01/05/26.
//

import UIKit
import SkeletonView
import SDWebImage

class SwitchAccountVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var onDismiss: (() -> Void)?
    var onDismiss1: (() -> Void)?
    var childrensArr: [ChildrensModel] = []
    var selectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        loadChildrenData()
        
        let nib = UINib(nibName: "ChildrensTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ChildrensTCell")
        
        self.delay(bySeconds: 0.25) { [weak self] in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.5)
            }
        }
    }
    
    func loadChildrenData() {
        if let data = UserDefaults.standard.data(forKey: Constants.Keys.childrenArrayKey),
           let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            
            childrensArr = ChildrensModel.modelsFromDictionaryArray(array: array as NSArray)

            let selectedUniqueId = UserDefaults.standard.string(forKey: Constants.Keys.userUniqueIdKey) ?? ""

            if let index = childrensArr.firstIndex(where: { $0.unique_id == selectedUniqueId }) {
                selectedIndex = index
            }

            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childrensArr.count
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 90
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChildrensTCell", for: indexPath) as! ChildrensTCell
        
        let dataModel = childrensArr[indexPath.row]
        
        cell.nameLbl.text = "\((dataModel.firstname ?? "").firstUppercased) \((dataModel.lastname ?? "").firstUppercased)"
        cell.gradeLbl.text = "Grade: \(dataModel.roll_number ?? "")"
        let imageURL = (dataModel.picture ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if !imageURL.isEmpty {
            cell.placeHolderlbl.isHidden = true
            cell.studentPicture.isHidden = false
            cell.studentPicture.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
        } else {
            cell.studentPicture.image = nil
            cell.studentPicture.isHidden = true
            cell.placeHolderlbl.isHidden = false
            
            let fullName1 = "\(dataModel.firstname ?? "") \(dataModel.lastname ?? "")"
            let fullName = (fullName1).trimmingCharacters(in: .whitespacesAndNewlines)
            let words = fullName.split(separator: " ")
            let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
            let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
            cell.placeHolderlbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
        }
        let imageName = selectedIndex == indexPath.row ? "largecircle.fill.circle" : "circle"
        cell.radioBtn.setImage(UIImage(systemName: imageName), for: .normal)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.onDismiss1?()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss1?()
    }
    @IBAction func switchTapped(_ sender: Any) {
        let selectedStudent = childrensArr[selectedIndex]
        
        UserDefaults.standard.set(selectedStudent.unique_id ?? "", forKey: Constants.Keys.userUniqueIdKey)
        UserDefaults.standard.synchronize()
        
        self.dismiss(animated: true) {
            self.onDismiss?()
        }
    }
}
// MARK: - UITableViewDataSource
extension SwitchAccountVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        
        return "ChildrensTCell"
        
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 2
    }
}
