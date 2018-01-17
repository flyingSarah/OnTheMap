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
    @IBOutlet weak var browseButton: UIButton!
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
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        locationTextField.delegate = self
        urlTextField.delegate = self
        
        mapView.delegate = self
        
        //set placeholder text color
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Location", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        urlTextField.attributedPlaceholder = NSAttributedString(string: "Enter a URL to share", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        findButton.isEnabled = false
        submitButton.isEnabled = false
        browseButton.isEnabled = false
        
        //initialize tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(InfoPostingViewController.handleSingleTap(_:)))
        tapRecognizer!.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let userInfo = UdacityClient.sharedInstance()
        
        //If the user has already posted, show the data associated with the user
        if(userInfo.mediaURL != nil)
        {
            locationTextField.text = userInfo.mapString
            urlTextField.text = userInfo.mediaURL
            
            //remove any annotation currently showing on the map
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapAnnotation = nil
            
            //construct annotation
            let annotation = MKPointAnnotation()
            let coordinates = CLLocationCoordinate2D(latitude: userInfo.latitude!, longitude: userInfo.longitude!)
            annotation.coordinate = coordinates
            annotation.title = "\(userInfo.firstName!) \(userInfo.lastName!)"
            annotation.subtitle = userInfo.mediaURL!
            
            //add the annotation to the map view
            self.mapView.addAnnotation(annotation)
            self.mapAnnotation = annotation
            
            //Zoom in on the map pin
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(annotation.coordinate, 5000, 5000), animated: false)
            
            submitButton.isEnabled = true
            findButton.isEnabled = true
            browseButton.isEnabled = true
        }
        
        //add the tap recognizer
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        //remove the tap recognizer
        removeKeyboardDismissRecognizer()
    }
    
    //MARK --- Actions
    @IBAction func findLocation(_ sender: AnyObject)
    {
        dismissAnyVisibleKeyboards()
        
        //use an activity monitor for this action
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.center = view.center
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        CLGeocoder().geocodeAddressString(locationTextField.text!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
        
            if error != nil
            {
                //show alert view when geocoding the address fails
                self.showAlertController("Geocoder Error", message: error!.localizedDescription)
                
                return
            }
            
            if let placemark = placemarks?[0] as CLPlacemark!
            {
                self.latitude = placemark.location!.coordinate.latitude
                self.longitude = placemark.location!.coordinate.longitude
                
                self.setPinOnMap()
            }
            else
            {
                self.showAlertController("Geocoder Error", message: "Unknown error from geocoder.")
            }
            
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        } as! CLGeocodeCompletionHandler)
    }
    
    @IBAction func browseURL(_ sender: AnyObject)
    {
        let urlString = urlTextField.text
        
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
    
    @IBAction func postInfo(_ sender: AnyObject)
    {
        dismissAnyVisibleKeyboards()
    
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
            
            if let error = error
            {
                //make alert view show up with error from the Parse Client
                self.showAlertController("Udacity Posting Error", message: error.localizedDescription)
            }
            else
            {
                print("Successfully posted user info!")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField)
    {
        //only enable the find button if the location text field isn't empty
        if(locationTextField.text!.isEmpty)
        {
            findButton.isEnabled = false
        }
        else
        {
            findButton.isEnabled = true
        }
        
        //only enable the browse button if the url text field isn't empty
        if(urlTextField.text!.isEmpty)
        {
            browseButton.isEnabled = false
        }
        else
        {
            browseButton.isEnabled = true
        }
        
        //only enable the submit button if neither of the info text fields are empty and if the map has found a valid location
        if(urlTextField.text!.isEmpty || locationTextField.text!.isEmpty)
        {
            submitButton.isEnabled = false
        }
        else if(mapView.annotations.isEmpty)
        {
            submitButton.isEnabled = false
        }
        else
        {
            submitButton.isEnabled = true
        }
    }
    
    //only call this after latitude and longitude has been set using the findLocation function
    func setPinOnMap()
    {
        DispatchQueue.main.async(execute: {
            
            //first remove any annotation currently showing on the map
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapAnnotation = nil
            
            let annotation = MKPointAnnotation()
            
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
            
            //Zoom in on the map pin
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinates, 5000, 5000), animated: true)
        })
    }
    
    //MARK --- MKMapViewDelegate functions that allow you to click on URLs in the pin veiw on the map
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
        if(annotationView.annotation!.subtitle! != "You have not entered a URL")
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
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return true
    }
    
    //MARK --- Other Helpers
    
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

extension InfoPostingViewController {
    
    func dismissAnyVisibleKeyboards()
    {
        if(locationTextField.isFirstResponder || urlTextField.isFirstResponder)
        {
            view.endEditing(true)
        }
    }
}
