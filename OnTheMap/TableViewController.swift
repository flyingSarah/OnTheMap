//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/20/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit

class TableViewController : UITableViewController {
    
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TableViewController.logout(_:)))
        
        let refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(TableViewController.refreshButtonClicked(_:)))
        
        let pinImage: UIImage = UIImage(named: "pin")!
        let pinButton: UIBarButtonItem = UIBarButtonItem(image: pinImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(TableViewController.addPin(_:)))
        
        let buttons = [refreshButton, pinButton]
        
        navigationItem.rightBarButtonItems = buttons
        
        //set locations on the map
        setLocations()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //only set the pins if the locations have already been set
        if(locationSet)
        {
            studentLocationTable.reloadData()
        }
    }
    
    //MARK --- Tab Bar Buttons
    
    @objc func logout(_ sender: AnyObject)
    {
        UdacityClient.sharedInstance().logoutOfSession() { result, error in
            
            if let error = error
            {
                //make alert view show up with error from the Udacity client
                self.showAlertController("Udacity Logout Error", message: error.localizedDescription)
            }
            else
            {
                print("Successfully logged out of Udacity session")
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func addPin(_ sender: AnyObject)
    {
        //Grab the information posting VC from Storyboard
        let object:AnyObject = storyboard!.instantiateViewController(withIdentifier: "InfoPostingViewController")
        
        let addPinVC = object as! InfoPostingViewController
        
        //present the view controller
        present(addPinVC, animated: true, completion: nil)
    }
    
    @objc func refreshButtonClicked(_ sender: AnyObject)
    {
        setLocations()
    }
    
    //MARK --- Table Behavior
    
    func setLocations()
    {
        ParseClient.sharedInstance().getStudentLocation() { result, error in
            
            if let error = error
            {
                //make alert view show up with error from the Parse Client
                self.showAlertController("Parse Error", message: error.localizedDescription)
            }
            else
            {
                print("Successfully got student info!")
                
                ParseClient.sharedInstance().studentLocations = result!
                self.locationSet = true
                self.studentLocationTable.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ParseClient.sharedInstance().studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let student = ParseClient.sharedInstance().studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) 
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let student = tableView.cellForRow(at: indexPath)
        
        if let urlString = student?.detailTextLabel?.text
        {
            if(verifyURL(urlString))
            {
                //open the url if valid
                print("open url: \(urlString)")
                UIApplication.shared.openURL(URL(string: urlString)!)
            }
            else
            {
                print("invalid url: \(urlString)")
                //if the url is not valid, show an alert view
                showAlertController("URL Lookup Failed", message: "The provided URL is not valid.")
            }
        }
    }
    
    //MARK --- Helpers
    
    //verify url
    func verifyURL(_ urlString: String?) -> Bool
    {
        if let urlString = urlString
        {
            if let url = URL(string: urlString)
            {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        
        return false
    }
    
    func showAlertController(_ title: String, message: String)
    {
        DispatchQueue.main.async(execute: {
            
            print("failure string from client: \(message)")
            
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        })
    }
}
