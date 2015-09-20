//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/17/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    //shared session
    var session: NSURLSession
    
    //shared student location arrays
    var studentLocations = [StudentLocation]()
    
    override init()
    {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //MARK --- Get
    func taskForGetMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        //build the url and configure the request
        let urlString = ParseClient.Constants.BaseURLSecure + method + ParseClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        //make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            //parse and use the data (happens in completion handler)
            if let error = downloadError
            {
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            }
            else
            {
                ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        return task
    }
    
    //MARK --- Post
    func taskForPostMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        //build the URL and configure the request
        let urlString = ParseClient.Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        var jsonifyError: NSError? = nil
        
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        //make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            //parse and use the data (happens in completion handler)
            if let error = downloadError
            {
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            }
            else
            {
                ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        //start the request
        task.resume()
        return task
    }
    
    //MARK --- Put
    func taskForPutMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        //build the URL and configure the request
        let urlString = ParseClient.Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        var jsonifyError: NSError? = nil
        
        request.HTTPMethod = "PUT"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        //make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            //parse and use the data (happens in completion handler)
            if let error = downloadError
            {
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            }
            else
            {
                ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        //start the request
        task.resume()
        return task
    }
    
    //MARK --- Helpers
    
    //given a response with error, see if a status_message is returned, otherwise return the previous error
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError?) -> NSError
    {
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject]
        {
            if let errorMessage = parsedResult[ParseClient.JSONResponseKeys.StatusMessage] as? String
            {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                if let errorCode = parsedResult[ParseClient.JSONResponseKeys.StatusCode] as? Int
                {
                    return NSError(domain: "Parse Error", code: errorCode, userInfo: userInfo)
                }
                
                return NSError(domain: "Parse Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error!
    }
    
    //Given raw JSON, return a useable Foundation object
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
            if let errorMessage = parsedResult?.valueForKey(ParseClient.JSONResponseKeys.StatusMessage) as? String
            {
                let newError = errorForData(data, response: nil, error: nil)
                completionHandler(result: nil, error: newError)
            }
            else
            {
                completionHandler(result: parsedResult, error: nil)
            }
            
        }
    }
    
    //given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String
    {
        var queryItems = map(parameters) { NSURLQueryItem(name: $0, value: $1 as! String) }
        var components = NSURLComponents()
        
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
    }
    
    //MARK --- Shared Instance
    class func sharedInstance() -> ParseClient
    {
        struct Singleton
        {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}