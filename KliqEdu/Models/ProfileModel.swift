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
    public var total_experience: Int?
    public var gender: String?
    public var dob: String?
    public var father_name: String?
    public var position: String?
    public var religion: String?
    public var picture: String?

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
        total_experience = dictionary["total_experience"] as? Int
        gender = dictionary["gender"] as? String
        dob = dictionary["dob"] as? String
        father_name = dictionary["father_name"] as? String
        position = dictionary["position"] as? String
        religion = dictionary["religion"] as? String
        picture = dictionary["picture"] as? String
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
