//
//  VisitorPassDetailVC.swift
//  KliqEdu
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreImage.CIFilterBuiltins

class VisitorPassDetailVC: UIViewController {

    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var qrHintLbl: UILabel!
    @IBOutlet weak var validityLbl: UILabel!
    @IBOutlet weak var visitorNameLbl: UILabel!
    @IBOutlet weak var relationLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var studentLbl: UILabel!
    @IBOutlet weak var purposeLbl: UILabel!
    @IBOutlet weak var createdLbl: UILabel!
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var initialsLbl: UILabel!
    @IBOutlet weak var issuedTimeLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var expiresTimeLbl: UILabel!
    @IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var validityIconView: UIImageView!
    @IBOutlet weak var dashLineView: UIImageView!

    /// From the list (has the student name). Nil right after creating a pass: only `uniqueId` is known.
    var passDetails: VisitorPassModel?
    var uniqueId = ""

    private var countdownTimer: Timer?
    /// Ticket "tear" line between the QR code and the validity.
    private let dashLayer = CAShapeLayer()
    private var isLoadingPass = false

    /// The scroll content (ticket + buttons), hidden until there is something to show.
    private var contentView: UIView? { actionsStackView.superview }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Keep the QR code sharp when scaled.
        qrImageView.layer.magnificationFilter = .nearest
        statusLbl.layer.cornerRadius = 13
        statusLbl.layer.masksToBounds = true
        statusLbl.backgroundColor = .white
        timeProgressView.layer.cornerRadius = 3
        timeProgressView.clipsToBounds = true

