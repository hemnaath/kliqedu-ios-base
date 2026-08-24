//
//  SingleChatModel.swift
//  OnlyAlly
//
//  Created by Karthick RJ on 17/08/21.
//

import Foundation

import Foundation

class SingleChatModel {

    var id: String?
    var room_id: String?
    
    var message_id: String?
    var message: String?
    
    var sender_id: String?
    var sender_name: String?
    
    var receiver_id: String?
    var receiver_name: String?
    var receiver_model: String?
    
    var timestamp: Int64?
    var updated: String?
    
    // MARK: - User Details
    var firstname: String?
    var lastname: String?
    var grade: String?
    var section: String?
    var subject: String?
    var picture: String?
    var mobile_number: String?

    init?(dictionary: NSDictionary) {

        self.id = dictionary["id"] as? String
        self.room_id = dictionary["room_id"] as? String
        
        self.message_id = dictionary["message_id"] as? String
        self.message = dictionary["message"] as? String
        
        self.sender_id = dictionary["sender_id"] as? String
        self.sender_name = dictionary["sender_name"] as? String
        
        // Support old API key if backend sends senderName
        if self.sender_name == nil {
            self.sender_name = dictionary["senderName"] as? String
        }
        
        self.receiver_id = dictionary["receiver_id"] as? String
        self.receiver_name = dictionary["receiver_name"] as? String
        self.receiver_model = dictionary["receiver_model"] as? String
        
        if let value = dictionary["timestamp"] as? Int64 {
            self.timestamp = value
        } else if let value = dictionary["timestamp"] as? Int {
            self.timestamp = Int64(value)
        } else if let value = dictionary["timestamp"] as? Double {
            self.timestamp = Int64(value)
        } else if let value = dictionary["timestamp"] as? NSNumber {
            self.timestamp = value.int64Value
        } else if let value = dictionary["timestamp"] as? String {
            self.timestamp = Int64(value)
        }
        
        self.updated = dictionary["updated"] as? String
        
        // MARK: - User Details
        
        if let details = dictionary["user_details"] as? NSDictionary {
            
            self.firstname = details["firstname"] as? String ?? ""
            self.lastname = details["lastname"] as? String ?? ""
            self.grade = details["grade"] as? String ?? ""
            self.section = details["section"] as? String ?? ""
            self.subject = details["subject"] as? String ?? ""
            self.picture = details["picture"] as? String ?? ""
            self.mobile_number = details["mobile_number"] as? String ?? ""
            
        } else {
            
            // Also support flat fields when loading from Core Data
            self.firstname = dictionary["firstname"] as? String ?? ""
            self.lastname = dictionary["lastname"] as? String ?? ""
            self.grade = dictionary["grade"] as? String ?? ""
            self.section = dictionary["section"] as? String ?? ""
            self.subject = dictionary["subject"] as? String ?? ""
            self.picture = dictionary["picture"] as? String ?? ""
            self.mobile_number = dictionary["mobile_number"] as? String ?? ""
        }
    }
}
