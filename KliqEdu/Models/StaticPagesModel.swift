//
//  StaticPagesModel.swift
//  ECommerce
//
//  Created by Karthick RJ on 19/10/22.
//

import Foundation

public class StaticPagesModel {
    public var static_page_id : Int?
    public var title : String?
    public var description : String?
    public var type : String?
    public var status : Int?
    public var created_at : String?
    public var updated_at : String?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let staticPageDataModal_list = StaticPageDataModal.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of StaticPageDataModal Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [StaticPagesModel]
    {
        var models:[StaticPagesModel] = []
        for item in array
        {
            models.append(StaticPagesModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let staticPageDataModal = StaticPageDataModal(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: StaticPageDataModal Instance.
*/
    required public init?(dictionary: NSDictionary) {

        static_page_id = dictionary["static_page_id"] as? Int
        title = dictionary["title"] as? String
        description = dictionary["description"] as? String
        type = dictionary["type"] as? String
        status = dictionary["status"] as? Int
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
    }

        
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.static_page_id, forKey: "static_page_id")
        dictionary.setValue(self.title, forKey: "title")
        dictionary.setValue(self.description, forKey: "description")
        dictionary.setValue(self.type, forKey: "type")
        dictionary.setValue(self.status, forKey: "status")
        dictionary.setValue(self.created_at, forKey: "created_at")
        dictionary.setValue(self.updated_at, forKey: "updated_at")

        return dictionary
    }
}
