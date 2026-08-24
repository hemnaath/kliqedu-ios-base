//
//  ChatMessage+CoreDataProperties.swift
//  
//
//  Created by codegama on 10/08/26.
//
//

public import Foundation
public import CoreData


public typealias ChatMessageCoreDataPropertiesSet = NSSet

extension ChatMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatMessage> {
        return NSFetchRequest<ChatMessage>(entityName: "ChatMessage")
    }

    @NSManaged public var id: String?
    @NSManaged public var message: String?
    @NSManaged public var receiver_id: String?
    @NSManaged public var room_id: String?
    @NSManaged public var sender_id: String?
    @NSManaged public var senderName: String?
    @NSManaged public var timestamp: Int64
    @NSManaged public var message_id: String?
    @NSManaged public var receiver_name: String?
    @NSManaged public var sender_name: String?
    @NSManaged public var receiver_model: String?
    @NSManaged public var firstname: String?
    @NSManaged public var lastname: String?
    @NSManaged public var grade: String?
    @NSManaged public var section: String?
    @NSManaged public var subject: String?
    @NSManaged public var picture: String?
    @NSManaged public var mobile_number: String?

}
