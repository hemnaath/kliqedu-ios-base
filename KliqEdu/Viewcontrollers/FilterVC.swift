//
//  FilterVC.swift
//  KliqEdu
//
//  Created by codegama on 01/05/26.
//

import UIKit

class FilterVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var gradeBadge: UILabel!
    @IBOutlet weak var sectionBadge: UILabel!
    @IBOutlet weak var statusBadge: UILabel!
    @IBOutlet weak var dateBadge: UILabel!

    @IBOutlet weak var gradeView: UIView!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var dateOuterView: UIStackView!
    
    @IBOutlet weak var gradeBtn: UIButton!
    @IBOutlet weak var sectionBtn: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    
    @IBOutlet weak var tablviewOuterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    
    // MARK: - Variables
    
    var selectedType = "Grade"
    
    let gradeArray = ["9th Std", "10th Std", "11th Std", "12th Std"]
    let sectionArray = ["A", "B", "C"]
    let statusArray = ["Pending", "Success", "Failed"]
    
    var selectedGrade = ""
    var selectedSection = ""
    var selectedStatus = ""
    var onDismiss: (() -> Void)?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.view.backgroundColor = .clear
        
        self.delay(bySeconds: 0.25) { [weak self] in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.5)
            }
        }
        tableView.separatorStyle = .none
        let nib = UINib(nibName: "FilterTCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FilterTCell")
        
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        
        updateButtons()
        
    }
    
    // MARK: - Update Button UI
    
    func updateButtons() {
        
        let buttons = [gradeBtn, sectionBtn, statusBtn, dateBtn]
        let buttonBgView = [gradeView, sectionView, statusView, dateView]

        buttons.forEach {
            $0?.setTitleColor(.black, for: .normal)
        }
        
        buttonBgView.forEach {
            $0?.backgroundColor = .themeLite
        }

        // Hide all badges first
        [gradeBadge, sectionBadge, statusBadge, dateBadge].forEach {
            $0?.isHidden = true
        }

        switch selectedType {
        case "Grade":
            gradeView.backgroundColor = .white
            gradeBadge.isHidden = false
            selectedButton(gradeBtn)
        case "Section":
            sectionView.backgroundColor = .white
            sectionBadge.isHidden = false
            selectedButton(sectionBtn)
        case "Status":
            statusView.backgroundColor = .white
            statusBadge.isHidden = false
            selectedButton(statusBtn)
        case "Date":
            dateView.backgroundColor = .white
            dateBadge.isHidden = false
            selectedButton(dateBtn)
        default:
            break
        }
    }
    
    func selectedButton(_ button: UIButton) {
                
        button.setTitleColor(.theme, for: .normal)
        
    }
    
    // MARK: - Current Array
    
    func currentArray() -> [String] {
        
        switch selectedType {
            
        case "Grade":
            return gradeArray
            
        case "Section":
            return sectionArray
            
        case "Status":
            return statusArray
            
        default:
            return []
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func gradeTapped(_ sender: UIButton) {
        selectedType = "Grade"
        updateButtons()
        tableView.reloadData()
    }
    
    @IBAction func sectionTapped(_ sender: UIButton) {
        selectedType = "Section"
        updateButtons()
        tableView.reloadData()
    }
    
    @IBAction func statusTapped(_ sender: UIButton) {
        selectedType = "Status"
        updateButtons()
        tableView.reloadData()
    }
    
    @IBAction func clearTapped(_ sender: UIButton) {
        
        selectedGrade = ""
        selectedSection = ""
        selectedStatus = ""
        
        tableView.reloadData()
    }
    
    @IBAction func applyTapped(_ sender: UIButton) {
        
        print("Selected Grade:", selectedGrade)
        print("Selected Section:", selectedSection)
        print("Selected Status:", selectedStatus)
        
        dismiss(animated: true)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.onDismiss?()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss?()
    }
}

// MARK: - UITableView Delegate/DataSource

extension FilterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return currentArray().count
    }
    // ✅ Cell Height
    
//    func tableView(_ tableView: UITableView,
//
//                   heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return 60
//
//    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTCell", for: indexPath as IndexPath) as? FilterTCell {
            
            let value = currentArray()[indexPath.row]
            
            cell.titleLbl?.text = value
            cell.selectionStyle = .none
            
            cell.checkBoxBtn.isUserInteractionEnabled = false
            
            // Selected image
            
            if isSelected(value: value) {
                
                cell.checkBoxBtn.isSelected = true
                                
            } else {
                
                cell.checkBoxBtn.isSelected = false

                
            }
            
            return cell
        }else {
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let value = currentArray()[indexPath.row]
        
        switch selectedType {
            
        case "Grade":
            selectedGrade = value
            
        case "Section":
            selectedSection = value
            
        case "Status":
            selectedStatus = value
            
        default:
            break
        }
        
        tableView.reloadData()
    }
    // MARK: - Selected Check
    
    func isSelected(value: String) -> Bool {
        
        switch selectedType {
            
        case "Grade":
            
            return selectedGrade == value
            
        case "Section":
            
            return selectedSection == value
            
        case "Status":
            
            return selectedStatus == value
            
        default:
            
            return false
            
        }
        
    }
}
