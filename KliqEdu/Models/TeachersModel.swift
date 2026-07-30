//
//  TeachersModel.swift
//  KliqEdu
//
//  Created by codegama on 03/05/26.
//

import Foundation

public class TeachersModel {
    public var full_name: String?
    public var subject: String?
    public var mobile: String?
    public var teacher_picture: String?
    public var email: String?
    public var unique_id: String?


    // Init from dictionary
    required public init?(dictionary: NSDictionary) {
       
        full_name = dictionary["full_name"] as? String
        subject = dictionary["subject"] as? String
        mobile = dictionary["mobile"] as? String
        teacher_picture = dictionary["teacher_picture"] as? String
        email = dictionary["email"] as? String
        unique_id = dictionary["unique_id"] as? String

    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.full_name, forKey: "full_name")
        dictionary.setValue(self.subject, forKey: "subject")
        dictionary.setValue(self.mobile, forKey: "mobile")
        dictionary.setValue(self.teacher_picture, forKey: "teacher_picture")
        dictionary.setValue(self.email, forKey: "email")
        dictionary.setValue(self.unique_id, forKey: "unique_id")

        return dictionary
    }
    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [TeachersModel] {
        var models: [TeachersModel] = []
        for item in array {
            if let model = TeachersModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }
        return models
    }
}

