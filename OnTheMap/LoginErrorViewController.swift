//
//  LoginErrorViewController.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/13/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit


class LoginErrorViewController: UIViewController {
    
    //MARK --- Outlets
    @IBOutlet weak var errorLabel: UILabel!
    
    //MARK --- Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        errorLabel.text = UdacityClient.sharedInstance().loginError
    }
    
    //MARK --- Actions
    @IBAction func okButtonTouchUp(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK --- UI configuration
    func configureUI()
    {
        //TODO: configure background gradient
    }
    
}