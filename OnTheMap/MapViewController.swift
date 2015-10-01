//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/16/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //MARK --- Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK --- Useful Variables
    
    var locationsSet = false
    let emptyURLSubtitleText = "Student has not entered a URL"
    
    //MARK --- Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //set the map view delegate
        mapView.delegate = self
        
        //create the needed bar button items - I referenced this website http://stackoverflow.com/questions/30341263/how-to-add-two-multiple-uibarbuttonitems-on-right-side-of-navigation-bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("logout:"))
        
        var refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("refreshButtonClicked:"))
        
        var pinImage: UIImage = UIImage(named: "pin")!
        var pinButton: UIBarButtonItem = UIBarButtonItem(image: pinImage,  style: UIBarButtonItemStyle.Plain, target: self, action: Selector("addPin:"))
        
        var buttons = [refreshButton, pinButton]
        
        navigationItem.rightBarButtonItems = buttons
        
        //set the locations on the map
        setLocations()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //only set the pins if the locations have already been set
        if(locationsSet)
        {
            setPinsOnMap()
        }
    }
    
    //MARK --- Tab Bar Buttons
    
    func logout(sender: AnyObject)
    {
        UdacityClient.sharedInstance().logoutOfSession() { result, error in
            
            if let error = error
            {
                //make alert view show up with error from the Udacity client
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let failureString = error.userInfo![NSLocalizedDescriptionKey] as! String
                    println("failure string from udacity client: \(failureString)")
                    
                    let alert: UIAlertController = UIAlertController(title: "Udacity Logout Error", message: failureString, preferredStyle: .Alert)
                    let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alert.addAction(okAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                })
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
        
        //Present the view controller
        presentViewController(addPinVC, animated: true, completion: nil)
    }
    
    func refreshButtonClicked(sender: AnyObject)
    {
        setLocations()
    }
    
    //MARK --- Map Behavior
    
    func setLocations()
    {
        ParseClient.sharedInstance().getStudentLocation() { result, error in
            
            if let error = error
            {
                //make alert view show up with error from the Parse Client
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let failureString = error.userInfo![NSLocalizedDescriptionKey] as! String
                    println("failure string from parse client: \(failureString)")
                    
                    let alert: UIAlertController = UIAlertController(title: "Parse Error", message: failureString, preferredStyle: .Alert)
                    let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alert.addAction(okAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
            else
            {
                println("Successfully got student info!")
                
                ParseClient.sharedInstance().studentLocations = result!
                self.locationsSet = true
                self.setPinsOnMap()
            }
        }
    }
    
    func setPinsOnMap()
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            //first remove annootations currently showing on the map view
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            var annotations = [MKPointAnnotation]()
            
            //get the needed data for every student
            for student in ParseClient.sharedInstance().studentLocations
            {
                let firstName = student.firstName
                let lastName = student.lastName
                
                var mediaURL = ""
                if(student.mediaURL != nil)
                {
                    mediaURL = student.mediaURL!
                }
                else
                {
                    mediaURL = self.emptyURLSubtitleText
                }
            
                let latitude = CLLocationDegrees(student.latitude!)
                let longitude = CLLocationDegrees(student.longitude!)
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let uniqueKey = student.uniqueKey
                
                //construct an anotation
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                //add each single annotation to the array
                annotations.append(annotation)
            }
            
            //add the annotations to the map veiw
            self.mapView.addAnnotations(annotations)
        })
    }
    
    //MARK -- MKMapViewDelegate functions that allow you to click on URLs in the pin views on the map
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    {
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if(pinView == nil)
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            let thisTitle = annotation.title!
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else
        {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!)
    {
        if(annotationView.annotation.subtitle != emptyURLSubtitleText)
        {
            if(control == annotationView.rightCalloutAccessoryView)
            {
                let urlString = annotationView.annotation.subtitle!
                
                if(verifyURL(urlString))
                {
                    //open the url if valid
                    UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
                }
                else
                {
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
    }
    
    //MARK --- Helpers
    
    // learned how to verify urls from this website: http://stackoverflow.com/questions/28079123/how-to-check-validity-of-url-in-swift
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
