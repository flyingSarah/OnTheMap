//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/20/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit

class TableViewController : UITableViewController, UITableViewDelegate {
    
    //MARK --- Outlets
    @IBOutlet var studentLocationTable: UITableView!
    
    //MARK --- Useful Variables
    
    var locationSet = false
    let emptyURLSubtitleText = "Student has not entered a URL"
    
    //MARK --- Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //create the needed bar button items
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("logout:"))
        
        var refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("refreshButtonClicked:"))
        
        var pinImage: UIImage = UIImage(named: "pin")!
        var pinButton: UIBarButtonItem = UIBarButtonItem(image: pinImage, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("addPin:"))
        
        var buttons = [refreshButton, pinButton]
        
        navigationItem.rightBarButtonItems = buttons
        
        //set locations on the map
        setLocations()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //only set the pins if the locations have already been set
        if(locationSet)
        {
            studentLocationTable.reloadData()
        }
    }
    
    //MARK --- Tab Bar Buttons
    
    func logout(sender: AnyObject)
    {
        UdacityClient.sharedInstance().logoutOfSession() { result, error in
            
            if let error = error
            {
                //TODO: make alert view show up with error from the Udacity client
                let failureString = error.userInfo![NSLocalizedDescriptionKey] as! String
                println("failure string from udacity client: \(failureString)")
            }
            else
            {
                println("Successfully logged out of Udacity session")
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func addPin(sender: AnyObject)
    {
        //Grab the information posting VC from Storyboard
        let object:AnyObject = storyboard!.instantiateViewControllerWithIdentifier("InfoPostingViewController")!
        
        let addPinVC = object as! InfoPostingViewController
        
        //present the view controller using navigation
        navigationController?.showViewController(addPinVC, sender: self)
    }
    
    func refreshButtonClicked(sender: AnyObject)
    {
        setLocations()
    }
    
    //MARK --- Table Behavior
    
    func setLocations()
    {
        ParseClient.sharedInstance().getStudentLocation() { result, error in
            
            if let error = error
            {
                //TODO: make alert view show up with error from the Parse Client
                let failureString = error.userInfo![NSLocalizedDescriptionKey] as! String
                println("failure string from parse client: \(failureString)")
            }
            else
            {
                println("Successfully got student info!")
                
                ParseClient.sharedInstance().studentLocations = result!
                self.locationSet = true
                self.studentLocationTable.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ParseClient.sharedInstance().studentLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let student = ParseClient.sharedInstance().studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
        
        var mediaURL = ""
        if(student.mediaURL != nil)
        {
            mediaURL = student.mediaURL!
        }
        else
        {
            mediaURL = emptyURLSubtitleText
        }
        
        cell.detailTextLabel!.text = mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let student = tableView.cellForRowAtIndexPath(indexPath)
        
        if let urlString = student?.detailTextLabel?.text
        {
            if(verifyURL(urlString))
            {
                //open the url if valid
                println("open url: \(urlString)")
                UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
            }
            else
            {
                println("invalid url: \(urlString)")
                //if the url is not valid, show an alert view
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let alert: UIAlertController = UIAlertController(title: "URL Lookup Failed", message: "The provided URL is not valid", preferredStyle: .Alert)
                    let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alert.addAction(okAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    //MARK --- Helpers
    
    //verify url
    func verifyURL(urlString: String?) -> Bool
    {
        if let urlString = urlString
        {
            if let url = NSURL(string: urlString)
            {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        
        return false
    }
}
