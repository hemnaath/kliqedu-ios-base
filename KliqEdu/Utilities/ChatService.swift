//
//  ChatService.swift
//  KliqEdu
//
//  Shared chat logic used by the chat list, the chat screen and push notifications.
//
//  How chat works with the backend:
//  - A room is "<studentUniqueId>_<teacherUniqueId>". Teachers chat with a student's parent;
//    on the parent side the logged-in identity is the selected child's unique id.
//  - The server only queues undelivered messages. The app downloads a room's queue, stores it
//    in Core Data and then deletes it on the server, so the device cache is the chat history.
//

import UIKit
import Alamofire
import SwiftyJSON

//extension Notification.Name {
//    /// Posted after messages for a room were saved locally (object: room id).
//    static let chatMessagesUpdated = Notification.Name("chatMessagesUpdated")
//}
//
///// Name, subtitle and picture shown for the other person in a chat.
//struct ChatContact: Codable {
//    var name: String
//    var subtitle: String
//    var picture: String
//    var mobile: String? = nil
//}

//final class ChatService {
//
//    static let shared = ChatService()
//    private init() {}
//
//    private let defaults = UserDefaults.standard
//    private let contactsKey = "chat_contacts"
//    private var syncingRooms = Set<String>()
//    private var resolvingIds = Set<String>()
//    private var teachersListRequested = false
//
//    /// Chat opened from a notification before the tab bar was ready (cold launch).
//    var pendingRoomId: String?
//
//    // MARK: - Identity
//
//    var isTeacher: Bool { roleKey == "teacher" }
//
//    var myUniqueId: String { defaults.string(forKey: Constants.Keys.userUniqueIdKey) ?? "" }
//
//    func roomId(withCounterpart counterpartId: String) -> String {
//        isTeacher ? "\(counterpartId)_\(myUniqueId)" : "\(myUniqueId)_\(counterpartId)"
//    }
//
//    /// (studentId, teacherId) for a room id, if it has the expected format.
//    func participants(of roomId: String) -> (student: String, teacher: String)? {
//        let parts = roomId.components(separatedBy: "_")
//        guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else { return nil }
//        return (parts[0], parts[1])
//    }
//
//    /// The logged-in side of the room (teacher id, or the child's id for a parent).
//    func myId(in roomId: String) -> String {
//        guard let p = participants(of: roomId) else { return myUniqueId }
//        return isTeacher ? p.teacher : p.student
//    }
//
//    /// The other side of the room (student id for a teacher, teacher id for a parent).
//    func counterpartId(in roomId: String) -> String {
//        guard let p = participants(of: roomId) else { return "" }
//        return isTeacher ? p.student : p.teacher
//    }
//
//    /// Rooms that belong to the logged-in user (and, for parents, the selected child).
//    func isMyRoom(_ roomId: String) -> Bool {
//        guard let p = participants(of: roomId), !myUniqueId.isEmpty else { return false }
//        return isTeacher ? p.teacher == myUniqueId : p.student == myUniqueId
//    }
//
//    /// Parents' messages can come back from the server with the parent's own id ("PAR-…").
//    func isOwnMessage(_ message: SingleChatModel, roomId: String) -> Bool {
//        let sender = message.sender_id ?? ""
//        if sender == myId(in: roomId) { return true }
//        if !isTeacher {
//            let parentId = defaults.string(forKey: Constants.Keys.parentIdKey) ?? ""
//            return sender.hasPrefix("PAR-") || (!parentId.isEmpty && sender == parentId)
//        }
//        return false
//    }
//
//    /// Name sent as `sender_name`: the teacher's name, or the selected child's name for a parent.
//    var myDisplayName: String {
//        if !isTeacher, let child = currentChild() {
//            let name = "\(child["firstname"] as? String ?? "") \(child["lastname"] as? String ?? "")"
//                .trimmingCharacters(in: .whitespaces)
//            if !name.isEmpty { return name }
//        }
//        let first = defaults.string(forKey: Constants.Keys.firstNameKey) ?? ""
//        let last = defaults.string(forKey: Constants.Keys.lastNameKey) ?? ""
//        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
//    }
//
//    private func currentChild() -> [String: Any]? {
//        guard let data = defaults.data(forKey: Constants.Keys.childrenArrayKey),
//              let children = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return nil }
//        return children.first { ($0["unique_id"] as? String) == myUniqueId }
//    }
//
//    // MARK: - Contacts
//
//    private var contacts: [String: ChatContact] {
//        get {
//            guard let data = defaults.data(forKey: contactsKey),
//                  let value = try? JSONDecoder().decode([String: ChatContact].self, from: data) else { return [:] }
//            return value
//        }
//        set {
//            if let data = try? JSONEncoder().encode(newValue) {
//                defaults.set(data, forKey: contactsKey)
//            }
//        }
//    }
//
//    func contact(for uniqueId: String) -> ChatContact? {
//        contacts[uniqueId]
//    }
//
//    func saveContact(_ contact: ChatContact, for uniqueId: String) {
//        guard !uniqueId.isEmpty, !contact.name.isEmpty else { return }
//        var all = contacts
//        all[uniqueId] = contact
//        contacts = all
//    }
//
//    func saveContact(student: StudentsModel) {
//        saveContact(ChatContact(name: student.full_name ?? "",
//                                subtitle: ChatService.gradeText(student.studentClass ?? ""),
//                                picture: student.student_picture ?? ""),
//                    for: student.unique_id ?? "")
//    }
//
//    func saveContact(teacher: TeachersModel) {
//        saveContact(ChatContact(name: teacher.full_name ?? "",
//                                subtitle: ChatService.subjectText(teacher.subject ?? ""),
//                                picture: teacher.teacher_picture ?? "",
//                                mobile: teacher.mobile),
//                    for: teacher.unique_id ?? "")
//    }
//
//    static func gradeText(_ grade: String) -> String {
//        let value = grade.trimmingCharacters(in: .whitespaces)
//        if value.isEmpty { return "" }
//        return value.lowercased().hasPrefix("grade") ? value : "Grade \(value)"
//    }
//
//    static func subjectText(_ subject: String) -> String {
//        let value = subject.trimmingCharacters(in: .whitespaces)
//        return value.isEmpty ? "Teacher" : "\(value) Teacher"
//    }
//
//    /// Best available name/subtitle/picture for the other person in a room.
//    /// Order: saved contact → my last sent message (it carries the receiver's details)
//    /// → the other person's `sender_name` → a role-based fallback.
//    func displayContact(forRoom roomId: String, messages: [SingleChatModel]) -> ChatContact {
//        let counterpart = counterpartId(in: roomId)
//        if let saved = contact(for: counterpart) { return saved }
//
//        let sorted = messages.sorted { ($0.timestamp ?? 0) > ($1.timestamp ?? 0) }
//
//        if let sent = sorted.first(where: { isOwnMessage($0, roomId: roomId) }) {
//            let detailsName = "\(sent.firstname ?? "") \(sent.lastname ?? "")".trimmingCharacters(in: .whitespaces)
//            let name = detailsName.isEmpty ? (sent.receiver_name ?? "") : detailsName
//            if !name.isEmpty {
//                let subtitle: String
//                if isTeacher {
//                    subtitle = TeacherWorkload.gradeSectionText(grade: sent.grade ?? "", section: sent.section ?? "")
//                } else {
//                    subtitle = ChatService.subjectText(sent.subject ?? "")
//                }
//                return ChatContact(name: name,
//                                   subtitle: (sent.grade ?? "").isEmpty && isTeacher ? "" : subtitle,
//                                   picture: sent.picture ?? "",
//                                   mobile: sent.mobile_number)
//            }
//        }
//
//        if let received = sorted.first(where: { !isOwnMessage($0, roomId: roomId) }),
//           let name = received.sender_name, !name.trimmingCharacters(in: .whitespaces).isEmpty {
//            return ChatContact(name: name, subtitle: isTeacher ? "" : "Teacher", picture: "")
//        }
//
//        return ChatContact(name: isTeacher ? "Parent" : "Teacher", subtitle: "", picture: "")
//    }
//
//    /// Looks up an unknown contact from the API and caches it.
//    /// Teachers: student info by id. Parents: the teachers list (one request per session).
//    func resolveContact(_ uniqueId: String, completion: @escaping () -> Void) {
//        guard !uniqueId.isEmpty, contact(for: uniqueId) == nil, NetworkManager.shared.isConnected else { return }
//
//        if isTeacher {
//            guard !resolvingIds.contains(uniqueId) else { return }
//            resolvingIds.insert(uniqueId)
//            let param = [:] as [String: Any]
//            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(uniqueId)", params: param, HTTPMethod: .get)
//            AlamofireHC.request("\(Constants.Urls.studentInfoUrl)/\(uniqueId)", method: .get, params: param, headers: headers, shouldShowHUD: false, success: { response in
//                guard let data = response.dictionaryObject?["data"] as? [String: Any] else { return }
//                let name = "\(data["firstname"] as? String ?? "") \(data["lastname"] as? String ?? "")"
//                    .trimmingCharacters(in: .whitespaces)
//                self.saveContact(ChatContact(name: name,
//                                             subtitle: ChatService.gradeText(data["grade_formatted"] as? String ?? ""),
//                                             picture: data["student_picture"] as? String ?? ""),
//                                 for: uniqueId)
//                completion()
//            }, failure: { _ in })
//        } else {
//            guard !teachersListRequested else { return }
//            teachersListRequested = true
//            let param = [:] as [String: Any]
//            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list", params: param, HTTPMethod: .get)
//            AlamofireHC.request(Constants.Urls.teachersListUrl, method: .get, params: param, headers: headers, shouldShowHUD: false, success: { response in
//                let list = response.dictionaryObject?["data"] as? [[String: Any]] ?? []
//                list.compactMap { TeachersModel(dictionary: $0 as NSDictionary) }.forEach { self.saveContact(teacher: $0) }
//                completion()
//            }, failure: { _ in
//                self.teachersListRequested = false
//            })
//        }
//    }
//
//    // MARK: - Messages
//
//    /// Downloads the room's queued messages, stores them locally and clears the server queue.
//    func syncRoom(_ roomId: String, completion: ((_ savedCount: Int) -> Void)? = nil) {
//        guard !roomId.isEmpty, !syncingRooms.contains(roomId), NetworkManager.shared.isConnected else {
//            completion?(0)
//            return
//        }
//        syncingRooms.insert(roomId)
//
//        let param = [:] as [String: Any]
//        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(roomId)", params: param, HTTPMethod: .get)
//        let url = "\(isTeacher ? Constants.Urls.teacherMsgUrl : Constants.Urls.studentMsgUrl)/\(roomId)"
//
//        AlamofireHC.request(url, method: .get, params: param, headers: headers, shouldShowHUD: false, success: { response in
//            self.syncingRooms.remove(roomId)
//            let result = response.dictionaryObject
//            guard result?["success"] as? Bool ?? false else {
//                completion?(0)
//                return
//            }
//
//            let list = result?["data"] as? [[String: Any]] ?? []
//            var saved = 0
//            for item in list {
//                guard let model = SingleChatModel(dictionary: item as NSDictionary) else { continue }
//                // Own messages are already stored when sent from this device.
//                if self.isOwnMessage(model, roomId: roomId) { continue }
//                self.save(model, fallbackRoomId: roomId)
//                saved += 1
//            }
//
//            // Clear the server queue once, after everything was stored.
//            if saved > 0 {
//                self.deleteServerQueue(roomId)
//                NotificationCenter.default.post(name: .chatMessagesUpdated, object: roomId)
//            }
//            completion?(saved)
//        }, failure: { _ in
//            self.syncingRooms.remove(roomId)
//            completion?(0)
//        })
//    }
//
//    private func deleteServerQueue(_ roomId: String) {
//        let param = [:] as [String: Any]
//        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(roomId)", params: param, HTTPMethod: .delete)
//        let url = "\(isTeacher ? Constants.Urls.teacherMsgDeleteUrl : Constants.Urls.studentMsgDeleteUrl)/\(roomId)"
//        AlamofireHC.request(url, method: .delete, params: param, headers: headers, shouldShowHUD: false, success: { _ in }, failure: { _ in })
//    }
//
//    /// Stores a message in Core Data (deduplicated by message id).
//    func save(_ model: SingleChatModel, fallbackRoomId: String) {
//        let messageId = model.message_id ?? model.id ?? UUID().uuidString
//        CoreDataManager.shared.saveMessage(
//            id: messageId,
//            room_id: model.room_id ?? fallbackRoomId,
//            message_id: messageId,
//            message: model.message ?? "",
//            sender_id: model.sender_id ?? "",
//            sender_name: model.sender_name ?? "",
//            receiver_id: model.receiver_id ?? "",
//            receiver_name: model.receiver_name ?? "",
//            timestamp: model.timestamp ?? Int64(Date().timeIntervalSince1970 * 1000),
//            receiver_model: model.receiver_model ?? "",
//            firstname: model.firstname ?? "",
//            lastname: model.lastname ?? "",
//            grade: model.grade ?? "",
//            section: model.section ?? "",
//            subject: model.subject ?? "",
//            picture: model.picture ?? "",
//            mobile_number: model.mobile_number ?? ""
//        )
//    }
//
//    /// Latest message per room, newest first, for the logged-in user only.
//    func roomSummaries() -> [(roomId: String, last: SingleChatModel, messages: [SingleChatModel])] {
//        var rooms: [String: [SingleChatModel]] = [:]
//        for message in CoreDataManager.shared.getAllMessages() {
//            let room = message.room_id ?? ""
//            guard isMyRoom(room) else { continue }
//            rooms[room, default: []].append(message)
//        }
//        return rooms.compactMap { room, messages in
//            guard let last = messages.max(by: { ($0.timestamp ?? 0) < ($1.timestamp ?? 0) }) else { return nil }
//            return (room, last, messages)
//        }
//        .sorted { ($0.last.timestamp ?? 0) > ($1.last.timestamp ?? 0) }
//    }
//
//    // MARK: - Logout
//
//    /// Removes cached chats and contacts so the next account on this device can't see them.
//    func clearAll() {
//        CoreDataManager.shared.deleteAllMessages()
//        defaults.removeObject(forKey: contactsKey)
//        pendingRoomId = nil
//        teachersListRequested = false
//        resolvingIds.removeAll()
//    }
//
//    // MARK: - Opening a chat (notifications)
//
//    /// Opens the chat for a room. If the tab bar isn't on screen yet (cold launch from a
//    /// notification), the room is kept and opened by `openPendingChatIfNeeded()`.
//    func openChat(roomId: String) {
//        guard !roomId.isEmpty, defaults.bool(forKey: Constants.Keys.isLoggedIn) else { return }
//
//        let top = UIApplication.getTopViewController()
//        if let chat = top as? ChatVC, chat.roomID == roomId {
//            chat.refreshMessages()
//            return
//        }
//        guard let nav = top?.navigationController, top?.tabBarController != nil else {
//            pendingRoomId = roomId
//            return
//        }
//        pendingRoomId = nil
//        let storyboard = UIStoryboard(name: Constants.StoryboardIds.mainSb, bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC else { return }
//        vc.chatListroomID = roomId
//        vc.comingFrom = "chatList"
//        vc.hidesBottomBarWhenPushed = true
//        nav.pushViewController(vc, animated: true)
//    }
//
//    func openPendingChatIfNeeded() {
//        guard let roomId = pendingRoomId else { return }
//        pendingRoomId = nil
//        DispatchQueue.main.async { self.openChat(roomId: roomId) }
//    }
//}
