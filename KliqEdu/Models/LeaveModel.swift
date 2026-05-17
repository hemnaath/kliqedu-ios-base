//
//  LeaveModel.swift
//  KliqEdu
//
//  Created by codegama on 11/05/26.
//

import Foundation

public class LeaveModel {

    public var unique_id: String?

    // Student
    public var student_unique_id: String?
    public var student_name: String?
    public var student_grade: String?
    public var student_picture: String?

    // Teacher
    public var teacher_unique_id: String?
    public var teacher_name: String?
    public var teacher_department: String?
    public var teacher_picture: String?

    // Leave Details
    public var leave_type: String?
    public var start_date: String?
    public var end_date: String?
    public var total_days: Double?
    public var reason: String?
    public var status: String?
    public var is_editable: Bool?
    public var is_deletable: Bool?
    public var created_at: String?
    public var is_half_day: Int?

    // Init from dictionary
    required public init?(dictionary: NSDictionary) {

        unique_id = dictionary["unique_id"] as? String

        if let student = dictionary["student"] as? NSDictionary {
            student_unique_id = student["unique_id"] as? String
            student_name = student["full_name"] as? String
            student_grade = student["grade_formatted"] as? String
            student_picture = student["picture"] as? String
        }

        if let teacher = dictionary["teacher"] as? NSDictionary {
            teacher_unique_id = teacher["unique_id"] as? String
            teacher_name = teacher["full_name"] as? String
            teacher_department = teacher["department"] as? String
            teacher_picture = teacher["picture"] as? String
        }

        leave_type = dictionary["leave_type"] as? String
        start_date = dictionary["start_date"] as? String
        end_date = dictionary["end_date"] as? String
        total_days = dictionary["total_days"] as? Double
        reason = dictionary["reason"] as? String
        status = dictionary["status"] as? String
        is_editable = dictionary["is_editable"] as? Bool
        is_deletable = dictionary["is_deletable"] as? Bool
        created_at = dictionary["created_at"] as? String
        is_half_day = dictionary["is_half_day"] as? Int

    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.unique_id, forKey: "unique_id")

        let studentDict = NSMutableDictionary()
        studentDict.setValue(self.student_unique_id, forKey: "unique_id")
        studentDict.setValue(self.student_name, forKey: "full_name")
        studentDict.setValue(self.student_grade, forKey: "grade_formatted")
        studentDict.setValue(self.student_picture, forKey: "picture")

        dictionary.setValue(studentDict, forKey: "student")

        let teacherDict = NSMutableDictionary()
        teacherDict.setValue(self.teacher_unique_id, forKey: "unique_id")
        teacherDict.setValue(self.teacher_name, forKey: "full_name")
        teacherDict.setValue(self.teacher_department, forKey: "department")
        teacherDict.setValue(self.teacher_picture, forKey: "picture")

        dictionary.setValue(teacherDict, forKey: "teacher")

        dictionary.setValue(self.leave_type, forKey: "leave_type")
        dictionary.setValue(self.start_date, forKey: "start_date")
        dictionary.setValue(self.end_date, forKey: "end_date")
        dictionary.setValue(self.total_days, forKey: "total_days")
        dictionary.setValue(self.reason, forKey: "reason")
        dictionary.setValue(self.status, forKey: "status")
        dictionary.setValue(self.is_editable, forKey: "is_editable")
        dictionary.setValue(self.is_deletable, forKey: "is_deletable")
        dictionary.setValue(self.created_at, forKey: "created_at")
        dictionary.setValue(self.is_half_day, forKey: "is_half_day")

        return dictionary
    }

    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [LeaveModel] {

        var models: [LeaveModel] = []

        for item in array {
            if let model = LeaveModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }

        return models
    }
}
