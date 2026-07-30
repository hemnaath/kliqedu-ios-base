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

    func saveMessage(id: String = UUID().uuidString,
                     room_id: String,
                     sender_id: String,
                     receiver_id: String,
                     senderName: String,
                     message: String,
                     timestamp: Int64) {

        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        if let result = try? context.fetch(request),
           result.count > 0 {
            return
        }

        let chat = ChatMessage(context: context)
        chat.id = id
        chat.room_id = room_id
        chat.sender_id = sender_id
        chat.receiver_id = receiver_id
        chat.senderName = senderName
        chat.message = message
        chat.timestamp = timestamp

        saveContext()
    }

    // MARK: - Get Messages

    func getMessages(room_id: String) -> [SingleChatModel] {

        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()

        request.predicate = NSPredicate(format: "room_id == %@", room_id)

        request.sortDescriptors = [
            NSSortDescriptor(key: "timestamp", ascending: false)
        ]

        do {

            let data = try context.fetch(request)

            return data.map {

                let dict: NSDictionary = [
                    "id": $0.id ?? "",
                    "room_id": $0.room_id ?? "",
                    "sender_id": $0.sender_id ?? "",
                    "receiver_id": $0.receiver_id ?? "",
                    "senderName": $0.senderName ?? "",
                    "message": $0.message ?? "",
                    "timestamp": $0.timestamp
                ]

                return SingleChatModel(dictionary: dict)!
            }

        } catch {

            print(error)
            return []
        }
    }
    func getAllMessages() -> [SingleChatModel] {

        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "timestamp", ascending: false)
        ]

        do {
            let result = try context.fetch(request)

            var messages: [SingleChatModel] = []

            for item in result {

                let dict: [String: Any] = [
                    "id": item.id ?? "",
                    "room_id": item.room_id ?? "",
                    "sender_id": item.sender_id ?? "",
                    "receiver_id": item.receiver_id ?? "",
                    "senderName": item.senderName ?? "",
                    "message": item.message ?? "",
                    "timestamp": item.timestamp
                ]

                if let model = SingleChatModel(dictionary: dict as NSDictionary) {
                    messages.append(model)
                }
            }

            return messages

        } catch {
            print("CoreData getAllMessages:", error)
            return []
        }
    }
    // MARK: - Delete One Message

    func deleteMessage(id: String) {

        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()

        request.predicate = NSPredicate(format: "id == %@", id)

        do {

            let data = try context.fetch(request)

            data.forEach {
                context.delete($0)
            }

            saveContext()

        } catch {

            print(error)
        }
    }

    // MARK: - Delete Room

    func deleteRoom(room_id: String) {

        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()

        request.predicate = NSPredicate(format: "room_id == %@", room_id)

        do {

            let data = try context.fetch(request)

            data.forEach {
                context.delete($0)
            }

            saveContext()

        } catch {

            print(error)
        }
    }

    // MARK: - Delete All

    func deleteAllMessages() {

        let request: NSFetchRequest<NSFetchRequestResult> = ChatMessage.fetchRequest()

        let delete = NSBatchDeleteRequest(fetchRequest: request)

        do {

            try context.execute(delete)

        } catch {

            print(error)
        }
    }

    // MARK: - Save Context

    func saveContext() {

        if context.hasChanges {

            do {

                try context.save()

            } catch {

                print(error)
            }
        }
    }
}
