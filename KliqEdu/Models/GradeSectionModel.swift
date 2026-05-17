//
//  GradeSectionModel.swift
//  KliqEdu
//
//  Created by codegama on 17/05/26.
//

import Foundation

public class GradeSectionModel {
    public var name: String?
    public var unique_id: String?
 


    // Init from dictionary
    required public init?(dictionary: NSDictionary) {
       
        name = dictionary["name"] as? String
        unique_id = dictionary["unique_id"] as? String
       
    }

    // Convert back to dictionary
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.name, forKey: "name")
        dictionary.setValue(self.unique_id, forKey: "unique_id")
       
        return dictionary
    }
    // Init array of models from NSArray
    public class func modelsFromDictionaryArray(array: NSArray) -> [GradeSectionModel] {
        var models: [GradeSectionModel] = []
        for item in array {
            if let model = GradeSectionModel(dictionary: item as! NSDictionary) {
                models.append(model)
            }
        }
        return models
    }
}

