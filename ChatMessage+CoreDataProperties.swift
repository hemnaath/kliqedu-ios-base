//
//  ChatMessage+CoreDataProperties.swift
//  
//
//  Created by codegama on 28/07/26.
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

}
