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
        
        //set placeholder text color
        //Found out how to do this from this stackoverflow topic: http://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        //add a little left indent/padding on the text fields
        //Found how to do this from this stackoverflow topic: http://stackoverflow.com/questions/7565645/indent-the-text-in-a-uitextfield
        var emailSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        emailTextField.leftViewMode = UITextFieldViewMode.Always
        emailTextField.leftView = emailSpacerView
        var passwordSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        passwordTextField.leftView = passwordSpacerView
        
        loginButton.enabled = false
        
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
                println("login complete! \(message)")
                self.completeLogin()
            }
            else
            {
                println("Login failed: \(message)")
                
                //get the description of the specific error that results from the failed request
                let failureError: NSError = error!
                let failureString = failureError.userInfo![NSLocalizedDescriptionKey] as! String
                
                self.displayError("\(failureString)")
            }
        }
    }
    
    @IBAction func signUpWithUdacity(sender: UIButton)
    {
        let url = NSURL(string: "https://www.google.com/url?q=https://www.udacity.com/account/auth%23!/signin&sa=D&usg=AFQjCNHOjlXo3QS15TqT0Bp_TKoR9Dvypw")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    //MARK --- Login Behavior
    
    func completeLogin()
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?)
    {
        UdacityClient.sharedInstance().loginError = errorString
        
        dispatch_async(dispatch_get_main_queue(), {
            
            //learned how to implement an alert controller from this website: http://swiftoverload.com/uialertcontroller-swift-example/
            let alert: UIAlertController = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: .Alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            
            self.showViewController(alert, sender: true)
        })
    }
    
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