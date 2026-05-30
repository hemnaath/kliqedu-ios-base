//
//  ChildrensModel.swift
//  KliqEdu
//
//  Created by codegama on 19/05/26.
//

import Foundation

public class ChildrensModel {
    public var firstname: String?
    public var lastname: String?
    public var religion: String?
    public var group_id: String?
    public var status: Int?
    public var dob: String?
    public var picture: String?
    public var parent_id: String?
    public var unique_id: String?
    public var createdAt: String?
    public var section_id: String?
    public var join_date: String?
    public var caste: String?
    public var blood_group: String?
    public var updatedAt: String?
    public var gender: Int?
    public var org_id: String?
    public var roll_number: String?
    public var age: Int?
    public var grade_id: String?

    // Init from dictionary
    required public init?(dictionary: NSDictionary) {
       
        firstname = dictionary["firstname"] as? String
        lastname = dictionary["lastname"] as? String
        religion = dictionary["religion"] as? String
        group_id = dictionary["group_id"] as? String
        status = dictionary["status"] as? Int
        dob = dictionary["dob"] as? String
        picture = dictionary["picture"] as? String
        parent_id = dictionary["parent_id"] as? String
        unique_id = dictionary["unique_id"] as? String
        createdAt = dictionary["createdAt"] as? String
        section_id = dictionary["section_id"] as? String
        join_date = dictionary["join_date"] as? String
        caste = dictionary["caste"] as? String
        blood_group = dictionary["blood_group"] as? String
        updatedAt = dictionary["updatedAt"] as? String
        gender = dictionary["gender"] as? Int
        org_id = dictionary["org_id"] as? String
        roll_number = dictionary["roll_number"] as? String
        age = dictionary["age"] as? Int
        grade_id = dictionary["grade_id"] as? String
       
    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.firstname, forKey: "firstname")
        dictionary.setValue(self.lastname, forKey: "lastname")
        dictionary.setValue(self.religion, forKey: "religion")
        dictionary.setValue(self.group_id, forKey: "group_id")
        dictionary.setValue(self.status, forKey: "status")
        dictionary.setValue(self.dob, forKey: "dob")
        dictionary.setValue(self.picture, forKey: "picture")
        dictionary.setValue(self.parent_id, forKey: "parent_id")
        dictionary.setValue(self.unique_id, forKey: "unique_id")
        dictionary.setValue(self.createdAt, forKey: "createdAt")
        dictionary.setValue(self.section_id, forKey: "section_id")
        dictionary.setValue(self.join_date, forKey: "join_date")
        dictionary.setValue(self.caste, forKey: "caste")
        dictionary.setValue(self.blood_group, forKey: "blood_group")
        dictionary.setValue(self.updatedAt, forKey: "updatedAt")
        dictionary.setValue(self.gender, forKey: "gender")
        dictionary.setValue(self.org_id, forKey: "org_id")
        dictionary.setValue(self.roll_number, forKey: "roll_number")
        dictionary.setValue(self.age, forKey: "age")
        dictionary.setValue(self.grade_id, forKey: "grade_id")
       
        return dictionary
    }
    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [ChildrensModel] {
        var models: [ChildrensModel] = []
        for item in array {
            if let model = ChildrensModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }
        return models
    }
}
