//
//  TimeTableModel.swift
//  KliqEdu
//
//  Created by codegama on 07/08/26.
//

import Foundation

public class TimeTableModel {
    public var firstname: String?
    public var lastname: String?
    public var grade: String?
    public var section: String?
    public var picture: String?
    public var unique_id: String?

    // Init from dictionary
    required public init?(dictionary: NSDictionary) {
       
        firstname = dictionary["firstname"] as? String
        lastname = dictionary["lastname"] as? String
        grade = dictionary["grade"] as? String
        section = dictionary["section"] as? String
        picture = dictionary["picture"] as? String
        unique_id = dictionary["unique_id"] as? String
       
    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.firstname, forKey: "firstname")
        dictionary.setValue(self.lastname, forKey: "lastname")
        dictionary.setValue(self.grade, forKey: "grade")
        dictionary.setValue(self.section, forKey: "section")
        dictionary.setValue(self.picture, forKey: "picture")
        dictionary.setValue(self.unique_id, forKey: "unique_id")
       
        return dictionary
    }
    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [TimeTableModel] {
        var models: [TimeTableModel] = []
        for item in array {
            if let model = TimeTableModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }
        return models
    }
}
