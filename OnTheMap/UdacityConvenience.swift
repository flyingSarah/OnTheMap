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
    
    func createSession(username: String, password: String, completionHandler: (message: String, error: NSError?) -> Void)
    {
        //Specify method and HTTP body
        var method: String = UdacityClient.Methods.AccountLogIn
        
        let jsonBody: [String : AnyObject] = [
            "udacity" : [
                UdacityClient.JSONBodyKeys.Username : username,
                UdacityClient.JSONBodyKeys.Password : password
            ]
        ]
        
        //make the request
        taskForPostMethod(method, jsonBody: jsonBody) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                completionHandler(message: "Sign In Failed", error: error)
            }
            else
            {
                if let account = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account) as? NSDictionary
                {
                    if let userID = account.valueForKey(UdacityClient.JSONResponseKeys.UserID) as? String
                    {
                        //get the user data from here
                        self.getPublicUserData(userID) { message, error in
                            
                            if let error = error
                            {
                                completionHandler(message: message, error: error)
                            }
                            else
                            {
                                completionHandler(message: message, error: nil)
                            }
                        }
                    }
                }
                else
                {
                    completionHandler(message: "Couldn't find account dictionary in createSession result", error: NSError(domain: "createSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Please check your username and password and try again."]))
                }
            }
        }
    }
    
    func logoutOfSession(completionHandler: (message: String, error: NSError?) -> Void)
    {
        //specify method
        var method: String = UdacityClient.Methods.AccountLogIn
        
        //make the request
        taskForDeleteMethod(method) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                completionHandler(message: "Logout Failed", error: error)
            }
            else
            {
                if let session = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) as? NSDictionary
                {
                    if let sessionID = session.valueForKey(UdacityClient.JSONResponseKeys.SessionID) as? String
                    {
                        //get the user data from here
                        completionHandler(message: "Logout Successful", error: nil)
                    }
                }
                else
                {
                    completionHandler(message: "Couldn't find session dictionary in logoutOfSession result", error: NSError(domain: "logoutOfSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unknown error: Try logging out again."]))
                }
            }
        }
    }
    
    func getPublicUserData(userID: String, completionHandler: (message: String, error: NSError?) -> Void)
    {
        //Specify method
        var method: String = UdacityClient.Methods.AccountUserData + userID
        
        taskForGetMethod(method) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                completionHandler(message: "Getting Public User Data Failed", error: error)
            }
            else
            {
                if let userDictionary = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User) as? NSDictionary
                {
                    if let firstName = userDictionary.valueForKey(UdacityClient.JSONResponseKeys.FirstName) as? String
                    {
                        if let lastName = userDictionary.valueForKey(UdacityClient.JSONResponseKeys.LastName) as? String
                        {
                            UdacityClient.sharedInstance().userID = userID
                            UdacityClient.sharedInstance().firstName = firstName
                            UdacityClient.sharedInstance().lastName = lastName
                            
                            completionHandler(message: "User Info aquired! UserID: \(userID) FirstName: \(firstName) LastName: \(lastName)", error: nil)
                        }
                        else
                        {
                            completionHandler(message: "Unable to find last name in userDictionary", error: NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not parse getPublicUserData"]))
                        }
                    }
                    else
                    {
                        completionHandler(message: "Unable to find first name in userDictionary", error: NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not parse getPublicUserData"]))
                    }
                }
                else
                {
                    completionHandler(message: "Couldn't find user dictionary in getPublicUserData result", error: NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unknown Udacity error -- please check your username and password and try again."]))
                }
            }
        }
    }
    
    
}