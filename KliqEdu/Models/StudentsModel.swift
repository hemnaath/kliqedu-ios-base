//
//  StudentsModel.swift
//  KliqEdu
//
//  Created by codegama on 03/05/26.
//

import Foundation

public class StudentsModel {
    public var full_name: String?
    public var first_name: String?
    public var last_name: String?
    public var grade: String?
    public var section: String?
    public var unique_id: String?
    public var studentClass: String?
    public var student_picture: String?
   

    // Init from dictionary
    required public init?(dictionary: NSDictionary) {
       
        full_name = dictionary["full_name"] as? String
        first_name = dictionary["first_name"] as? String
        last_name = dictionary["last_name"] as? String
        grade = dictionary["grade"] as? String
        section = dictionary["section"] as? String
        unique_id = dictionary["unique_id"] as? String
        studentClass = dictionary["class"] as? String
        student_picture = dictionary["student_picture"] as? String

    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.full_name, forKey: "full_name")
        dictionary.setValue(self.first_name, forKey: "first_name")
        dictionary.setValue(self.last_name, forKey: "last_name")
        dictionary.setValue(self.grade, forKey: "grade")
        dictionary.setValue(self.section, forKey: "section")
        dictionary.setValue(self.unique_id, forKey: "unique_id")
        dictionary.setValue(self.studentClass, forKey: "class")
        dictionary.setValue(self.student_picture, forKey: "student_picture")

        return dictionary
    }
    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [StudentsModel] {
        var models: [StudentsModel] = []
        for item in array {
            if let model = StudentsModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }
        return models
    }
}

