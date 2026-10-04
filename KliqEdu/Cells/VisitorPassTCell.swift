//
//  VisitorPassTCell.swift
//  KliqEdu
//

import UIKit

/// Ticket-style visitor pass card.
class VisitorPassTCell: UITableViewCell {

    //MARK: Outlets

    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var initialsLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var purposeLbl: UILabel!
    @IBOutlet weak var validTitleLbl: UILabel!
    @IBOutlet weak var validTimeLbl: UILabel!
    @IBOutlet weak var remainingLbl: UILabel!
    @IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var dashLineView: UIImageView!
    @IBOutlet weak var progressHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressTopConstraint: NSLayoutConstraint!

    /// Ticket "tear" line between the visitor details and the validity.
    private let dashLayer = CAShapeLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        statusLbl.layer.cornerRadius = 13
        statusLbl.layer.masksToBounds = true
        timeProgressView.layer.cornerRadius = 2
        timeProgressView.clipsToBounds = true

        dashLineView.image = nil
        dashLayer.strokeColor = UIColor.systemGray4.cgColor
        dashLayer.lineWidth = 1.5
        dashLayer.lineDashPattern = [6, 5]
        dashLayer.lineCap = .round
        dashLineView.layer.addSublayer(dashLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        let y = dashLineView.bounds.midY
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: dashLineView.bounds.width, y: y))
        dashLayer.frame = dashLineView.bounds
        dashLayer.path = path.cgPath
    }

    func configureCellWith(pass: VisitorPassModel) {
        let state = pass.state

        initialsLbl.text = pass.initials
        nameLbl.text = pass.visitor_name
        subtitleLbl.text = [pass.relation, pass.phone].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
        purposeLbl.text = pass.purpose ?? "-"

        statusLbl.text = state.title
        statusLbl.textColor = state.textColor
        statusLbl.backgroundColor = state.backgroundColor

        // Avatar tinted by status so passes can be told apart at a glance.
        switch state {
        case .active:
            avatarView.backgroundColor = UIColor(named: "ThemeLite1")
            initialsLbl.textColor = UIColor(named: "ThemeColor")
        case .expired:
            avatarView.backgroundColor = .systemGray5
            initialsLbl.textColor = .darkGray
        case .cancelled:
            avatarView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            initialsLbl.textColor = .systemRed
        }

        let date = pass.validTillDate
        validTimeLbl.text = date.isEmpty ? pass.validTillTime : "\(pass.validTillTime) · \(date)"

        switch state {
        case .active:
            validTitleLbl.text = "Valid till"
            remainingLbl.text = pass.remainingText
            remainingLbl.textColor = remainingColor(for: pass)
        case .expired:
            validTitleLbl.text = "Expired at"
            remainingLbl.text = nil   // the status pill already says it
        case .cancelled:
            validTitleLbl.text = "Was valid till"
            remainingLbl.text = nil
        }

        // Time bar: how much of an active pass's validity is left. Collapsed for other passes.
        let showsBar = state == .active
        timeProgressView.isHidden = !showsBar
        progressHeightConstraint.constant = showsBar ? 4 : 0
        progressTopConstraint.constant = showsBar ? 12 : 0
        timeProgressView.progress = pass.remainingFraction
        timeProgressView.progressTintColor = remainingColor(for: pass)
    }

    /// Green while there's time, orange in the last 20% so it stands out.
    private func remainingColor(for pass: VisitorPassModel) -> UIColor {
        pass.remainingFraction <= 0.2 ? .systemOrange : .systemGreen
    }
}
