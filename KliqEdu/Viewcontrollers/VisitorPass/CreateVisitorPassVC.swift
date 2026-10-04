//
//  CreateVisitorPassVC.swift
//  KliqEdu
//

import UIKit
import Alamofire
import SwiftyJSON
import DropDown

class CreateVisitorPassVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var relationRowView: UIView!
    @IBOutlet weak var relationLbl: UILabel!
    @IBOutlet weak var visitorWarningLbl: UILabel!
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var purposeWarningLbl: UILabel!
    @IBOutlet var validityButtons: [UIButton]!
    @IBOutlet weak var validityHintLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!

    /// Set to edit an existing pass.
    var passDetails: VisitorPassModel?

    private let relationDropDown = DropDown()
    private let relations = ["Father", "Mother", "Guardian", "Grandparent", "Sibling", "Relative", "Driver", "Other"]
    private var selectedRelation = ""
    private var selectedValidity = 30
    private let purposePlaceholder = "e.g. Parent-teacher meeting, picking up my child"

    private var isEditMode: Bool { passDetails != nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        nameField.delegate = self
        phoneField.delegate = self
        purposeTextView.delegate = self
        purposeTextView.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)

        [visitorWarningLbl, purposeWarningLbl].forEach { $0?.hide() }
        configureRelationDropDown()

        if let pass = passDetails {
            titleLbl.text = "Edit Visitor Pass"
            submitBtn.setTitle("Update Pass", for: .normal)
            nameField.text = pass.visitor_name
            phoneField.text = pass.phone
            setRelation(pass.relation ?? "")
            setPurpose(pass.purpose ?? "")
            selectedValidity = pass.validity_minutes ?? 30
        } else {
            titleLbl.text = "Create Visitor Pass"
            submitBtn.setTitle("Generate Pass", for: .normal)
            setRelation("")
            setPurpose("")
        }
        updateValidityButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }

    // MARK: - Relation

    private func configureRelationDropDown() {
        relationDropDown.anchorView = relationRowView
        relationDropDown.bottomOffset = CGPoint(x: 0, y: relationRowView.bounds.height)
        relationDropDown.direction = .any
        relationDropDown.backgroundColor = .white
        relationDropDown.cellHeight = 48
        relationDropDown.textFont = UIFont(name: GLOBAL.FontsIdentifier.FontMedium, size: 15) ?? .systemFont(ofSize: 15)
        relationDropDown.selectionBackgroundColor = .themeLite1
        relationDropDown.separatorColor = UIColor.systemGray5
        relationDropDown.dataSource = relations
        relationDropDown.selectionAction = { [weak self] _, item in
            self?.setRelation(item)
            self?.updateVisitorWarning()
        }
    }

    private func setRelation(_ relation: String) {
        selectedRelation = relation
        relationLbl.text = relation.isEmpty ? "Select relation" : relation
        relationLbl.textColor = relation.isEmpty ? .lightGray : .black
    }

    // MARK: - Purpose

    private func setPurpose(_ purpose: String) {
        if purpose.isEmpty {
            purposeTextView.text = purposePlaceholder
            purposeTextView.textColor = .lightGray
        } else {
            purposeTextView.text = purpose
            purposeTextView.textColor = .black
        }
    }

    private var purposeText: String {
        purposeTextView.textColor == .lightGray ? "" : purposeTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Validity

    private func updateValidityButtons() {
        // Editing: validity is counted from when the pass was created, so durations that
        // have already run out would expire the pass immediately.
        let createdDate = passDetails?.createdDate
        for button in validityButtons {
            var isAvailable = true
            if let created = createdDate {
                isAvailable = created.addingTimeInterval(TimeInterval(button.tag * 60)) > Date()
            }
            button.isEnabled = isAvailable
            button.alpha = isAvailable ? 1 : 0.4
            let isSelected = button.tag == selectedValidity
            button.backgroundColor = isSelected ? .theme : .white
            button.setTitleColor(isSelected ? .white : .black, for: .normal)
        }
        let duration = VisitorPassModel.durationText(minutes: selectedValidity)
        if let created = createdDate {
            let validTill = VisitorPassModel.timeFormatter.string(from: created.addingTimeInterval(TimeInterval(selectedValidity * 60)))
            let createdAt = VisitorPassModel.timeFormatter.string(from: created)
            validityHintLbl.text = "Validity is counted from when the pass was created (\(createdAt)). It will be valid till \(validTill)."
        } else {
            validityHintLbl.text = "The pass will be valid for \(duration) from the time it's generated."
        }
    }

    // MARK: - Actions

    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func relationBtnTapped(_ sender: Any) {
        view.endEditing(true)
        relationDropDown.show()
    }

    @IBAction func validityTapped(_ sender: UIButton) {
        selectedValidity = sender.tag
        updateValidityButtons()
    }

    @IBAction func submitBtnTapped(_ sender: Any) {
        view.endEditing(true)
        guard validateFields() else { return }

        guard NetworkManager.shared.isConnected else {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            return
        }
        submitBtn?.showButtonLoading()

        let param: [String: Any] = [
            "visitor_name": (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "relation": selectedRelation,
            "phone": (phoneField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "purpose": purposeText,
            "validity_minutes": selectedValidity
        ]

        if let uniqueId = passDetails?.unique_id {
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(uniqueId)", params: param, HTTPMethod: .patch)
            callServiceMethod(service: "\(Constants.Urls.parentVisitorPassUpdateUrl)/\(uniqueId)", method: .patch, params: param, key: "updatePassUrl", headers: headers)
        } else {
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/add", params: param, HTTPMethod: .post)
            callServiceMethod(service: Constants.Urls.parentVisitorPassAddUrl, method: .post, params: param, key: "createPassUrl", headers: headers)
        }
    }

    // MARK: - Validation

    @discardableResult
    private func updateVisitorWarning() -> Bool {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var message: String?
        if name.count < 2 {
            message = "Please enter the visitor's name"
        } else if let phoneError = ValidationClass.validateMobileNumber(phoneField.text ?? "") {
            message = phoneError
        } else if selectedRelation.isEmpty {
            message = "Please select the visitor's relation"
        }
        if let message = message {
            visitorWarningLbl.text = message
            visitorWarningLbl.unhide()
            return false
        }
        visitorWarningLbl.hide()
        return true
    }

    @discardableResult
    private func updatePurposeWarning() -> Bool {
        let purpose = purposeText
        if purpose.isEmpty {
            purposeWarningLbl.text = "Please enter the purpose of the visit"
        } else if purpose.count < 5 {
            purposeWarningLbl.text = "Purpose should be minimum 5 characters"
        } else {
            purposeWarningLbl.hide()
            return true
        }
        purposeWarningLbl.unhide()
        return false
    }

    private func validateFields() -> Bool {
        let visitorValid = updateVisitorWarning()
        let purposeValid = updatePurposeWarning()
        return visitorValid && purposeValid
    }

    // MARK: - API

    func callServiceMethod(service: String, method: HTTPMethod, params: [String: Any], key: String, headers: [String: String]) {
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            self.submitBtn?.hideButtonLoading()
            let result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if resultcheck {
                let msg = result?["message"] as? String ?? ""
                if !msg.isEmpty {
                    self.showAnimatedToast(message: msg)
                }
                let data = result?["data"] as? NSDictionary
                NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.visitorPassChanged), object: nil)

                if key == "createPassUrl", let uniqueId = data?["unique_id"] as? String, !uniqueId.isEmpty {
                    // The create API only returns the id: the details screen loads the full pass (with its QR code).
                    self.openDetails(uniqueId: uniqueId)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                let errorCode: Int = result?["status_code"] as? Int ?? 0
                let msg = result?["message"] as? String ?? StringConstants.somethingWentWrong
                if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    self.performLogout(Vc: self)
                } else {
                    self.showAnimatedToast(message: msg, type: .warning)
                }
            }
        }) { error in
            self.submitBtn?.hideButtonLoading()
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain, type: .error)
            debugPrint(error)
        }
    }

    private func openDetails(uniqueId: String) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        guard let nav = navigationController,
              let vc = sb.instantiateViewController(withIdentifier: "VisitorPassDetailVC") as? VisitorPassDetailVC else {
            navigationController?.popViewController(animated: true)
            return
        }
        vc.uniqueId = uniqueId
        vc.hidesBottomBarWhenPushed = true
        var stack = nav.viewControllers
        stack.removeLast()
        stack.append(vc)
        nav.setViewControllers(stack, animated: true)
    }
}

// MARK: - Text input
extension CreateVisitorPassVC: UITextFieldDelegate, UITextViewDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        guard let stringRange = Range(range, in: current) else { return true }
        let updated = current.replacingCharacters(in: stringRange, with: string)
        if textField == phoneField {
            return updated.count <= 15 && updated.allSatisfy { $0.isNumber }
        }
        return updated.count <= 60
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if !visitorWarningLbl.isHidden {
            updateVisitorWarning()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            phoneField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setPurpose("")
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if !purposeWarningLbl.isHidden {
            updatePurposeWarning()
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let current = textView.text ?? ""
        guard let stringRange = Range(range, in: current) else { return true }
        return current.replacingCharacters(in: stringRange, with: text).count <= 500
    }
}
