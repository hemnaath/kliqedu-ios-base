//
//  HomeWorkModel.swift
//  KliqEdu
//
//  Created by codegama on 08/05/26.
//

import Foundation

public class HomeWorkModel {
    public var unique_id: String?
    public var title: String?
    public var descriptionValue: String?
    public var audience: String?
    public var grade_id: String?
    public var section_id: String?
    public var grade: String?
    public var section: String?
    public var created_by: String?
    public var created_at: String?
    public var date: String?
    public var subject: String?
    public var group: String?
    public var file: String?
    public var is_editable: Bool?
    public var is_deletable: Bool?

    // Missing fields
    public var subject_id: String?
    public var group_id: String?
    public var grade_name: String?
    public var section_name: String?
    public var subject_name: String?
    public var group_name: String?

    // Init from dictionary
    required public init?(dictionary: NSDictionary) {

        unique_id = dictionary["unique_id"] as? String
        title = dictionary["title"] as? String
        descriptionValue = dictionary["description"] as? String
        audience = dictionary["audience"] as? String
        grade_id = dictionary["grade_id"] as? String
        section_id = dictionary["section_id"] as? String
        grade = dictionary["grade"] as? String
        section = dictionary["section"] as? String
        created_by = dictionary["created_by"] as? String
        created_at = dictionary["created_at"] as? String
        date = dictionary["date"] as? String
        subject = dictionary["subject"] as? String
        group = dictionary["group"] as? String
        file = dictionary["file"] as? String
        is_editable = dictionary["is_editable"] as? Bool
        is_deletable = dictionary["is_deletable"] as? Bool

        // Missing mappings
        subject_id = dictionary["subject_id"] as? String
        group_id = dictionary["group_id"] as? String
        grade_name = dictionary["grade_name"] as? String
        section_name = dictionary["section_name"] as? String
        subject_name = dictionary["subject_name"] as? String
        group_name = dictionary["group_name"] as? String
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
        dictionary.setValue(self.grade, forKey: "grade")
        dictionary.setValue(self.section, forKey: "section")
        dictionary.setValue(self.created_by, forKey: "created_by")
        dictionary.setValue(self.created_at, forKey: "created_at")
        dictionary.setValue(self.date, forKey: "date")
        dictionary.setValue(self.subject, forKey: "subject")
        dictionary.setValue(self.group, forKey: "group")
        dictionary.setValue(self.file, forKey: "file")
        dictionary.setValue(self.is_editable, forKey: "is_editable")
        dictionary.setValue(self.is_deletable, forKey: "is_deletable")

        // Missing mappings
        dictionary.setValue(self.subject_id, forKey: "subject_id")
        dictionary.setValue(self.group_id, forKey: "group_id")
        dictionary.setValue(self.grade_name, forKey: "grade_name")
        dictionary.setValue(self.section_name, forKey: "section_name")
        dictionary.setValue(self.subject_name, forKey: "subject_name")
        dictionary.setValue(self.group_name, forKey: "group_name")

        return dictionary
    }

    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [HomeWorkModel] {
        var models: [HomeWorkModel] = []

        for item in array {
            if let model = HomeWorkModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }

        return models
    }
}
