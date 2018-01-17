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
    
    func getStudentLocation(_ completionHandler: @escaping (_ result: [StudentLocation]?, _ error: NSError?) -> Void)
    {
        //specify parameters and method
        let parameters = [
            ParseClient.ParameterKeys.Limit: "\(100)",
            ParseClient.ParameterKeys.Skip: "\(0)",
            ParseClient.ParameterKeys.Order: "-updatedAt"
        ]
        
        let method : String = Methods.StudentLocation + "?"
        
        //make the request
        taskForGetMethod(method, parameters: parameters as [String : AnyObject]) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                completionHandler(nil, error)
            }
            else
            {
                if let results = JSONResult?.value(forKey: ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]]
                {
                    let locations = StudentLocation.locationsFromResults(results)
                    
                    completionHandler(locations, nil)
                }
                else
                {
                    print("Error parsing getStudentLocation -- couldn't find results string in json result")
                    completionHandler(nil, NSError(domain: "getStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not parse getStudentLocation"]))
                }
            }
        }
    }
    
    func postStudentLocation(_ location: StudentLocation, completionHandler: @escaping (_ result: String?, _ error: NSError?) -> Void)
    {
        //specify method and HTTP body
        let method : String = Methods.StudentLocation
        
        let jsonBody: [String : AnyObject] = [
            ParseClient.JSONBodyKeys.UniqueKey: location.uniqueKey as AnyObject,
            ParseClient.JSONBodyKeys.FirstName: location.firstName as AnyObject,
            ParseClient.JSONBodyKeys.LastName: location.lastName as AnyObject,
            ParseClient.JSONBodyKeys.MapString: location.mapString as AnyObject,
            ParseClient.JSONBodyKeys.MediaURL: location.mediaURL! as String as AnyObject,
            ParseClient.JSONBodyKeys.Latitude: location.latitude! as Double as AnyObject,
            ParseClient.JSONBodyKeys.Longitude: location.longitude! as Double as AnyObject
        ]
        
        //make the request
        taskForPostMethod(method, jsonBody: jsonBody) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                print("error from post method \(error)")
                completionHandler(nil, error)
            }
            else
            {
                if let objectID = JSONResult?.value(forKey: ParseClient.JSONResponseKeys.ObjectID) as? String
                {
                    if let createdAt = JSONResult?.value(forKey: ParseClient.JSONResponseKeys.CreatedAt) as? String
                    {
                        print("Student Location Posted \(objectID) \(createdAt)")
                        
                        completionHandler(objectID, nil)
                    }
                    else
                    {
                        print("Error parsing postStudentLocation -- couldn't find createdAt in json result")
                        completionHandler(nil, NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "couldn't find createdAt key in result"]))
                    }
                }
                else
                {
                    print("Error parsing postStudentLocation -- couldn't find objectID in json result")
                    completionHandler(nil, NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "couldn't find objectID key in result"]))
                }
            }
        }
    }
    
}
