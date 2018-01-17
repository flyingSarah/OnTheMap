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
    
    func createSession(_ username: String, password: String, completionHandler: @escaping (_ message: String, _ error: NSError?) -> Void)
    {
        //Specify method and HTTP body
        let method: String = UdacityClient.Methods.AccountLogIn
        
        let jsonBody: [String : [String : AnyObject]] = [
            "udacity" : [
                UdacityClient.JSONBodyKeys.Username : username as AnyObject,
                UdacityClient.JSONBodyKeys.Password : password as AnyObject
            ]
        ]
        
        //make the request
        taskForPostMethod(method, jsonBody: jsonBody as [String : AnyObject]) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                completionHandler("Sign In Failed", error)
            }
            else
            {
                if let account = JSONResult?.value(forKey: UdacityClient.JSONResponseKeys.Account) as? NSDictionary
                {
                    if let userID = account.value(forKey: UdacityClient.JSONResponseKeys.UserID) as? String
                    {
                        //get the user data from here
                        self.getPublicUserData(userID) { message, error in
                            
                            if let error = error
                            {
                                completionHandler(message, error)
                            }
                            else
                            {
                                completionHandler(message, nil)
                            }
                        }
                    }
                }
                else
                {
                    completionHandler("Couldn't find account dictionary in createSession result", NSError(domain: "createSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Please check your username and password and try again."]))
                }
            }
        }
    }
    
    func logoutOfSession(_ completionHandler: @escaping (_ message: String, _ error: NSError?) -> Void)
    {
        //specify method
        let method: String = UdacityClient.Methods.AccountLogIn
        
        //make the request
        taskForDeleteMethod(method) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                completionHandler("Logout Failed", error)
            }
            else
            {
                if let session = JSONResult?.value(forKey: UdacityClient.JSONResponseKeys.Session) as? NSDictionary
                {
                    if let sessionID = session.value(forKey: UdacityClient.JSONResponseKeys.SessionID) as? String
                    {
                        //get the user data from here
                        completionHandler("Logout Successful", nil)
                    }
                }
                else
                {
                    completionHandler("Couldn't find session dictionary in logoutOfSession result", NSError(domain: "logoutOfSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unknown error: Try logging out again."]))
                }
            }
        }
    }
    
    func getPublicUserData(_ userID: String, completionHandler: @escaping (_ message: String, _ error: NSError?) -> Void)
    {
        //Specify method
        let method: String = UdacityClient.Methods.AccountUserData + userID
        
        taskForGetMethod(method) { JSONResult, error in
            
            //send the desired values to the completion handler
            if let error = error
            {
                completionHandler("Getting Public User Data Failed", error)
            }
            else
            {
                if let userDictionary = JSONResult?.value(forKey: UdacityClient.JSONResponseKeys.User) as? NSDictionary
                {
                    if let firstName = userDictionary.value(forKey: UdacityClient.JSONResponseKeys.FirstName) as? String
                    {
                        if let lastName = userDictionary.value(forKey: UdacityClient.JSONResponseKeys.LastName) as? String
                        {
                            UdacityClient.sharedInstance().userID = userID
                            UdacityClient.sharedInstance().firstName = firstName
                            UdacityClient.sharedInstance().lastName = lastName
                            
                            completionHandler("User Info aquired! UserID: \(userID) FirstName: \(firstName) LastName: \(lastName)", nil)
                        }
                        else
                        {
                            completionHandler("Unable to find last name in userDictionary", NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not parse getPublicUserData"]))
                        }
                    }
                    else
                    {
                        completionHandler("Unable to find first name in userDictionary", NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not parse getPublicUserData"]))
                    }
                }
                else
                {
                    completionHandler("Couldn't find user dictionary in getPublicUserData result", NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unknown Udacity error -- please check your username and password and try again."]))
                }
            }
        }
    }
    
    
}
