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
    var session: URLSession
    
    //authentication state
    var sessionID: String? = nil
    var userID: String? = nil
    var loginError: String? = nil
    
    //user data
    var firstName: String? = nil
    var lastName: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var mediaURL: String? = nil
    var mapString: String? = nil
    
    override init()
    {
        session = URLSession.shared
        super.init()
    }
    
    //MARK --- Get
    func taskForGetMethod(_ method: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask
    {
        //build the URL and configure the request
        let urlString = UdacityClient.Constants.BaseURLSecure + method
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        //make the request
        let task = session.dataTask(with: request, completionHandler: { data, response, downloadError in
            
            //parse and use the data (happens in completion handler)
            if let error = downloadError
            {
                let newError = UdacityClient.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            }
            else
            {
                let newData = data!.subdata(in: 5..<(data!.count - 5)) // subset response data
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }) 

        //start the request
        task.resume()
        return task
    }
    
    //MARK --- Post
    func taskForPostMethod(_ method: String, jsonBody: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask
    {
        //build the URL and configure the request
        let urlString = UdacityClient.Constants.BaseURLSecure + method
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        var jsonifyError: NSError? = nil
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
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
                let newError = UdacityClient.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            }
            else
            {
                let newData = data!.subdata(in: 5..<(data!.count - 5)) //subset response data
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }) 
        
        //start the request
        task.resume()
        return task
    }
    
    //MARK --- Delete
    func taskForDeleteMethod(_ method: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask
    {
        //build the URL and configure the request
        let urlString = UdacityClient.Constants.BaseURLSecure + method
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        var xsrfCookie: HTTPCookie? = nil
        request.httpMethod = "DELETE"
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! as [HTTPCookie]
        {
            if(cookie.name == "XSRF-TOKEN")
            {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie
        {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        //make the request
        let task = session.dataTask(with: request, completionHandler: { data, response, downloadError in
            
            //parse and use the data (happens in completion handler)
            if let error = downloadError
            {
                let newError = UdacityClient.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            }
            else
            {
                let newData = data!.subdata(in: 5..<(data!.count - 5)) //subset response data
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }) 
        
        //start the request
        task.resume()
        return task
    }
    
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
    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError
    {
        if let parsedResult = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String : AnyObject]
        {
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String
            {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                if let errorCode = parsedResult[UdacityClient.JSONResponseKeys.StatusCode] as? Int
                {
                    return NSError(domain: "Udacity Error", code: errorCode, userInfo: userInfo)
                }
                
                return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
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
            completionHandler(parsedResult, nil)
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
