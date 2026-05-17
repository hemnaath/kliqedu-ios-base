//
//  ProfileModel.swift
//  KliqEdu
//
//  Created by codegama on 11/05/26.
//

import Foundation

public class ProfileModel {

    public var firstname: String?
    public var lastname: String?
    public var email: String?
    public var mobile: String?
    public var address: String?
    public var emergency_contact: String?
    public var qualification: String?
    public var blood_group: String?
    public var age: Int?
    public var total_experience: String?
    public var gender: String?
    public var dob: String?
    public var father_name: String?
    public var position: String?
    public var religion: String?
    public var picture: String?
    public var class_teacher: String?
    public var unique_id: String?
    public var join_date: String?
    public var department: String?
    public var caste: String?

    public var mother_name: String?
    public var father_mobile: String?
    public var mother_mobile: String?
    public var father_occupation: String?
    public var mother_occupation: String?
    public var total_children: Int?

    // Init from dictionary
    required public init?(dictionary: NSDictionary) {

        firstname = dictionary["firstname"] as? String
        lastname = dictionary["lastname"] as? String
        email = dictionary["email"] as? String
        mobile = dictionary["mobile"] as? String
        address = dictionary["address"] as? String
        emergency_contact = dictionary["emergency_contact"] as? String
        qualification = dictionary["qualification"] as? String
        blood_group = dictionary["blood_group"] as? String
        age = dictionary["age"] as? Int
        total_experience = dictionary["total_experience"] as? String
        gender = dictionary["gender"] as? String
        dob = dictionary["dob"] as? String
        father_name = dictionary["father_name"] as? String
        position = dictionary["position"] as? String
        religion = dictionary["religion"] as? String
        picture = dictionary["picture"] as? String
        class_teacher = dictionary["class_teacher"] as? String
        unique_id = dictionary["unique_id"] as? String
        join_date = dictionary["join_date"] as? String
        department = dictionary["department"] as? String
        caste = dictionary["caste"] as? String

        mother_name = dictionary["mother_name"] as? String
        father_mobile = dictionary["father_mobile"] as? String
        mother_mobile = dictionary["mother_mobile"] as? String
        father_occupation = dictionary["father_occupation"] as? String
        mother_occupation = dictionary["mother_occupation"] as? String
        total_children = dictionary["total_children"] as? Int

    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.firstname, forKey: "firstname")
        dictionary.setValue(self.lastname, forKey: "lastname")
        dictionary.setValue(self.email, forKey: "email")
        dictionary.setValue(self.mobile, forKey: "mobile")
        dictionary.setValue(self.address, forKey: "address")
        dictionary.setValue(self.emergency_contact, forKey: "emergency_contact")
        dictionary.setValue(self.qualification, forKey: "qualification")
        dictionary.setValue(self.blood_group, forKey: "blood_group")
        dictionary.setValue(self.age, forKey: "age")
        dictionary.setValue(self.total_experience, forKey: "total_experience")
        dictionary.setValue(self.gender, forKey: "gender")
        dictionary.setValue(self.dob, forKey: "dob")
        dictionary.setValue(self.father_name, forKey: "father_name")
        dictionary.setValue(self.position, forKey: "position")
        dictionary.setValue(self.religion, forKey: "religion")
        dictionary.setValue(self.picture, forKey: "picture")
        dictionary.setValue(self.class_teacher, forKey: "class_teacher")
        dictionary.setValue(self.unique_id, forKey: "unique_id")
        dictionary.setValue(self.join_date, forKey: "join_date")
        dictionary.setValue(self.department, forKey: "department")
        dictionary.setValue(self.caste, forKey: "caste")
        dictionary.setValue(self.mother_name, forKey: "mother_name")
        dictionary.setValue(self.father_mobile, forKey: "father_mobile")
        dictionary.setValue(self.mother_mobile, forKey: "mother_mobile")
        dictionary.setValue(self.father_occupation, forKey: "father_occupation")
        dictionary.setValue(self.mother_occupation, forKey: "mother_occupation")
        dictionary.setValue(self.total_children, forKey: "total_children")

        return dictionary
    }

    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [ProfileModel] {

        var models: [ProfileModel] = []

        for item in array {
            if let model = ProfileModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }

        return models
    }
}
