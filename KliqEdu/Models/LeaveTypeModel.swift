//
//  LeaveTypeModel.swift
//  KliqEdu
//
//  Created by codegama on 11/05/26.
//

import Foundation

public class LeaveTypeModel {
    public var full_name: String?
    public var unique_id: String?
    public var studentClass: String?
    public var student_picture: String?
   

    // Init from dictionary
    required public init?(dictionary: NSDictionary) {
       
        full_name = dictionary["full_name"] as? String
        unique_id = dictionary["unique_id"] as? String
        studentClass = dictionary["class"] as? String
        student_picture = dictionary["student_picture"] as? String

    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.full_name, forKey: "full_name")
        dictionary.setValue(self.unique_id, forKey: "unique_id")
        dictionary.setValue(self.studentClass, forKey: "class")
        dictionary.setValue(self.student_picture, forKey: "student_picture")

        return dictionary
    }
    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [LeaveTypeModel] {
        var models: [LeaveTypeModel] = []
        for item in array {
            if let model = LeaveTypeModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }
        return models
    }
}

