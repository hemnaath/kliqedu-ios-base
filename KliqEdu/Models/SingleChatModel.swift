//
//  SingleChatModel.swift
//  OnlyAlly
//
//  Created by Karthick RJ on 17/08/21.
//

import Foundation

public class SingleChatModel {
    public var message : String?
    public var sent_at : String?
    public var sent_by : Int?

   // public var sent_by : Int?
    public var sender_id : String?
    public var receiver_id : String?
    public var room_id : String?
    public var timestamp : Int64?
    public var senderName : String?

    
/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let documentModel_list = DocumentModel.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of DocumentModel Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [SingleChatModel]
    {
        var models:[SingleChatModel] = []
        for item in array
        {
            models.append(SingleChatModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let documentModel = DocumentModel(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: DocumentModel Instance.
*/
    required public init?(dictionary: NSDictionary) {
        
        message = dictionary["message"] as? String
        sent_at = dictionary["sent_at"] as? String
        sent_by = dictionary["sent_by"] as? Int
        sender_id = dictionary["sender_id"] as? String

        receiver_id = dictionary["receiver_id"] as? String
        room_id = dictionary["room_id"] as? String

        senderName = dictionary["sender_name"] as? String
        if senderName == nil {
            senderName = dictionary["senderName"] as? String
        }

        if let value = dictionary["timestamp"] as? Int64 {
            timestamp = value
        } else if let value = dictionary["timestamp"] as? Int {
            timestamp = Int64(value)
        } else if let value = dictionary["timestamp"] as? NSNumber {
            timestamp = value.int64Value
        }

        
        
    }

        
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()
        
      
        dictionary.setValue(self.message, forKey: "message")
        dictionary.setValue(self.sent_at, forKey: "sent_at")
        dictionary.setValue(self.sent_by, forKey: "sent_by")
        dictionary.setValue(self.sender_id, forKey: "sender_id")
        dictionary.setValue(self.receiver_id, forKey: "receiver_id")
        dictionary.setValue(self.room_id, forKey: "room_id")
        dictionary.setValue(self.timestamp, forKey: "timestamp")
        dictionary.setValue(self.senderName, forKey: "senderName")

        return dictionary
    }

}
