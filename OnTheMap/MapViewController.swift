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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MapViewController.logout(_:)))
        
        let refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(MapViewController.refreshButtonClicked(_:)))
        
        let pinImage: UIImage = UIImage(named: "pin")!
        let pinButton: UIBarButtonItem = UIBarButtonItem(image: pinImage,  style: UIBarButtonItemStyle.plain, target: self, action: #selector(MapViewController.addPin(_:)))
        
        let buttons = [refreshButton, pinButton]
        
        navigationItem.rightBarButtonItems = buttons
        
        //set the locations on the map
        setLocations()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //only set the pins if the locations have already been set
        if(locationsSet)
        {
            setPinsOnMap()
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
        
        //Present the view controller
        present(addPinVC, animated: true, completion: nil)
    }
    
    @objc func refreshButtonClicked(_ sender: AnyObject)
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
                self.showAlertController("Parse Error", message: error.localizedDescription)
            }
            else
            {
                print("Successfully got student info!")
                
                ParseClient.sharedInstance().studentLocations = result!
                self.locationsSet = true
                self.setPinsOnMap()
            }
        }
    }
    
    func setPinsOnMap()
    {
        DispatchQueue.main.async(execute: {
            
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
                _ = student.uniqueKey
                
                //construct an anotation
                let annotation = MKPointAnnotation()
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if(pinView == nil)
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            let thisTitle = annotation.title!
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else
        {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if(annotationView.annotation!.subtitle! != emptyURLSubtitleText)
        {
            if(control == annotationView.rightCalloutAccessoryView)
            {
                let urlString = annotationView.annotation!.subtitle!
                
                if(verifyURL(urlString))
                {
                    //open the url if valid
                    UIApplication.shared.openURL(URL(string: urlString!)!)
                }
                else
                {
                    //if the url is not valid, show an alert view
                    showAlertController("URL Lookup Failed", message: "The provided URL is not valid.")
                }
            }
        }
    }
    
    //MARK --- Helpers
    
    // learned how to verify urls from this website: http://stackoverflow.com/questions/28079123/how-to-check-validity-of-url-in-swift
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
