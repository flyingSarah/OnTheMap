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
    var session: URLSession
    
    //shared student location arrays
    var studentLocations = [StudentLocation]()
    
    override init()
    {
        session = URLSession.shared
        super.init()
    }
    
    //MARK --- Get
    func taskForGetMethod(_ method: String, parameters: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask
    {
        //build the url and configure the request
        let urlString = ParseClient.Constants.BaseURLSecure + method + ParseClient.escapedParameters(parameters)
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        //make the request
        let task = session.dataTask(with: request, completionHandler: { data, response, downloadError in
            
            //parse and use the data (happens in completion handler)
            if let error = downloadError
            {
                let newError = ParseClient.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            }
            else
            {
                ParseClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }) 
        
        task.resume()
        return task
    }
    
    //MARK --- Post
    func taskForPostMethod(_ method: String, jsonBody: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask
    {
        //build the URL and configure the request
        let urlString = ParseClient.Constants.BaseURLSecure + method
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        var jsonifyError: NSError? = nil
        
        request.httpMethod = "POST"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch let error as NSError {
            jsonifyError = error
            request.httpBody = nil
        }
        
        //make the request
        let task = session.dataTask(with: request, completionHandler: { data, response, downloadError in
            
            //parse and use the data (happens in completion handler)
            if let error = downloadError
            {
                let newError = ParseClient.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            }
            else
            {
                ParseClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }) 
        
        //start the request
        task.resume()
        return task
    }
    
    //MARK --- Put
    func taskForPutMethod(_ method: String, jsonBody: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask
    {
        //build the URL and configure the request
        let urlString = ParseClient.Constants.BaseURLSecure + method
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        var jsonifyError: NSError? = nil
        
        request.httpMethod = "PUT"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch let error as NSError {
            jsonifyError = error
            request.httpBody = nil
        }
        
        //make the request
        let task = session.dataTask(with: request, completionHandler: { data, response, downloadError in
            
            //parse and use the data (happens in completion handler)
            if let error = downloadError
            {
                let newError = ParseClient.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            }
            else
            {
                ParseClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }) 
        
        //start the request
        task.resume()
        return task
    }
    
    //MARK --- Helpers
    
    //given a response with error, see if a status_message is returned, otherwise return the previous error
    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError?) -> NSError
    {
        if let parsedResult = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String : AnyObject]
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
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError
        {
            completionHandler(nil, error)
        }
        else
        {
            if let errorMessage = parsedResult?.value(forKey: ParseClient.JSONResponseKeys.StatusMessage) as? String
            {
                let newError = errorForData(data, response: nil, error: nil)
                completionHandler(nil, newError)
            }
            else
            {
                completionHandler(parsedResult, nil)
            }
            
        }
    }
    
    //given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String
    {
        let queryItems = parameters.map { URLQueryItem(name: $0, value: $1 as? String) }
        var components = URLComponents()
        
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
