//
//  FeesModel.swift
//  KliqEdu
//
//  Created by codegama on 07/05/26.
//

import Foundation

public class FeesModel {
    public var student_unique_id: String?
    public var student_name: String?
    public var student_grade: String?
    public var student_section: String?
    public var fee_type: String?
    public var due_date: String?
    public var status: String?
    public var paid_amount: String?
    public var remaining_amount: String?
    public var unique_id: String?


    // Init from dictionary
    required public init?(dictionary: NSDictionary) {

        if let student = dictionary["student"] as? NSDictionary {
            student_unique_id = student["unique_id"] as? String
            student_name = student["name"] as? String
            student_grade = student["grade"] as? String
            student_section = student["section"] as? String
        }

        fee_type = dictionary["fee_type"] as? String
        due_date = dictionary["due_date"] as? String
        status = dictionary["status"] as? String
        paid_amount = dictionary["paid_amount"] as? String
        remaining_amount = dictionary["remaining_amount"] as? String
        unique_id = dictionary["unique_id"] as? String

    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        let studentDict = NSMutableDictionary()
        studentDict.setValue(self.student_unique_id, forKey: "unique_id")
        studentDict.setValue(self.student_name, forKey: "name")
        studentDict.setValue(self.student_grade, forKey: "grade")
        studentDict.setValue(self.student_section, forKey: "section")

        dictionary.setValue(studentDict, forKey: "student")
        dictionary.setValue(self.fee_type, forKey: "fee_type")
        dictionary.setValue(self.due_date, forKey: "due_date")
        dictionary.setValue(self.status, forKey: "status")
        dictionary.setValue(self.paid_amount, forKey: "paid_amount")
        dictionary.setValue(self.remaining_amount, forKey: "remaining_amount")
        dictionary.setValue(self.unique_id, forKey: "unique_id")

        return dictionary
    }
    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [FeesModel] {
        var models: [FeesModel] = []
        for item in array {
            if let model = FeesModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }
        return models
    }
}
