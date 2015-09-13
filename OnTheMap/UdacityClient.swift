//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/12/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    
    //shared session
    var session: NSURLSession
    
    //authentication state
    var sessionID: String? = nil
    var userID: Int? = nil
    
    override init()
    {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //MARK --- Get
    /*func taskForGetMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        //build the URL and configure the request
        
        //make the request
        
        //parse and use the data (happens in completion handler)
        
        //start the request
    }*/
    
    //MARK --- Post
    func taskForPostMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        //build the URL and configure the request
        let urlString = UdacityClient.Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        var jsonifyError: NSError? = nil
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        //make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            //parse and use the data (happens in completion handler)
            if let error = downloadError
            {
                let newError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            }
            else
            {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) //subset response data
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        //start the request
        task.resume()
        return task
    }
    
    //MARK --- Delete
    /*func taskForDeleteMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        //build the URL and configure the request
        
        //make the request
        
        //parse and use the data (happens in completion handler)
        
        //start the request
    }*/
    
    //MARK --- Helpers
    
    //Substitute the key for the value that is contained within the method name
    /*class func substituteKeyInMethod(method: String, key: String, value: String) -> String?
    {
        if(method.rangeOfString("{\(key)}") != nil)
        {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        }
        return nil
    }*/
    
    //Given a response with error, see if a status_message is returned, otherwise return the previous error
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError
    {
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject]
        {
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String
            {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    //Given raw JSON, return a usable Foundation object
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void)
    {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError
        {
            completionHandler(result: nil, error: error)
        }
        else
        {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    //Given a dictionary of parameters, convert to a string for a url
    /*class func escapedParameters(parameters: [String : AnyObject]) -> String
    {
        var queryItems = map(parameters) { NSURLQueryItem(name: $0, value: $1 as! String) }
        var components = NSURLComponents()
        
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
    }*/
    
    //MARK --- Shared Instance
    class func sharedInstance() -> UdacityClient
    {
        struct Singleton
        {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}