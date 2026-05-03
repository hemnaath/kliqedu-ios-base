//
//  AnnouncementModel.swift
//  KliqEdu
//
//  Created by codegama on 03/05/26.
//

import Foundation

public class AnnouncementModel {
    public var unique_id: String?
    public var title: String?
    public var descriptionValue: String?
    public var audience: String?
    public var grade_id: String?
    public var section_id: String?
    public var created_by: String?
    public var created_at: String?


    // Init from dictionary
    required public init?(dictionary: NSDictionary) {
       
        unique_id = dictionary["unique_id"] as? String
        title = dictionary["title"] as? String
        descriptionValue = dictionary["description"] as? String
        audience = dictionary["audience"] as? String
        grade_id = dictionary["grade_id"] as? String
        section_id = dictionary["section_id"] as? String
        created_by = dictionary["created_by"] as? String
        created_at = dictionary["created_at"] as? String

    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.unique_id, forKey: "unique_id")
        dictionary.setValue(self.title, forKey: "title")
        dictionary.setValue(self.descriptionValue, forKey: "description")
        dictionary.setValue(self.audience, forKey: "audience")
        dictionary.setValue(self.grade_id, forKey: "grade_id")
        dictionary.setValue(self.section_id, forKey: "section_id")
        dictionary.setValue(self.created_by, forKey: "created_by")
        dictionary.setValue(self.created_at, forKey: "created_at")

        return dictionary
    }
    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [AnnouncementModel] {
        var models: [AnnouncementModel] = []
        for item in array {
            if let model = AnnouncementModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }
        return models
    }
}
