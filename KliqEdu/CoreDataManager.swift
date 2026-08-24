//
//  CoreDataManager.swift
//  KliqEdu
//
//  Created by codegama on 19/07/26.
//

import Foundation
import CoreData
import UIKit

final class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {}

    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    // MARK: - Save Message

    func saveMessage(
        id: String = UUID().uuidString,
        room_id: String,
        message_id: String = "",
        message: String,
        sender_id: String,
        sender_name: String = "",
        receiver_id: String,
        receiver_name: String = "",
        timestamp: Int64,
        receiver_model: String = "",
        firstname: String = "",
        lastname: String = "",
        grade: String = "",
        section: String = "",
        subject: String = "",
        picture: String = "",
        mobile_number: String = ""
    ) {

        let request: NSFetchRequest<ChatMessage> =
            ChatMessage.fetchRequest()

        // Use message_id to prevent duplicate messages
        if !message_id.isEmpty {

            request.predicate = NSPredicate(
                format: "message_id == %@",
                message_id
            )

        } else {

            request.predicate = NSPredicate(
                format: "id == %@",
                id
            )
        }

        request.fetchLimit = 1

        do {

            // MARK: - Existing Message

            if let existingMessage = try context.fetch(request).first {

                existingMessage.id = id
                existingMessage.room_id = room_id
                existingMessage.message_id = message_id
                existingMessage.message = message
                existingMessage.sender_id = sender_id
                existingMessage.sender_name = sender_name
                existingMessage.receiver_id = receiver_id
                existingMessage.receiver_name = receiver_name
                existingMessage.receiver_model = receiver_model
                existingMessage.timestamp = timestamp

                existingMessage.firstname = firstname
                existingMessage.lastname = lastname
                existingMessage.grade = grade
                existingMessage.section = section
                existingMessage.subject = subject
                existingMessage.picture = picture
                existingMessage.mobile_number = mobile_number

                // Existing field from your old model
                existingMessage.senderName = sender_name

                saveContext()

                print("Updated existing message: \(message_id)")

                return
            }

        } catch {

            print(
                "CoreData duplicate check error:",
                error.localizedDescription
            )
        }

        // MARK: - New Message

        let chat = ChatMessage(context: context)

        chat.id = id
        chat.room_id = room_id
        chat.message_id = message_id
        chat.message = message

        chat.sender_id = sender_id
        chat.sender_name = sender_name

        // Existing field
        chat.senderName = sender_name

        chat.receiver_id = receiver_id
        chat.receiver_name = receiver_name
        chat.receiver_model = receiver_model

        chat.timestamp = timestamp

        // MARK: - User Details

        chat.firstname = firstname
        chat.lastname = lastname
        chat.grade = grade
        chat.section = section
        chat.subject = subject
        chat.picture = picture
        chat.mobile_number = mobile_number

        saveContext()

        print("""
        
        ==============================
        MESSAGE SAVED TO CORE DATA
        ==============================
        id              : \(id)
        room_id         : \(room_id)
        message_id      : \(message_id)
        message         : \(message)
        sender_id       : \(sender_id)
        sender_name     : \(sender_name)
        receiver_id     : \(receiver_id)
        receiver_name   : \(receiver_name)
        receiver_model  : \(receiver_model)
        timestamp       : \(timestamp)

        firstname       : \(firstname)
        lastname        : \(lastname)
        grade           : \(grade)
        section         : \(section)
        subject         : \(subject)
        picture         : \(picture)
        mobile_number   : \(mobile_number)
        ==============================
        """)
    }

    // MARK: - Get Messages

    func getMessages(room_id: String) -> [SingleChatModel] {

        let request: NSFetchRequest<ChatMessage> =
            ChatMessage.fetchRequest()

        request.predicate = NSPredicate(
            format: "room_id == %@",
            room_id
        )

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "timestamp",
                ascending: false
            )
        ]

        do {

            let data = try context.fetch(request)

            var messages: [SingleChatModel] = []

            for item in data {

                if let model = createModel(from: item) {
                    messages.append(model)
                }
            }

            return messages

        } catch {

            print(
                "CoreData getMessages error:",
                error.localizedDescription
            )

            return []
        }
    }

    // MARK: - Get All Messages

    func getAllMessages() -> [SingleChatModel] {

        let request: NSFetchRequest<ChatMessage> =
            ChatMessage.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "timestamp",
                ascending: false
            )
        ]

        do {

            let result = try context.fetch(request)

            var messages: [SingleChatModel] = []

            for item in result {

                if let model = createModel(from: item) {
                    messages.append(model)
                }
            }

            return messages

        } catch {

            print(
                "CoreData getAllMessages error:",
                error.localizedDescription
            )

            return []
        }
    }

    // MARK: - Create Model

    private func createModel(
        from item: ChatMessage
    ) -> SingleChatModel? {

        var dict: [String: Any] = [:]

        // MARK: - Message

        dict["id"] = item.id ?? ""

        dict["room_id"] = item.room_id ?? ""

        dict["message_id"] = item.message_id ?? ""

        dict["message"] = item.message ?? ""

        // MARK: - Sender

        dict["sender_id"] = item.sender_id ?? ""

        dict["sender_name"] = item.sender_name
            ?? item.senderName
            ?? ""

        // Keep compatibility
        dict["senderName"] = item.senderName
            ?? item.sender_name
            ?? ""

        // MARK: - Receiver

        dict["receiver_id"] = item.receiver_id ?? ""

        dict["receiver_name"] =
            item.receiver_name ?? ""

        dict["receiver_model"] =
            item.receiver_model ?? ""

        // MARK: - Timestamp

        dict["timestamp"] = item.timestamp

        // MARK: - User Details

        dict["firstname"] =
            item.firstname ?? ""

        dict["lastname"] =
            item.lastname ?? ""

        dict["grade"] =
            item.grade ?? ""

        dict["section"] =
            item.section ?? ""

        dict["subject"] =
            item.subject ?? ""

        dict["picture"] =
            item.picture ?? ""

        dict["mobile_number"] =
            item.mobile_number ?? ""

        return SingleChatModel(
            dictionary: dict as NSDictionary
        )
    }

    // MARK: - Delete One Message

    func deleteMessage(id: String) {

        let request: NSFetchRequest<ChatMessage> =
            ChatMessage.fetchRequest()

        request.predicate = NSPredicate(
            format: "id == %@",
            id
        )

        do {

            let data = try context.fetch(request)

            for item in data {
                context.delete(item)
            }

            saveContext()

        } catch {

            print(
                "CoreData deleteMessage error:",
                error.localizedDescription
            )
        }
    }

    // MARK: - Delete Room

    func deleteRoom(room_id: String) {

        let request: NSFetchRequest<ChatMessage> =
            ChatMessage.fetchRequest()

        request.predicate = NSPredicate(
            format: "room_id == %@",
            room_id
        )

        do {

            let data = try context.fetch(request)

            for item in data {
                context.delete(item)
            }

            saveContext()

        } catch {

            print(
                "CoreData deleteRoom error:",
                error.localizedDescription
            )
        }
    }

    // MARK: - Delete All

    func deleteAllMessages() {

        let request:
            NSFetchRequest<NSFetchRequestResult> =
            ChatMessage.fetchRequest()

        let deleteRequest =
            NSBatchDeleteRequest(
                fetchRequest: request
            )

        do {

            try context.execute(deleteRequest)

            saveContext()

        } catch {

            print(
                "CoreData deleteAllMessages error:",
                error.localizedDescription
            )
        }
    }

    // MARK: - Save Context

    func saveContext() {

        if context.hasChanges {

            do {

                try context.save()

            } catch {

                print(
                    "CoreData saveContext error:",
                    error.localizedDescription
                )
            }
        }
    }
}
