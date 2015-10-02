//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/19/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InfoPostingViewController : UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    //MARK --- Outlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK --- Variables
    
    var appDelegate: AppDelegate!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var mapAnnotation: MKPointAnnotation? = nil
    
    //MARK --- Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        locationTextField.delegate = self
        urlTextField.delegate = self
        
        mapView.delegate = self
        
        //set placeholder text color
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Location", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        urlTextField.attributedPlaceholder = NSAttributedString(string: "Enter a URL to share", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        findButton.enabled = false
        submitButton.enabled = false
        
        //initialize tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        tapRecognizer!.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        var userInfo = UdacityClient.sharedInstance()
        
        //If the user has already posted, show the data associated with the user
        if(userInfo.mediaURL != nil)
        {
            locationTextField.text = userInfo.mapString
            urlTextField.text = userInfo.mediaURL
            
            //remove any annotation currently showing on the map
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapAnnotation = nil
            
            //construct annotation
            var annotation = MKPointAnnotation()
            let coordinates = CLLocationCoordinate2D(latitude: userInfo.latitude!, longitude: userInfo.longitude!)
            annotation.coordinate = coordinates
            annotation.title = "\(userInfo.firstName!) \(userInfo.lastName!)"
            annotation.subtitle = userInfo.mediaURL!
            
            //add the annotation to the map view
            self.mapView.addAnnotation(annotation)
            self.mapAnnotation = annotation
            
            submitButton.enabled = true
            findButton.enabled = true
        }
        
        //add the tap recognizer
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        //remove the tap recognizer
        removeKeyboardDismissRecognizer()
    }
    
    //MARK --- Actions
    @IBAction func findLocation(sender: AnyObject)
    {
        dismissAnyVisibleKeyboards()
        
        CLGeocoder().geocodeAddressString(locationTextField.text, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            
            if error != nil
            {
                //show alert view when geocoding the address fails
                self.showAlertController("Geocoder Error", message: error.localizedDescription)
                
                return
            }
            
            if let placemark = placemarks?[0] as? CLPlacemark
            {
                self.latitude = placemark.location.coordinate.latitude
                self.longitude = placemark.location.coordinate.longitude
                
                self.setPinOnMap()
            }
            else
            {
                println("Unknown error from geocoder")
            }
        })
    }
    
    @IBAction func postInfo(sender: AnyObject)
    {
        dismissAnyVisibleKeyboards()
        
        //use an activity monitor for this action
        var activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.activityIndicatorViewStyle = .Gray
        activityIndicator.center = view.center
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        //set user info
        let userInfo = UdacityClient.sharedInstance()
        
        userInfo.mapString = locationTextField.text
        userInfo.mediaURL = urlTextField.text
        userInfo.latitude = latitude
        userInfo.longitude = longitude
        
        var studentLocation = StudentLocation()
        studentLocation.firstName = userInfo.firstName!
        studentLocation.lastName = userInfo.lastName!
        studentLocation.uniqueKey = userInfo.userID!
        studentLocation.mapString = userInfo.mapString!
        studentLocation.mediaURL = userInfo.mediaURL
        
        //set the subtitle for the map annotation
        if let annotation: MKPointAnnotation = mapAnnotation
        {
            annotation.subtitle = studentLocation.mediaURL
        }
        
        studentLocation.latitude = userInfo.latitude
        studentLocation.longitude = userInfo.longitude
        
        ParseClient.sharedInstance().postStudentLocation(studentLocation) { result, error in
            
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
            
            if let error = error
            {
                //make alert view show up with error from the Parse Client
                self.showAlertController("Udacity Posting Error", message: error.localizedDescription)
            }
            else
            {
                println("Successfully posted user info!")
                
                //Zoom in on the map pin
                self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: studentLocation.latitude!, longitude: studentLocation.longitude!), 5000, 5000), animated: true)
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func textFieldChanged(sender: UITextField)
    {
        if(locationTextField.text.isEmpty)
        {
            findButton.enabled = false
        }
        else
        {
            findButton.enabled = true
        }
        
        if(urlTextField.text.isEmpty || locationTextField.text.isEmpty)
        {
            submitButton.enabled = false
        }
        else
        {
            //only enable the submit button if the map has found a valid location
            if(mapView.annotations.isEmpty)
            {
                submitButton.enabled = false
            }
            else
            {
                submitButton.enabled = true
            }
            
        }
    }
    
    //only call this after latitude and longitude has been set using the findLocation function
    func setPinOnMap()
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            //first remove any annotation currently showing on the map
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapAnnotation = nil
            
            var annotation = MKPointAnnotation()
            
            //get the needed data for the user
            let userInfo = UdacityClient.sharedInstance()
            
            let firstName = userInfo.firstName!
            let lastName = userInfo.lastName!
            
            let latidude = CLLocationDegrees(self.latitude!)
            let longitude = CLLocationDegrees(self.longitude!)
            let coordinates = CLLocationCoordinate2D(latitude: latidude, longitude: longitude)
            
            //construct annotation
            annotation.coordinate = coordinates
            annotation.title = "\(firstName) \(lastName)"
            
            //add the annotation to the map view
            self.mapView.addAnnotation(annotation)
            self.mapAnnotation = annotation
        })
    }
    
    //MARK --- MKMapViewDelegate functions that allow you to click on URLs in the pin veiw on the map
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
        if(annotationView.annotation.subtitle != "You have not entered a URL")
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
                    showAlertController("URL Lookup Failed", message: "The provided URL is not valid.")
                }
            }
        }
    }
    
    //MARK --- Keyboard Helpers
    
    //dismiss the keyboard
    func addKeyboardDismissRecognizer()
    {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer()
    {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return true
    }
    
    //MARK --- Other Helpers
    
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
    
    func showAlertController(title: String, message: String)
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            println("failure string from client: \(message)")
            
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
}

extension InfoPostingViewController {
    
    func dismissAnyVisibleKeyboards()
    {
        if(locationTextField.isFirstResponder() || urlTextField.isFirstResponder())
        {
            view.endEditing(true)
        }
    }
}