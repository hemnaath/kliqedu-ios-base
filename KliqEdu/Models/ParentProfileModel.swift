//
//  ParentProfileModel.swift
//  KliqEdu
//
//  Created by codegama on 12/05/26.
//

import Foundation

public class ParentProfileModel {

    // Parent Profile
    public var father_name: String?
    public var mother_name: String?
    public var father_mobile: String?
    public var mother_mobile: String?
    public var father_occupation: String?
    public var mother_occupation: String?
    public var email: String?
    public var address: String?
    public var emergency_contact: String?
    public var unique_id: String?
    public var picture: String?
    public var total_children: Int?

    // Student Profile
    public var firstname: String?
    public var lastname: String?
    public var age: Int?
    public var dob: String?
    public var religion: String?
    public var group: String?
    public var blood_group: String?
    public var caste: String?
    public var roll_number: String?
    public var grade: String?
    public var gender: String?

    // Init from dictionary
    required public init?(dictionary: NSDictionary) {

        // Parent
        father_name = dictionary["father_name"] as? String
        mother_name = dictionary["mother_name"] as? String
        father_mobile = dictionary["father_mobile"] as? String
        mother_mobile = dictionary["mother_mobile"] as? String
        father_occupation = dictionary["father_occupation"] as? String
        mother_occupation = dictionary["mother_occupation"] as? String
        email = dictionary["email"] as? String
        address = dictionary["address"] as? String
        emergency_contact = dictionary["emergency_contact"] as? String
        unique_id = dictionary["unique_id"] as? String
        picture = dictionary["picture"] as? String
        total_children = dictionary["total_children"] as? Int

        // Student
        firstname = dictionary["firstname"] as? String
        lastname = dictionary["lastname"] as? String
        age = dictionary["age"] as? Int
        dob = dictionary["dob"] as? String
        religion = dictionary["religion"] as? String
        group = dictionary["group"] as? String
        blood_group = dictionary["blood_group"] as? String
        caste = dictionary["caste"] as? String
        roll_number = dictionary["roll_number"] as? String
        grade = dictionary["grade"] as? String
        gender = dictionary["gender"] as? String
    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        // Parent
        dictionary.setValue(self.father_name, forKey: "father_name")
        dictionary.setValue(self.mother_name, forKey: "mother_name")
        dictionary.setValue(self.father_mobile, forKey: "father_mobile")
        dictionary.setValue(self.mother_mobile, forKey: "mother_mobile")
        dictionary.setValue(self.father_occupation, forKey: "father_occupation")
        dictionary.setValue(self.mother_occupation, forKey: "mother_occupation")
        dictionary.setValue(self.email, forKey: "email")
        dictionary.setValue(self.address, forKey: "address")
        dictionary.setValue(self.emergency_contact, forKey: "emergency_contact")
        dictionary.setValue(self.unique_id, forKey: "unique_id")
        dictionary.setValue(self.picture, forKey: "picture")
        dictionary.setValue(self.total_children, forKey: "total_children")

        // Student
        dictionary.setValue(self.firstname, forKey: "firstname")
        dictionary.setValue(self.lastname, forKey: "lastname")
        dictionary.setValue(self.age, forKey: "age")
        dictionary.setValue(self.dob, forKey: "dob")
        dictionary.setValue(self.religion, forKey: "religion")
        dictionary.setValue(self.group, forKey: "group")
        dictionary.setValue(self.blood_group, forKey: "blood_group")
        dictionary.setValue(self.caste, forKey: "caste")
        dictionary.setValue(self.roll_number, forKey: "roll_number")
        dictionary.setValue(self.grade, forKey: "grade")
        dictionary.setValue(self.gender, forKey: "gender")

        return dictionary
    }

    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [ParentProfileModel] {

        var models: [ParentProfileModel] = []

        for item in array {
            if let model = ParentProfileModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }

        return models
    }
}