        dashLayer.strokeColor = UIColor.systemGray4.cgColor
        dashLayer.lineWidth = 1.5
        dashLayer.lineDashPattern = [6, 5]
        dashLayer.lineCap = .round
        dashLineView.layer.addSublayer(dashLayer)
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        // Fresh copy every time (e.g. after creating or editing).
        getPassDetailsApi()
        startCountdown()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: dashLineView.bounds.midY))
        path.addLine(to: CGPoint(x: dashLineView.bounds.width, y: dashLineView.bounds.midY))
        dashLayer.frame = dashLineView.bounds
        dashLayer.path = path.cgPath
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
        countdownTimer = nil
        if isLoadingPass { LoadingIndicator.hide() }
    }

    // MARK: - UI

    private func updateUI() {
        guard let pass = passDetails else {
            contentView?.alpha = 0
            return
        }
        contentView?.alpha = 1

        let state = pass.state
        let stateColor: UIColor
        switch state {
        case .active: stateColor = .theme
        case .expired: stateColor = UIColor(red: 0.45, green: 0.47, blue: 0.53, alpha: 1)
        case .cancelled: stateColor = UIColor(red: 0.85, green: 0.30, blue: 0.33, alpha: 1)
        }
        visitorNameLbl.adjustsFontSizeToFitWidth = true

        // Header: who the pass is for, tinted by status.
        headerView.backgroundColor = stateColor
        initialsLbl.text = pass.initials
        visitorNameLbl.text = pass.visitor_name ?? "-"
        relationLbl.text = pass.relation ?? "Visitor"
        statusLbl.text = "   \(state.title)   "
        statusLbl.textColor = state == .active ? .systemGreen : stateColor

        // QR code
        let id = pass.unique_id ?? uniqueId
        qrImageView.image = generateQRCode(from: id)
        qrImageView.alpha = state == .active ? 1 : 0.2
        switch state {
        case .active: qrHintLbl.text = "Show this QR code at the school gate"
        case .expired: qrHintLbl.text = "This pass has expired and can't be used"
        case .cancelled: qrHintLbl.text = "This pass was cancelled and can't be used"
        }

        // Validity strip
        issuedTimeLbl.text = pass.createdDate.map { timeAndDay($0) } ?? "-"
        durationLbl.text = pass.validity_minutes.map { VisitorPassModel.durationText(minutes: $0) } ?? "-"
        expiresTimeLbl.text = pass.expiresDate.map { timeAndDay($0) } ?? "-"

        let fraction = pass.remainingFraction
        let remainingColor: UIColor = fraction <= 0.2 ? .systemOrange : .systemGreen
        timeProgressView.isHidden = state != .active
        timeProgressView.progress = fraction
        timeProgressView.progressTintColor = remainingColor
        switch state {
        case .active:
            validityLbl.text = "\(pass.remainingText) · expires at \(pass.validTillTime)"
            validityLbl.textColor = remainingColor
        case .expired:
            validityLbl.text = "Expired at \(pass.validTillTime), \(pass.validTillDate)"
            validityLbl.textColor = .darkGray
        case .cancelled:
            validityLbl.text = "Cancelled · was valid till \(pass.validTillTime)"
            validityLbl.textColor = .systemRed
        }
        validityIconView.tintColor = validityLbl.textColor

        // Visit details
        purposeLbl.text = pass.purpose ?? "-"
        phoneLbl.text = pass.phone ?? "-"
        // The view API has no student; it comes from the list.
        studentLbl.text = pass.student_name
        studentLbl.superview?.isHidden = (pass.student_name ?? "").isEmpty
        createdLbl.text = [pass.issued_by, pass.issuedText].compactMap { $0 }.joined(separator: "\n")

        // Only an active pass can be shared, edited or cancelled.
        actionsStackView.isHidden = !pass.isActive
        shareBtn.isHidden = !pass.isActive
    }

    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.updateUI()
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        guard !string.isEmpty else { return nil }
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 12, y: 12)),
              let cgImage = CIContext().createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    /// "01:23 PM" today, "01:23 PM\n04 Oct" on other days.
    private func timeAndDay(_ date: Date) -> String {
        let time = VisitorPassModel.timeFormatter.string(from: date)
        if Calendar.current.isDateInToday(date) { return time }
        let day = DateFormatter()
        day.dateFormat = "dd MMM"
        return "\(time)\n\(day.string(from: date))"
    }

    // MARK: - Actions

    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func editBtnTapped(_ sender: Any) {
        guard let pass = passDetails, pass.isActive else { return }
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "CreateVisitorPassVC") as? CreateVisitorPassVC {
            vc.passDetails = pass
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func cancelBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: Constants.appName,
                                      message: "Cancel this visitor pass? The visitor won't be able to use it.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants.yes, style: .destructive) { _ in
            self.cancelPassApi()
        })
        alert.addAction(UIAlertAction(title: StringConstants.no, style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func shareBtnTapped(_ sender: Any) {
        guard let pass = passDetails else { return }
        var text = "Visitor pass for \(pass.visitor_name ?? "")"
        if let relation = pass.relation, !relation.isEmpty { text += " (\(relation))" }
        if let student = pass.student_name, !student.isEmpty { text += " to visit \(student)" }
        text += ".\nValid till \(pass.validTillTime), \(pass.validTillDate). Please show the QR code at the school gate."

        var items: [Any] = [text]
        if let image = qrImageView.image { items.insert(image, at: 0) }
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = shareBtn
        present(activity, animated: true)
    }

    // MARK: - API

    func getPassDetailsApi() {
        let id = passDetails?.unique_id ?? uniqueId
        guard !id.isEmpty, !isLoadingPass else { return }
        guard NetworkManager.shared.isConnected else {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            return
        }
        isLoadingPass = true
        // Nothing to show yet (just created): use the app loader instead of an empty ticket.
        if passDetails == nil { LoadingIndicator.show() }

        let param = [:] as [String: Any]
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(id)", params: param, HTTPMethod: .get)
        callServiceMethod(service: "\(Constants.Urls.parentVisitorPassViewUrl)/\(id)", method: .get, params: param, key: "viewPassUrl", headers: headers)
    }

    func cancelPassApi() {
        let id = passDetails?.unique_id ?? uniqueId
        guard !id.isEmpty else { return }
        guard NetworkManager.shared.isConnected else {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            return
        }
        cancelBtn?.showButtonLoading()
        let param = [:] as [String: Any]
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(id)", params: param, HTTPMethod: .patch)
        callServiceMethod(service: "\(Constants.Urls.parentVisitorPassCancelUrl)/\(id)", method: .patch, params: param, key: "cancelPassUrl", headers: headers)
    }

    private func finishLoadingPass() {
        if isLoadingPass && passDetails == nil { LoadingIndicator.hide() }
        isLoadingPass = false
    }

    func callServiceMethod(service: String, method: HTTPMethod, params: [String: Any], key: String, headers: [String: String]) {
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            let result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if resultcheck {
                if key == "viewPassUrl" {
                    let previous = self.passDetails
                    self.finishLoadingPass()
                    if let data = result?["data"] as? NSDictionary, let pass = VisitorPassModel(dictionary: data) {
                        pass.fillMissing(from: previous)
                        // Passes belong to the selected child, so that is the student when nothing else says so.
                        if pass.student_name == nil, roleKey == "parent" {
//                            let child = ChatService.shared.myDisplayName
//                            pass.student_name = child.isEmpty ? nil : child
                        }
                        self.passDetails = pass
                    }
                    self.updateUI()
                } else if key == "cancelPassUrl" {
                    self.cancelBtn?.hideButtonLoading()
                    NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.visitorPassChanged), object: nil)
                    self.showAnimatedToast(message: result?["message"] as? String ?? "Visitor pass cancelled")
                    // The cancel response only has the id: reload the full pass.
                    self.getPassDetailsApi()
                }
            } else {
                if key == "viewPassUrl" { self.finishLoadingPass() }
                self.cancelBtn?.hideButtonLoading()
                let errorCode: Int = result?["status_code"] as? Int ?? 0
                let msg = result?["message"] as? String ?? StringConstants.somethingWentWrong
                if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    self.performLogout(Vc: self)
                } else {
                    self.showAnimatedToast(message: msg, type: .warning)
                }
            }
        }) { error in
            if key == "viewPassUrl" { self.finishLoadingPass() }
            self.cancelBtn?.hideButtonLoading()
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain, type: .error)
            debugPrint(error)
        }
    }
}
