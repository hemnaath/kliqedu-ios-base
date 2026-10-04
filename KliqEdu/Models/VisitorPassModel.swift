//
//  VisitorPassModel.swift
//  KliqEdu
//

import UIKit

/// A visitor pass created by a parent (`parent/visitor-pass/...`).
///
/// The API returns two shapes:
/// - list:  flat (`visitor_name`, `contact_number`, `status` "Active", `expires_at` "03 Oct 2026, 12:15 PM", `student_name`)
/// - view:  nested (`visitor_identity`, `pass_validity`, `parent_data`)
/// Create / update / cancel only return `unique_id`.
class VisitorPassModel {

    enum PassState {
        case active
        case expired
        case cancelled

        var title: String {
            switch self {
            case .active: return "Active"
            case .expired: return "Expired"
            case .cancelled: return "Cancelled"
            }
        }

        /// Value the list API expects for its `status` filter.
        var apiValue: String { title }

        var textColor: UIColor {
            switch self {
            case .active: return .systemGreen
            case .expired: return .darkGray
            case .cancelled: return .systemRed
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .active: return UIColor.systemGreen.withAlphaComponent(0.12)
            case .expired: return UIColor.systemGray5
            case .cancelled: return UIColor.systemRed.withAlphaComponent(0.1)
            }
        }
    }

    var unique_id: String?
    var visitor_name: String?
    var relation: String?
    var phone: String?
    var purpose: String?
    var validity_minutes: Int?
    var statusText: String?
    var expires_at: String?
    var issued_at: String?
    var student_name: String?
    var issued_by: String?

    init?(dictionary: NSDictionary) {
        let identity = dictionary["visitor_identity"] as? NSDictionary
        let validity = dictionary["pass_validity"] as? NSDictionary
        let parent = dictionary["parent_data"] as? NSDictionary

        func string(_ keys: [String], in sources: [NSDictionary?]) -> String? {
            for source in sources {
                for key in keys {
                    if let value = source?[key] as? String, !value.isEmpty, value != "undefined", value != "null" { return value }
                    if let value = source?[key] as? NSNumber { return value.stringValue }
                }
            }
            return nil
        }

        unique_id = string(["unique_id"], in: [identity, dictionary])
        visitor_name = string(["visitor_name"], in: [identity, dictionary])
        relation = string(["relation"], in: [identity, dictionary])
        phone = string(["contact_number", "phone"], in: [identity, dictionary])
        purpose = string(["purpose"], in: [identity, dictionary])
        validity_minutes = Int(string(["pass_duration", "validity_minutes"], in: [validity, dictionary]) ?? "")
        statusText = string(["status"], in: [parent, dictionary])
        expires_at = string(["pass_expires_at", "expires_at"], in: [validity, dictionary])
        issued_at = string(["pass_issued_at", "created_at"], in: [validity, dictionary])
        student_name = string(["student_name"], in: [dictionary]) ?? ((dictionary["student"] as? NSDictionary)?["full_name"] as? String)

        if let name = string(["parent_name"], in: [parent]) {
            let parentRelation = string(["parent_relation"], in: [parent])
            issued_by = parentRelation.map { "\(name) (\($0))" } ?? name
        }

        guard unique_id != nil else { return nil }
    }

    /// Keeps details that one response has and the other doesn't (e.g. the view API has no student name).
    func fillMissing(from other: VisitorPassModel?) {
        guard let other = other else { return }
        student_name = student_name ?? other.student_name
        issued_by = issued_by ?? other.issued_by
        phone = phone ?? other.phone
        purpose = purpose ?? other.purpose
        relation = relation ?? other.relation
    }

    // MARK: - Dates

    /// Dates come as "03 Oct 2026, 12:15 PM" (device/school local time); ISO strings are accepted too.
    private static let displayParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy, hh:mm a"
        return formatter
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static func parseDate(_ value: String?) -> Date? {
        guard let value = value else { return nil }
        return displayParser.date(from: value)
            ?? isoFormatter.date(from: value)
            ?? ISO8601DateFormatter().date(from: value)
    }

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    var expiresDate: Date? { VisitorPassModel.parseDate(expires_at) }

    /// When the pass was issued. The API counts validity from this time, also after an edit.
    var createdDate: Date? {
        if let issued = VisitorPassModel.parseDate(issued_at) { return issued }
        guard let expires = expiresDate, let minutes = validity_minutes else { return nil }
        return expires.addingTimeInterval(TimeInterval(-minutes * 60))
    }

    // MARK: - State

    /// Active passes become "Expired" once the expiry time has passed, even if the API still says active.
    var state: PassState {
        let status = (statusText ?? "").lowercased()
        if status.hasPrefix("cancel") || status == "2" { return .cancelled }
        if status.hasPrefix("expire") { return .expired }
        if let expires = expiresDate, expires <= Date() { return .expired }
        return .active
    }

    var isActive: Bool { state == .active }

    var validTillTime: String {
        guard let date = expiresDate else { return "-" }
        return VisitorPassModel.timeFormatter.string(from: date)
    }

    var validTillDate: String {
        guard let date = expiresDate else { return "" }
        return Calendar.current.isDateInToday(date) ? "Today" : VisitorPassModel.dateFormatter.string(from: date)
    }

    var issuedText: String {
        guard let date = createdDate else { return issued_at ?? "-" }
        let day = Calendar.current.isDateInToday(date) ? "Today" : VisitorPassModel.dateFormatter.string(from: date)
        return "\(day), \(VisitorPassModel.timeFormatter.string(from: date))"
    }

    /// "24 min left", "1 hr 5 min left"; empty when the pass isn't active.
    var remainingText: String {
        guard isActive, let expires = expiresDate else { return "" }
        let minutes = max(1, Int(ceil(expires.timeIntervalSinceNow / 60)))
        return "\(VisitorPassModel.durationText(minutes: minutes)) left"
    }

    /// Share of the validity still left (1 = just issued, 0 = used up / not active).
    var remainingFraction: Float {
        guard isActive, let expires = expiresDate, let created = createdDate else { return 0 }
        let total = expires.timeIntervalSince(created)
        guard total > 0 else { return 0 }
        return Float(min(max(expires.timeIntervalSinceNow / total, 0), 1))
    }
    
    static func durationText(minutes: Int) -> String {
        if minutes < 60 { return "\(minutes) min" }
        let hours = minutes / 60
        let rest = minutes % 60
        let hourText = hours == 1 ? "1 hr" : "\(hours) hrs"
        return rest == 0 ? hourText : "\(hourText) \(rest) min"
    }

    var initials: String {
        let words = (visitor_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
        let first = words.first?.first.map { String($0).uppercased() } ?? ""
        let second = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
        return second.isEmpty ? first : "\(first) \(second)"
    }
}
