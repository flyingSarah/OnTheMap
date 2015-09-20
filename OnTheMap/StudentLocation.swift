//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Sarah on 9/18/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

struct StudentLocation {
    
    var firstName = ""
    var lastName = ""
    var latitude: Double? = nil
    var longitude: Double? = nil
    var mapString = ""
    var mediaURL: String? = nil
    var objectID = ""
    var uniqueKey = ""
    var createdAt = ""
    var updatedAt = ""
    
    //construct a Student Location result from a dictionary
    init(dictionary: [String : AnyObject])
    {
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String
        objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        createdAt = dictionary[ParseClient.JSONResponseKeys.CreatedAt] as! String
        updatedAt = dictionary[ParseClient.JSONResponseKeys.UpdatedAt] as! String
    }
    
    //given an array of dictionaries, convert them to an array of Student Location result objects
    static func locationsFromResults(results: [[String : AnyObject]]) -> [StudentLocation]
    {
        var studentLocations = [StudentLocation]()
        
        for result in results
        {
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
}