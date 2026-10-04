//
//  WorkloadModel.swift
//  KliqEdu
//

import Foundation

/// A grade/section + subject the teacher is allocated to
/// (`class_subject_allocations` in the teacher profile response).
struct SubjectAllocation {
    let gradeId: String
    let grade: String
    let sectionId: String
    let section: String
    let subjectId: String
    let subject: String

    init(dictionary: NSDictionary) {
        gradeId = dictionary["grade_id"] as? String ?? ""
        grade = dictionary["grade"] as? String ?? ""
        sectionId = dictionary["section_id"] as? String ?? ""
        section = dictionary["section"] as? String ?? ""
        subjectId = dictionary["subject_id"] as? String ?? ""
        subject = dictionary["subject"] as? String ?? ""
    }

    /// "Grade 5" or "Grade 5 · Section A" (the API sends "N/A" when there is no section).
    var gradeSectionText: String {
        TeacherWorkload.gradeSectionText(grade: grade, section: section)
    }
}

/// Weekly workload, subject allocations and class-teacher mapping from the teacher profile response.
struct TeacherWorkload {
    let allocations: [SubjectAllocation]
    let teachingHours: Double
    let operationalHours: Double
    let totalHours: Double
    let teachingPercentage: Double
    let operationalPercentage: Double
    let classTeacherGradeId: String
    let classTeacherGrade: String
    let classTeacherSectionId: String
    let classTeacherSection: String

    init(dictionary: NSDictionary) {
        let allocationList = dictionary["class_subject_allocations"] as? [NSDictionary] ?? []
        allocations = allocationList.map { SubjectAllocation(dictionary: $0) }

        teachingHours = TeacherWorkload.number(dictionary["teaching_hours"])
        operationalHours = TeacherWorkload.number(dictionary["operational_hours"])
        let total = TeacherWorkload.number(dictionary["total_workload_hours"])
        totalHours = total > 0 ? total : teachingHours + operationalHours

        // Prefer the percentages sent by the API, fall back to calculating them.
        let teachingPercent = TeacherWorkload.number(dictionary["teaching_workload_percentage"])
        let operationalPercent = TeacherWorkload.number(dictionary["operational_workload_percentage"])
        if teachingPercent + operationalPercent > 0 {
            teachingPercentage = teachingPercent
            operationalPercentage = operationalPercent
        } else if totalHours > 0 {
            teachingPercentage = teachingHours / totalHours * 100
            operationalPercentage = operationalHours / totalHours * 100
        } else {
            teachingPercentage = 0
            operationalPercentage = 0
        }

        let mapping = dictionary["classTeacherMapping"] as? NSDictionary
        classTeacherGradeId = mapping?["gradeId"] as? String ?? ""
        classTeacherGrade = mapping?["grade"] as? String ?? ""
        classTeacherSectionId = mapping?["sectionId"] as? String ?? ""
        classTeacherSection = mapping?["section"] as? String ?? ""
    }

    var isClassTeacher: Bool { !classTeacherGrade.isEmpty }

    var classTeacherText: String {
        "Class Teacher · " + TeacherWorkload.gradeSectionText(grade: classTeacherGrade, section: classTeacherSection)
    }

    /// True when the allocation is for the class this teacher is class teacher of.
    func isClassTeacherClass(_ allocation: SubjectAllocation) -> Bool {
        guard isClassTeacher, allocation.gradeId == classTeacherGradeId else { return false }
        return allocation.sectionId == classTeacherSectionId
    }

    static func gradeSectionText(grade: String, section: String) -> String {
        let trimmedSection = section.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedSection.isEmpty || trimmedSection.uppercased() == "N/A" {
            return "Grade \(grade)"
        }
        return "Grade \(grade) - \(trimmedSection)"
    }

    /// Hours/percentages may arrive as Int, Double or String.
    private static func number(_ value: Any?) -> Double {
        if let number = value as? NSNumber { return number.doubleValue }
        if let string = value as? String { return Double(string) ?? 0 }
        return 0
    }
}
