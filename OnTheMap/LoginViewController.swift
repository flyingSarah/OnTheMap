//
//  ViewController.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/10/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    //MARK --- Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK --- Variables
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    //MARK --- Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the shared url session
        session = NSURLSession.sharedSession()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //configure the UI
        configureUI()
        
        //initialize tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        tapRecognizer!.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
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
    
    @IBAction func loginToUdacity(sender: UIButton)
    {
        dismissAnyVisibleKeyboards()
        
        UdacityClient.sharedInstance().createSession(emailTextField.text, password: passwordTextField.text) { success, message, error in
            
            if(success)
            {
                println("login complete!")
            }
            else
            {
                println("login failed: message \(message) - error \(error)")
            }
        }
    }
    
    @IBAction func signUpWithUdacity(sender: UIButton)
    {
        
    }
    
    //MARK --- Login Behavior
    
    @IBAction func textFieldChanged(sender: UITextField)
    {
        if(emailTextField.text.isEmpty || passwordTextField.text.isEmpty)
        {
            loginButton.enabled = false
        }
        else
        {
            loginButton.enabled = true
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
    
    
    //MARK --- UI configuration
    
    func configureUI()
    {
        //TODO: configure background gradient
    }
}

extension LoginViewController {
    
    func dismissAnyVisibleKeyboards()
    {
        if(emailTextField.isFirstResponder() || passwordTextField.isFirstResponder())
        {
            view.endEditing(true)
        }
    }
}