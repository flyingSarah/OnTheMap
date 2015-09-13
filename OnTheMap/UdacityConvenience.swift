//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/12/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit
import Foundation

extension UdacityClient {
    
    func createSession(username: String, password: String, completionHandler: (success: Bool, message: String, error: NSError?) -> Void)
    {
        //Specify method and HTTP body
        var method: String = Methods.AccountLogIn
        
        let jsonBody: [String : AnyObject] = [
            "udacity" : [
                UdacityClient.JSONBodyKeys.Username : username,
                UdacityClient.JSONBodyKeys.Password : password
            ]
        ]
        
        //make the request
        let task = taskForPostMethod(method, jsonBody: jsonBody) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                completionHandler(success: false, message: "Sign In Failed", error: error)
            }
            else
            {
                if let account = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account) as? NSDictionary
                {
                    if let userID = account.valueForKey(UdacityClient.JSONResponseKeys.UserID) as? String
                    {
                        println("success creating a session with user: \(userID)")
                        //TODO: get the user data from here
                    }
                }
                else
                {
                    //TODO: get a real message by parsing the error json result
                    completionHandler(success: false, message: "couldn't find account dictionary in post result", error: nil)
                }
            }
        }
    }
    
    
}