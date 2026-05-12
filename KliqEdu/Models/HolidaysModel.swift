//
//  HolidaysModel.swift
//  KliqEdu
//
//  Created by codegama on 03/05/26.
//

import Foundation

public class HolidaysModel {
    public var name: String?
    public var month: String?
    public var year: String?
    public var date: String?
    public var day: String?

    

    // Init from dictionary
    required public init?(dictionary: NSDictionary) {
       
        name = dictionary["name"] as? String
        month = dictionary["month"] as? String
        year = dictionary["year"] as? String
        date = dictionary["date"] as? String
        day = dictionary["day"] as? String

    }

    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [HolidaysModel] {
        var models: [HolidaysModel] = []
        for item in array {
            if let model = HolidaysModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }
        return models
    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.name, forKey: "name")
        dictionary.setValue(self.month, forKey: "month")
        dictionary.setValue(self.year, forKey: "year")
        dictionary.setValue(self.date, forKey: "date")
        dictionary.setValue(self.day, forKey: "day")

        return dictionary
    }
}

