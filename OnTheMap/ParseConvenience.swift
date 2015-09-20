//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/17/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit
import Foundation

extension ParseClient {
    
    //MARK: Student Location Methods
    
    func getStudentLocation(completionHandler: (result: [StudentLocation]?, error: NSError?) -> Void)
    {
        //specify parameters and method
        let parameters = [
            ParseClient.ParameterKeys.Limit: "\(100)",
            ParseClient.ParameterKeys.Skip: "\(0)",
            ParseClient.ParameterKeys.Order: "-updatedAt"
        ]
        
        let method : String = Methods.StudentLocation + "?"
        
        //make the request
        taskForGetMethod(method, parameters: parameters) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                completionHandler(result: nil, error: error)
            }
            else
            {
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]]
                {
                    var locations = StudentLocation.locationsFromResults(results)
                    
                    completionHandler(result: locations, error: nil)
                }
                else
                {
                    println("Error parsing getStudentLocation -- couldn't find results string in json result")
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not parse getStudentLocation"]))
                }
            }
        }
    }
    
    func postStudentLocation(location: StudentLocation, completionHandler: (result: String?, error: NSError?) -> Void)
    {
        //specify method and HTTP body
        let method : String = Methods.StudentLocation
        
        let jsonBody: [String : AnyObject] = [
            ParseClient.JSONBodyKeys.UniqueKey: location.uniqueKey,
            ParseClient.JSONBodyKeys.FirstName: location.firstName,
            ParseClient.JSONBodyKeys.LastName: location.lastName,
            ParseClient.JSONBodyKeys.MapString: location.mapString,
            ParseClient.JSONBodyKeys.MediaURL: location.mediaURL! as String,
            ParseClient.JSONBodyKeys.Latitude: location.latitude! as Double,
            ParseClient.JSONBodyKeys.Longitude: location.longitude! as Double
        ]
        
        //make the request
        taskForPostMethod(method, jsonBody: jsonBody) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                println("error from post method \(error)")
                completionHandler(result: nil, error: error)
            }
            else
            {
                if let objectID = JSONResult.valueForKey(ParseClient.JSONResponseKeys.ObjectID) as? String
                {
                    if let createdAt = JSONResult.valueForKey(ParseClient.JSONResponseKeys.CreatedAt) as? String
                    {
                        println("Student Location Posted \(objectID) \(createdAt)")
                        
                        completionHandler(result: objectID, error: nil)
                    }
                    else
                    {
                        println("Error parsing postStudentLocation -- couldn't find createdAt in json result")
                        completionHandler(result: nil, error: NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "couldn't find createdAt key in result"]))
                    }
                }
                else
                {
                    println("Error parsing postStudentLocation -- couldn't find objectID in json result")
                    completionHandler(result: nil, error: NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "couldn't find objectID key in result"]))
                }
            }
        }
    }
    
}