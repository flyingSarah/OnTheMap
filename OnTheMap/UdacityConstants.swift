//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/12/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

extension UdacityClient {
    
    //MARK --- Constants
    struct Constants
    {
        static let BaseURLSecure : String = "https://www.udacity.com/"
    }
    
    //MARK --- Methods
    struct Methods
    {
        static let AccountLogIn = "api/session"
        static let AccountLogOut = "api/session"
        static let AccountUserData = "api/users/"
    }
    
    //MARK --- URL Keys
    struct URLKeys
    {
        
    }
    
    //MARK --- Parameter Keys
    struct ParameterKeys
    {
        
    }
    
    //MARK --- JSON Body Keys
    struct JSONBodyKeys
    {
        static let Username = "username"
        static let Password = "password"
    }
    
    //MARK --- JSON Response Keys
    struct JSONResponseKeys
    {
        //TODO: find out what json response keys are in an error message from the Udacity API
        static let StatusMessage = "????"
        static let StatusCode = "????"
        
        static let Account = "account"
        static let Registered = "registered"
        static let UserID = "key"
        
        static let Session = "session"
        static let SessionID = "id"
        static let expiration = "expiration"
        
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
}